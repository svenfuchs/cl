require 'forwardable'
require 'cl/ctx'
require 'cl/helper'

class Cl
  module Runner
    class Default
      Runner.register :default, self

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

        # Stopping at any arg that starts with a dash, find the command
        # with the key matching the most args when joined with ":", and
        # remove these used args from the array
        def lookup(args)
          keys = args.take_while { |key| !key.start_with?('-') }

          keys = keys.inject([[], []]) do |keys, key|
            keys[1] << key
            keys[0] << [Cmd[keys[1].join(':')], keys[1].dup] if Cmd.registered?(keys[1].join(':'))
            keys
          end

          cmd, keys = keys[0].last
          cmd || raise(Error.new(:unknown_cmd, args.join(' ')))
          keys.each { |key| args.delete_at(args.index(key)) }
          [cmd, args]
        end
    end
  end
end
