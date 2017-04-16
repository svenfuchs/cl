require 'cl/registry'

module Cl
  class Cmd < Struct.new(:args, :opts)
    include Registry

    class << self
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
