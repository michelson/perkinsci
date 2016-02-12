class BuildReport < ActiveRecord::Base
  belongs_to :repo

  after_create :enqueue

  serialize :commit

  scope :availables, ->{where("build_status =? OR build_status =?", "started", "stopped" )}

  def enqueue
    BuildWorker.perform_async(self.id, sha, branch )
  end

  include AASM

  aasm column: :build_status do
    state :queued, :initial => true
    state :stopped
    state :started

    event :start do
      transitions :from => :queued, :to => :started
    end

    event :stop do
      transitions :from => :started, :to => :stopped
    end

  end

  def to_duration
    ChronicDuration.output(duration.to_i)
  end

  def build_with(sha, branch)
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
    puts "Sending Github #{state} status to #{self.repo.name}".green
    $github_client.create_status(
      self.repo.name, sha,
      state, 
      { context: "Perkins CI", 
        description: github_state_description , 
        target_url: github_state_url 
      }
    )
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

=begin
  def started?
    build_status == "started"
  end

  def stopped?
    build_status == "stopped"
  end

  def start!
    update_attribute(:build_status, "started")
  end

  def stop!
    update_attribute(:build_status, "stopped")
  end
=end

end
