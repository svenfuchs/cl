require 'cl/args'
require 'cl/registry'

module Cl
  ArgumentError = Class.new(::ArgumentError)

  class Cmd < Struct.new(:args, :opts)
    include Registry

    class << self
      def args(*args)
        return @args ||= Args.new unless args.any?
        opts = args.last.is_a?(Hash) ? args.pop : {}
        args.each { |arg| arg(arg, opts) }
      end

      def arg(name, opts = {})
        args.define(self, name, opts)
      end

      def purpose(purpose = nil)
        purpose ? @purpose = purpose : @purpose
      end

      def opt(*args, &block)
        opts << [args, block]
      end

      def opts
        @opts ||= superclass != Cmd && superclass.respond_to?(:opts) ? superclass.opts.dup : []
      end
    end

    def initialize(args, opts)
      args = self.class.args.apply(args)
      super
    end
  end
end
