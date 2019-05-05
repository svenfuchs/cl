require 'cl/args'
require 'cl/opts'
require 'cl/registry'

module Cl
  class Cmd < Struct.new(:ctx, :args, :opts)
    include Registry

    class << self
      inherited = ->(const) do
        const.register [registry_key, underscore(const.name.split('::').last)].compact.join(':') if const.name
        const.define_singleton_method(:inherited, &inherited)
      end

      define_method(:inherited, &inherited)

      def summary(summary = nil)
        summary ? @summary = summary : @summary
      end
      alias purpose summary

      def description(description = nil)
        description ? @description = description : @description
      end

      def args(*args)
        return @args ||= Args.new unless args.any?
        opts = args.last.is_a?(Hash) ? args.pop : {}
        args.each { |arg| arg(arg, opts) }
      end

      def arg(*args)
        self.args.define(self, *args)
      end

      def opt(*args, &block)
        self.opts.define(self, *args, &block)
      end

      def opts
        @opts ||= superclass < Cmd ? superclass.opts.dup : Opts.new
      end

      def underscore(string)
        string.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        downcase
      end
    end

    def initialize(ctx, args, opts)
      args = self.class.args.apply(self, args)
      opts = self.class.opts.apply(self, opts || {})
      super
    end

    def name
      registry_key
    end
  end
end
