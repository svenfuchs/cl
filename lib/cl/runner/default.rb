require 'forwardable'
require 'cl/ctx'
require 'cl/parser'
require 'cl/helper'

class Cl
  module Runner
    class Default
      extend Forwardable
      include Merge

      def_delegators :ctx, :config, :abort

      attr_reader :ctx, :const, :args, :opts

      def initialize(ctx, args)
        @ctx = ctx
        @const, args = lookup(args)
        @opts, @args = parse(args)
      end

      def run
        cmd.help? ? help.run : cmd.run
      end

      def cmd
        @cmd ||= const.new(ctx, args, opts)
      end

      def help
        Help.new(ctx, [cmd.registry_key], opts)
      end

      private

        def lookup(args)
          keys = expand(args) & Cl.registry.keys.map(&:to_s)
          cmd = Cl[keys.last] || abort("Unknown command: #{args.join(' ')}")
          [cmd, args - keys(cmd)]
        end

        def parse(args)
          opts = Parser.new(const.opts, args).opts unless const == Help
          opts = merge(config[name], opts) if config[name]
          [opts, args]
        end

        def name
          const.registry_key
        end

        def keys(cmd)
          keys = cmd.registry_key.to_s.split(':')
          keys.concat(expand(keys)).uniq
        end

        def expand(strs)
          strs = strs.reject { |str| str.start_with?('-') }
          strs.inject([]) { |strs, str| strs << [strs.last, str].compact.join(':') }
        end
    end
  end
end
