class Cl
  class << self
    def []=(key, object)
      registry[key.to_sym] = object
    end

    def [](key)
      key && registry[key.to_sym]
    end

    def registered?(key)
      registry.key?(key)
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
        unregister if registry_key
        @registry_key = key.to_sym
        Cl[key] = self
      end

      def unregister
        @registry_key = nil
        Cl.registry.delete(registry_key)
      end
    end

    module InstanceMethods
      def registry_key
        self.class.registry_key
      end
    end
  end
end
