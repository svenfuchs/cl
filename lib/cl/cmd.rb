require 'registry'
require 'cl'
require 'cl/args'
require 'cl/dsl'
require 'cl/opts'
require 'cl/parser'

class Cl
  # Base class for all command classes that can be run.
  #
  # Inherit your command classes from this class, use the {Cl::Cmd::Dsl} to
  # declare arguments, options, summary, description, examples etc., and
  # implement the method #run.
  #
  # See {Cl::Cmd::Dsl} for details on the DSL methods.
  class Cmd
    include Registry
    extend Dsl

    class << self
      include Merge, Suggest, Underscore

      attr_accessor :auto_register

      inherited = ->(const) do
        if const.name && Cmd.auto_register
          key = underscore(const.name.split('::').last)
          key = [registry_key, key].compact.join(':') unless abstract?
          const.register(key)
        end
        const.define_singleton_method(:inherited, &inherited)
      end
      define_method(:inherited, &inherited)

      def cmds
        registry.values.uniq
      end

      def parse(ctx, cmd, args)
        parser = Parser.new(cmd, args)
        args, opts = parser.args, parser.opts unless self == Help
        opts = merge(ctx.config[registry_key], opts) if ctx.config[registry_key]
        [args, opts || {}]
      end

      def suggestions(opt)
        suggest(opts.map(&:name), opt.sub(/^--/, ''))
      end
    end

    self.auto_register = true

    abstract

    opt '--help', 'Get help on this command'

    attr_reader :ctx, :args

    def initialize(ctx, args)
      @ctx = ctx
      args, opts = self.class.parse(ctx, self, args)
      @opts = self.class.opts.apply(self, self.opts.merge(opts))
      @args = self.class.args.apply(self, args, opts) unless help? && !is_a?(Help)
    end

    def opts
      @opts ||= {}
    end

    def deprecations
      @deprecations ||= {}
    end
  end
end
