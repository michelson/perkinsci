require 'travis/build/script/shared/jdk'

module Travis
  module Build
    class Script
      class Clojure < Script
        include Jdk

        DEFAULTS = {
          lein: 'lein',
          jdk:  'default'
        }

        def announce
          super
          sh.cmd "#{lein} version"
        end

        def install
          sh.cmd "#{lein} deps", fold: 'install', retry: true
        end

        def script
          sh.cmd "#{lein} test"
        end

        def cache_slug
          super << '--lein-' << lein
        end

        private

          def lein
            config[:lein].to_s
          end
      end
    end
  end
end
