module Concerns
  module GitGateway
    include ActiveSupport::Concern


    #included do
    #  attr_accessor :git
    #end

    attr_accessor :git
    
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

    # TODO: move this logic outside
    def download
      # we need this only in the context of the first clone
      # in the context of builds we are not going to notice 
      # the user that we are cloning the repo
      if self.virtual_sha.present?
        send_sse( status: "downloading")
        #self.update_column(:download_status, "downloading")
      end

      # clone repo
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

    def open
      self.git = Git.open(local_path)
      build_runner_config
    end

    def has_config_yml?
      File.exist?(".travis.yml")
    end

    def branches
      self.git.branches.map(&:name)
    end

    def chdir(&block)
      self.git.chdir do
        puts "executing build in: #{self.git.dir.path}".yellow
        block.call
      end
    end

  end
end