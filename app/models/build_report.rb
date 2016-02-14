class BuildReport < ActiveRecord::Base
  belongs_to :repo

  after_commit :enqueue, on: :create

  serialize :commit

  include AASM

  aasm column: :build_status do
    state :queued, :initial => true
    state :stopped
    state :started

    event :start, :after_commit => :notify_start_job do
      transitions :from => :queued, :to => :started
    end

    event :stop, :after_commit => :notify_stopped_job do
      transitions :from => :started, :to => :stopped
    end

  end

  scope :availables, ->{
    where("build_status IN(?)", ["started", "stopped"])
  }

  def notify_start_job
    self.repo.send_sse(status: "start", report: self )
    #@repo.update_column(:build_status, "started")
    self.build_status_report(self.sha, "pending")
  end

  def notify_stopped_job
    # self.repo.update_column(:build_status, "stopped")
    self.repo.send_sse({ status: "finished", report: self })
    self.send_github_status(sha)
    # enqueue the oldest build report, if any
    self.repo.build_reports.queued.first.try(:enqueue)
  end

  def enqueue
    BuildWorker.perform_async(self.id, sha )
  end

  def to_duration
    ChronicDuration.output(duration.to_i)
  end

  def build_with(sha)
    self.retrieve_commit_info
    repo = self.repo
    repo.attach_runner(self, sha)
    repo.runner.run(sha)
  end

  def retrieve_commit_info
    hsh = $github_client.commits(repo.name, sha).first.to_attrs
    self.commit = hsh
    self.save
  end

  def send_github_status(sha)
    #self.repo.git
    self.build_status_report(sha, github_state)
  end

  def as_json(options = {})
    data = {}

    unless fields = options[:only]
      fields = [:id, :sha, :commit, :branch, :build_time,
                :status, :duration, :build_time, :response, :build_status]
    end

    fields.each { |k| data[k] = send(k) }

    data
  end

  # Status report to GITHUB repo
  def build_status_report(sha, state)
    $github_client.create_status(
      self.repo.name, sha,
      state, 
      { context: "Perkins CI", 
        description: github_state_description , 
        target_url: github_state_url 
      }
    ) rescue "error sending github state!!!! notify this"
    puts "Sending Github #{state} status to #{self.repo.name}".green
  end

  def github_state
    self.status ? "success" : "failure"
  end

  def github_state_description
    d = "- The Perkins CI build"
    d = self.status ? "passed" : "fail"
  end

  def github_state_url
    "#{ENV['ENDPOINT']}/repos/#{repo.name}/builds/#{self.id}"
  end

end
