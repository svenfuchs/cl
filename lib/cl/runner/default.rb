require 'forwardable'
require 'cl/ctx'
require 'cl/helper'

class Cl
  module Runner
    class Default
      extend Forwardable
      include Merge

      def_delegators :ctx, :abort

      attr_reader :ctx, :const, :args, :opts

      def initialize(ctx, args)
        @ctx = ctx
        @const, @args = lookup(args)
      end

      def run
        cmd.help? ? help.run : cmd.run
      end

      def cmd
        @cmd ||= const.new(ctx, args)
      end

      def help
        Help.new(ctx, [cmd.registry_key])
      end

      private

        def lookup(args)
          keys = expand(args)
          keys = keys & Cmd.registry.keys.map(&:to_s)
          cmd  = Cmd[keys.last] || abort("Unknown command: #{args.join(' ')}")
          args = args[keys.last.split(':').size..-1]
          [cmd, args]
        end

        def expand(args)
          keys = args.take_while { |str| !str.start_with?('-') }
          args = args[keys.size..-1]
          keys.inject([]) { |strs, str| strs << [strs.last, str].compact.join(':') }
        end
    end
  end
end
