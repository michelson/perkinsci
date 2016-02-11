require 'core_ext/hash/deep_merge'
require 'core_ext/hash/deep_symbolize_keys'
require 'core_ext/object/false'
require 'erb'

module Perkins
  module Build
    class Script
      autoload :Helpers, 'perkins/build/script/helpers'

      #autoload :Stages,  'perkins/build/script/stages'
      #autoload :Ruby,    'perkins/build/script/ruby'
      #autoload :Go,      'perkins/build/script/go'

      #autoload :Addons,         'perkins/build/script/addons'
      #autoload :Android,        'perkins/build/script/android'
      autoload :Bundler,        'perkins/build/script/bundler'
      #autoload :C,              'perkins/build/script/c'
      #autoload :Cpp,            'perkins/build/script/cpp'
      #autoload :Clojure,        'perkins/build/script/clojure'
      #autoload :DirectoryCache, 'perkins/build/script/directory_cache'
      #autoload :Erlang,         'perkins/build/script/erlang'
      #autoload :Git,            'perkins/build/script/git'
      autoload :Go,             'perkins/build/script/go'
      #autoload :Groovy,         'perkins/build/script/groovy'
      #autoload :Generic,        'perkins/build/script/generic'
      #autoload :Haskell,        'perkins/build/script/haskell'
      autoload :Helpers,        'perkins/build/script/helpers'
      autoload :Jdk,            'perkins/build/script/jdk'
      #autoload :Jvm,            'perkins/build/script/jvm'
      #autoload :NodeJs,         'perkins/build/script/node_js'
      #autoload :ObjectiveC,     'perkins/build/script/objective_c'
      #autoload :Perl,           'perkins/build/script/perl'
      #autoload :Php,            'perkins/build/script/php'
      #autoload :PureJava,       'perkins/build/script/pure_java'
      #autoload :Python,         'perkins/build/script/python'
      autoload :Ruby,           'perkins/build/script/ruby'
      #autoload :Rust,           'perkins/build/script/rust'
      autoload :RVM,            'perkins/build/script/rvm'
      #autoload :Scala,          'perkins/build/script/scala'
      autoload :Services,       'perkins/build/script/services'
      autoload :Stages,         'perkins/build/script/stages'

      TEMPLATES_PATH = File.expand_path('../script/templates', __FILE__)

      STAGES = {
        builtin: [:configure, :checkout, :pre_setup, :export, :setup, :announce],
        custom:  [:before_install, :install, :before_script, :script, :after_result, :after_script]
      }

      attr_reader :stack, :repo, :config
      attr_reader :data, :options

      class << self
        def defaults
          self::DEFAULTS
        end
      end


      include Helpers, Stages #, DirectoryCache

      def initialize(data, repo)
        @config = data #used in runner
        @repo = repo
        #@stack = []
        @data = Data.new({ config: self.class.defaults }.deep_merge(data.deep_symbolize_keys))
        @options = options
        @stack = [Shell::Script.new(echo: true, timing: true)]
      end

      #run stages
      def compile
        #run_stages if check_config
        #@stack.compact.join(" && ")
        raw template 'header.sh'
        run_stages.compact if check_config
        raw template 'footer.sh'
        sh.to_s
      end

      private

      def check_config
        case data.config.present? #[:".result"]
        when 'not_found'
          echo 'Could not find .travis.yml, using standard configuration.', ansi: :red
          true
        when 'server_error'
          echo 'Could not fetch .travis.yml from GitHub.', ansi: :red
          raw 'travis_terminate 2'
          false
        else
          true
        end
      end

      def config
        data.config
      end

      def export
=begin
        set 'TRAVIS', 'true', echo: false
        set 'CI', 'true', echo: false
        set 'CONTINUOUS_INTEGRATION', 'true', echo: false
        set 'HAS_JOSH_K_SEAL_OF_APPROVAL', 'true', echo: false

        newline if data.env_vars_groups.any?(&:announce?)

        data.env_vars_groups.each do |group|
          echo "Setting environment variables from #{group.source}", ansi: :yellow if group.announce?
          group.vars.each { |var| set var.key, var.value, echo: var.to_s }
        end

        newline if data.env_vars_groups.any?(&:announce?)
=end
      end

      def finish
        puts "finish"
        #"push_directory_cache"
      end

      def pre_setup
        puts "pre setup"
        #start_services
        #setup_apt_cache if data.cache? :apt
        #fix_ps4
        #run_addons(:after_pre_setup)
      end

      def setup
        puts "setup"
        #setup_directory_cache
      end

      def announce
        # overwrite
      end

      def configure
        #fix_resolv_conf
        #fix_etc_hosts
      end

      #instance git repo
      def checkout
        #@repo.load_git
        nil
      end

      STAGES[:custom].each do |meth|
       define_method(meth) do
          puts "Configure custom #{meth}".green
        end
      end

      def template(filename)
        @working_dir = @repo.working_dir + @repo.download_name
        #puts "REPO REPO #{@working_dir}"
        ERB.new(File.read(File.expand_path(filename, TEMPLATES_PATH))).result(binding)
      end

    end

  end
end