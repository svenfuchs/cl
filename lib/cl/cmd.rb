require 'registry'
require 'cl/args'
require 'cl/helper'
require 'cl/opts'
# require 'cl/registry'

class Cl
  class Cmd
    include Registry

    class << self
      include Merge

      inherited = ->(const) do
        const.register [registry_key, underscore(const.name.split('::').last)].compact.join(':') if const.name
        const.define_singleton_method(:inherited, &inherited)
      end

      define_method(:inherited, &inherited)

      def cmds
        registry.values
      end

      def parse(ctx, args)
        opts = Parser.new(self.opts, args).opts unless self == Help
        opts = merge(ctx.config[registry_key], opts) if ctx.config[registry_key]
        [args, opts]
      end

      def abstract
        unregister
      end

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
        @opts ||= self == Cmd ? Opts.new : superclass.opts.dup
      end

      def defaults(defaults = nil)
        return @defaults = self.defaults.merge(defaults) if defaults
        @defaults ||= superclass < Cmd ? superclass.defaults.dup : {}
      end

      def default(name, value)
        defaults name => value
      end

      def underscore(string)
        string.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        downcase
      end
    end

    opt '--help', 'Get help on this command'

    attr_reader :ctx, :args

    def initialize(ctx, args)
      args, opts = self.class.parse(ctx, args)
      @ctx = ctx
      @opts = self.class.opts.apply(self, self.opts.merge(opts || {}))
      @args = @opts[:help] ? args : self.class.args.apply(self, args)
    end

    def opts
      @opts ||= {}
    end

    def deprecated_opts
      opts.keys & self.class.opts.deprecated
    end
  end
end
