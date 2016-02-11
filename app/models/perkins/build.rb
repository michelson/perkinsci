module Perkins
  module Build
    autoload :Data,     'perkins/build/data'
    autoload :Script,   'perkins/build/script'
    #autoload :Services, 'perkins/build/services'
    autoload :Shell,    'perkins/build/shell'

    HOME_DIR  = '$HOME'
    BUILD_DIR = File.join(HOME_DIR, 'build')

    class << self

      def script(config, options = {})
        #config  = config.deep_symbolize_keys
        lang  = (config.language || 'ruby').downcase.strip
        const = by_lang(lang)
        const.new(config, options)
      end

      def by_lang(lang)
        name = lang.split('_').map { |w| w.capitalize }.join
        Script.const_get(name, false) rescue Script::Ruby
      end

    end
  end
end