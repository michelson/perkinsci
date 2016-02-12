class Repo < ActiveRecord::Base
  attr_accessor :git
  attr_accessor :new_commit, :runner, :virtual_sha

  has_many :build_reports #, class_name: 'BuildReport'
  serialize :github_data, ActiveSupport::HashWithIndifferentAccess

  before_create :update_working_path

  scope :from_github, ->{where(cached: true)}
  scope :added, ->{where(cached: false)}

  def self.add_repo(id)
    repo = $github_client.repo(id.to_i)
    Repo.sync_github_repo(repo)
    r = Repo.add_from_github(id)
    r.add_hook rescue nil
    r
  end

  def self.add_from_github(id)
    github_repo  = synced_records.find_by(gb_id: id.to_i)
    store_from_github(github_repo)
  end

  def self.sync_github_repos(user=nil)
    $github_client.repos.each do |repo|
      self.sync_github_repo(repo)
    end
  end

  def self.sync_github_repo(r)
    repo = Repo.find_or_initialize_by(name: r[:full_name])
    repo.github_data = r.to_attrs.with_indifferent_access
    repo.cached = true
    repo.url    = r[:clone_url]
    repo.name   = r[:full_name]
    repo.gb_id  = r[:id]
    repo.save
  end

  def update_working_path
    self.working_dir ||= "/tmp"
  end

  def self.synced_records
    self.from_github
  end

  def self.store_from_github(repo)
    repo.cached = false
    repo.save
    repo
  end

  def self.initialize_from_store(opts)
    repo = Repo.new
    repo.url = opts["github_data"]["ssh_url"]
    repo.name = opts["name"]
    repo.github_data = opts["github_data"]
    repo.gb_id = opts["github_data"]["id"]
    repo.working_dir ||= "/tmp"
    repo
  end

  def load_git
    clone_or_load
  end

  def download!
    # we need this only in the context of the first clone
    # in the context of builds we are not going to notice 
    # the user that we are cloning the repo
    if self.virtual_sha.present?
      send_sse( status: "downloading")
      #self.update_column(:download_status, "downloading")
    end

    #clone repo
    ssh_url = self.github_data["ssh_url"]
    Git.clone(ssh_url, download_name, :path => working_dir)
    open
    
    #TODO: fix this & handle with care
    begin
      add_hook #permissions issue
    rescue Exception => e
      puts e.message
    end

    send_sse(status: "downloaded") if self.virtual_sha.present?
  end

  def download_name
    [name, self.virtual_sha].join
  end

  def add_hook(url=nil)
    url = hook_url if url.blank?
    if hook_id.blank?
      if existing_hook = hook_exists?
        puts "hook not added because is present".yellow
        self.update_attribute(:hook_id, existing_hook[:id]) if existing_hook[:id].present?
      else
        res = $github_client.create_hook(
          self.name,
          'web',
          { :url => url, :content_type => 'json'},
          { :events => ['push', 'pull_request'], 
            :active => true}
        )
        self.update_attribute(:hook_id, res[:id]) if res[:id].present?
      end
    end
  end

  def hook_exists?
    $github_client.hooks(self.name).detect do |o| 
      o[:config][:url] == self.hook_url
    end
  end

  def edit_hook(url)

    url = hook_url if url.blank?

    hook = get_hook
          
    if hook.present?
      res = $github_client.edit_hook(
        self.name,
        hook["id"],
        'web',
        {:url => url, :content_type => 'json'},
        {:active => true}
      )
      self.update_attribute(:hook_id, res[:id]) if res[:id].present?
    end
  end

  def hook_url
    u = ENV['endpoint']
    p = ENV['port'] == "80" ? nil : ENV['port']
    host = [u, p].compact.join(":")
    url = "#{host}/repos/receiver.json"
  end

  def get_hook
    return {} if self.hook_id.blank?
    $github_client.hook(self.name, self.hook_id)
  end

  def clone_or_load
    if exists?
      open
    else
      download!
    end
  end

  def open
    self.git = Git.open(local_path) #, :log => Logger.new(STDOUT) )
    build_runner_config
  end

  def check_config_existence
    puts "check travis.yml in: #{self.git.dir.path}".yellow
    config = self.git.chdir{
      if has_config_yml?
        config = Travis::Yaml.parse( File.open(".travis.yml").read )
      else
        config = Travis::Yaml.new
      end
      puts config.to_json.green
      config
    }
    config
  end

  def has_config_yml?
    File.exist?(".travis.yml")
  end

  def exists?
    File.exist?(local_path)
  end

  def local_path
   [ self.working_dir , self.download_name].join("/")
  end

  def branches
    self.git.branches.map(&:name)
  end

  #http://docs.travis-ci.com/user/build-configuration/#The-Build-Matrix
  def build_runner_config
    #config = self.check_config_existence
    runner = Runner.new()
    #runner.config = config
    runner.repo = self
    self.branch = runner_branch
    self.runner = runner
  end

  def runner_branch
    case self.branch
    when :all
      self.branches
    when nil
      ["master"]
    else
      self.branches.include?(self.branch) ? [self.branch] : ["master"]
    end
  end

  def add_commit(sha, branch)
    #if runner_branch.include?(branch)
      #@new_commit = Commit.new(sha, self)
      #@new_commit.branch = branch
      #enqueue_commit(@new_commit)
      enqueue_commit(sha, branch)
    #else
    #  puts "skipping commit from branch #{branch}"
    #end
  end

  def enqueue_commit(sha, branch)
    report = BuildReport.new
    report.sha = sha 
    report.branch = branch

    self.build_reports << report
    self.save
  end

  def attach_runner(report, sha)
    self.virtual_sha = "-#{report.id}-#{sha}"
    # will try to copy a base instance of repo
    self.copy_base_repo_to_runner_sha
    # repo.build_runner_config
    # it actually clone repo and instantiates git 
    # data & check travis.yml
    self.load_git
    return if self.runner.blank?
    self.runner.report = report
    self.runner.sha    = sha
    self.runner.branch = branch
    self
  end

  def local_base_repo
    working_dir + name
  end

  def local_base_repo_exists?
    File.exists?(local_base_repo)
  end

  def copy_base_repo_to_runner_sha
    return unless local_base_repo_exists?
    FileUtils.rm_r local_path if File.exists?(local_path)
    FileUtils.cp_r("#{local_base_repo}/.", local_path)
  end

  def http_url
    new_url = self.url.include?("http") ? self.url : self.url.gsub(":", "/")
    new_url.gsub!("git@", "https://")
    new_url.gsub!(".git", "")
    new_url
  end

  def last_report_id
    build_reports.availables.last.id if build_reports.availables.any?
  end

  def send_sse(msg)
    opts = {repo: {id: self.id, name: self.name }}
    opts[:repo].merge!(msg) if msg.is_a?(Hash)
    json_opts = opts.to_json
    #puts "Notify #{json_opts}".yellow
    ActionCable.server.broadcast "build_channel", opts
    #Redis.current.publish("message.", json_opts)
  end

end
