module Concerns
  module GithubGateway
    include ActiveSupport::Concern

    def check_config_existence(sha="master")
      puts "check travis.yml in: #{self.name}".yellow

      begin
        opts = { :path => '.travis.yml', :ref => sha }
        content = $github_client.contents(self.name, opts)
      rescue
        return Travis::Yaml.new
      end

      decoded = Base64.decode64(content[:content])
      # config = Travis::Yaml.parse(decoded)
      # support for matrix is comming soon
      config = Travis::Yaml.matrix(decoded)

      config.last
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

      archive = $github_client.archive_link(self.name, ref: virtual_sha)
      system("mkdir -p #{self.local_path}")
      system("curl -L #{archive} > #{self.local_path}.tar.gz")
      system("tar --strip-components=1 -xvf #{self.local_path}.tar.gz -C #{self.local_path}")
      system("rm #{self.local_path}.tar.gz")
      
      #TODO: fix this & handle with care
      begin
        add_hook #permissions issue
      rescue Exception => e
        puts e.message
      end

      send_sse(status: "downloaded") if self.virtual_sha.present?
    end

    def open
      build_runner_config
    end

    def branches
      $github_client.branches(name)
    end

    def chdir(&block)
      Dir.chdir(local_path) do
        puts "executing build in: #{Dir.pwd}".yellow
        block.call
      end
    end
    
  end
end 

