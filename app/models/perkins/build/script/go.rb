module Perkins
  module Build
    class Script
      class Go < Script
        DEFAULTS = {
          gobuild_args: '-v',
          go: '1.3.1'
        }

        def cache_slug
          super << "--go-" << config[:go].to_s
        end

        def pre_setup
          puts "configure"
        end

        def configure
          puts "configure"
        end

        def export
          super
          "export GO_VERSION=#{go_version}"
        end

        def announce
          super
          'gvm version && ' <<
          'go version && ' <<
          'go env'
        end

        def setup
          super
          "gvm get &&" <<
          "gvm update && source #{HOME_DIR}/.gvm/scripts/gvm && " <<
          "gvm install #{go_version} --binary || gvm install #{go_version} && " <<
          "gvm use #{go_version} && "
          # Prepend *our* GOPATH entry so that built binaries and packages are
          # easier to find and our `git clone`'d libraries are found by the
          # `go` commands.
          source_path = repo.url.gsub(/https\:\/\/|\.git/, "")
          source_owner_path = source_path.split('/')[0..1].join("/")
          local_path = self.repo.working_dir + self.repo.download_name
          "export GOPATH=#{HOME_DIR}/gopath:$GOPATH && " <<
          "mkdir -p #{HOME_DIR}/gopath/src/#{source_owner_path} && " <<
          "cp -r #{local_path} #{HOME_DIR}/gopath/src/#{source_owner_path} && " <<
          "export BUILD_DIR=#{HOME_DIR}/gopath/src/#{source_path} && " <<
          "cd #{HOME_DIR}/gopath/src/#{source_path}"
        end

        def install
          if uses_make?
            'true'
          else
            "go get #{config[:gobuild_args]} ./..."
          end
        end

        def script
          if uses_make?
            'make'
          else
            "go test #{config[:gobuild_args]} ./..."
          end
        end

        private

          def uses_make?(*args)
            self.if '-f GNUmakefile || -f makefile || -f Makefile || -f BSDmakefile', *args
          end

          def go_version
            version = config[:go].to_s
            case version
            when '1'
              'go1.3.1'
            when '1.0'
              'go1.0.3'
            when '1.2'
              'go1.2.2'
            when '1.3'
              'go1.3.1'
            when /^[0-9]\.[0-9\.]+/
              "go#{config[:go]}"
            else
              if config[:go].is_a?(Travis::Yaml::Nodes::VersionList)
                config[:go].first
              else
                config[:go]
              end
            end
          end
      end
    end
  end
end