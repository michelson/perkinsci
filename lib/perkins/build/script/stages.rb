module Perkins
  module Build
    class Script
      module Stages

        def run_stages
          STAGES[:builtin].each { |stage| run_builtin_stage(stage) }
          STAGES[:custom].each  { |stage| run_stage(stage) }
        end

        def run_builtin_stage(stage)
          self.send(stage)
        end

        def run_stage(stage)
          puts "Running stage: #{stage}".yellow
          call_custom_stage(stage)
        end

        def call_custom_stage(stage)
          if @config.send(stage).present? 
            cmd(@config.send(stage))
          else
            self.send(stage)
          end
        end

      end
    end
  end
end