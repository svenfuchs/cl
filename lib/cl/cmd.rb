require 'cl/registry'

module Cl
  module Cmd
    def self.included(const)
      const.send :include, Registry
      const.send :extend, ClassMethods
    end

    module ClassMethods
      def args(*args)
        args.any? ? @args = args : @args ||= []
      end

      def purpose(purpose = nil)
        purpose ? @purpose = purpose : @purpose
      end

      def on(*args, &block)
        opts << [args, block]
      end

      def opts
        @opts ||= superclass.respond_to?(:opts) ? superclass.opts : []
      end
    end
  end
end
