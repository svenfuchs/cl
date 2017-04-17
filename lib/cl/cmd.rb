require 'cl/args'
require 'cl/registry'

module Cl
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

      def cmd(description = nil)
        @description = description
      end

      attr_reader :description

      def opt(*args, &block)
        opts << [args, block]
      end

      def opts
        @opts ||= superclass != Cmd && superclass.respond_to?(:opts) ? superclass.opts.dup : []
      end
    end

    def initialize(args, opts)
      args = self.class.args.apply(self, args)
      opts = self.class::OPTS.merge(opts) if self.class.const_defined?(:OPTS)
      super
    end
  end
end
