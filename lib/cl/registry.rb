module Cl
  class << self
    def []=(key, object)
      registry[key.to_sym] = object
    end

    def [](key)
      key && registry[key.to_sym]
    end

    def cmds
      registry.values
    end

    def registry
      @registry ||= {}
    end
  end

  module Registry
    class << self
      def included(const)
        const.send(:extend, ClassMethods)
        const.send(:include, InstanceMethods)
      end
    end

    module ClassMethods
      attr_reader :registry_key

      def [](key)
        Cl[key.to_sym]
      end

      def register(key)
        Cl.registry.delete(registry_key) if registry_key
        Cl[key] = self
        @registry_key = key.to_sym
      end
    end

    module InstanceMethods
      def registry_key
        self.class.registry_key
      end
    end
  end
end
