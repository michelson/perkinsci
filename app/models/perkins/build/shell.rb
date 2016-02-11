module Perkins
  module Build
    module Shell
      autoload :Dsl,     'perkins/build/shell/dsl'
      autoload :Node,    'perkins/build/shell/node'
      autoload :Cmd,     'perkins/build/shell/node'
      autoload :Script,  'perkins/build/shell/node'

      class InvalidParent < RuntimeError
        def initialize(node, required, actual)
          super("Node #{node.name} requires to be added to a #{required.name}, but is a #{actual.name}")
        end
      end
    end
  end
end