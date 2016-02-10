
class Runner

  attr_accessor :repo, :report, :command, :config, :sha, :branch
  attr_reader :build_time, :duration, :response, :status, :current_build

  def exec(cmd)
    result = run_script(cmd)
    @response = result.join("")
    
    if result.last.chomp.include?("with 0")
      @status = true
    elsif result.last.chomp.include?("with 1")
      @status = false
    else
      puts "status result not found!!"
      @status = false
    end
        
    #puts result
    #process_status = $?
    #if successful_command?(process_status) || config_command_with_empty_value?(result,process_status)
    #  @response = result
    #  @status = true
    #  return result
    #else
    #  @response = result
    #  @status = false
    #end
  end

  def run_script(source)
    script = File.expand_path(
      "~/.perkins/.build/#{repo.name}/travis-build-#{sha}" #<< stages.join('-')
    )
    FileUtils.mkdir_p(File.dirname(script))
    File.open(script, 'w') { |f| f.write(source) }
    FileUtils.chmod(0755, script)
    Bundler.with_clean_env{
      pipe_command("#{script} 2>&1")
      #`bash #{script} 2>&1`.chomp
    }
  end

  def pipe_command(cmd)
    output = []
    r, io = IO.pipe
    pid = fork do
      @process = system(cmd, out: io, err: :out)
    end
    io.close
    r.each_line{|l| 
      puts l.yellow
      output << l
      #puts "CURRENT DIR: #{Dir.pwd} !!!!!"
      #puts "CURRENT GIT DIR: #{repo.git.dir.path} !!!!!"
      #puts "#{repo.download_name} !!!!!!!"
      #updates each time, this should trigger event to interface to refresh
      @current_report.update_column(:response, output.join(""))
    } 
    #Process.waitpid(p1) #this is to get the $ exitstatus
    output
  end

  def run(sha)
    self.sha = sha
    start_build
    self.repo.virtual_sha = "-#{@current_report.id}-#{self.sha}"
    #it actually clone repo and instantiates git data
    repo.load_git
    #fetch & reset to sha
    git_update(sha)
    #check travis yml
    config = repo.check_config_existence
    #build script
    script = Perkins::Build::script(config, repo)

    repo.git.chdir do
      #puts "CURRENT DIR: #{Dir.pwd} !!!!!"
      #puts "CURRENT GIT DIR: #{repo.git.dir.path} !!!!!"
      set_build_stats do
        puts "perform build".green
        self.exec(script.compile)
      end
    end
    #store_report
    stop_build
  end

  def start_build
    @running = true
    store_report
    @current_report.start!
    @repo.send_sse(status: "start")
    @repo.update_column(:build_status, "started")
    @current_report.build_status_report(sha, "pending")
  end

  def stop_build
    @running = false
    @current_report.stop!
    @current_report.update_attributes(self.to_report)
    @repo.update_column(:build_status, "stopped")
    @repo.send_sse({ status: "stop", report: self })
    @current_report.send_github_status(sha)
  end

  def set_build_stats(&block)
    up = Time.now
    #call the command itself
    block.call
    down = Time.now
    @build_time = down
    @duration = down - up
  end

  def running?
    @running
  end

  def successful_command?(process_status)
    process_status.exitstatus.to_i == 0
  end

  def config_command_with_empty_value?(result, process_status)
    process_status.exitstatus.to_i == 1 && result.empty?
  end

  def working_dir
    repo.git.dir.path
  end

  def git_update(branch)
    puts "fetch repo & reset to sha #{sha}".green
    repo.git.fetch()
    puts repo.git.reset_hard(sha).green
  end

  #TODO: add a serialized commit in order to avoid
  #Perkins::Commit initialization in every instantiation
  def to_report
    {
      build_time: self.build_time,
      duration: self.duration,
      response: self.response,
      status: self.status,
      sha: self.sha,
      branch: self.branch.to_s
    }
  end

  def store_report
    @current_report = Perkins::BuildReport.find(report)
  end

  def get_builds
    repo.build_reports
  end

end