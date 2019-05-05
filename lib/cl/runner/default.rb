require 'cl/ctx'
require 'cl/parser'

class Cl
  module Runner
    class Default
      attr_reader :ctx, :const, :args, :opts

      def initialize(ctx, *args)
        @ctx = ctx
        @const, @args, @opts = lookup(args.flatten.map(&:to_s))
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
          cmd = keys_for(args).map { |key| Cl[key] }.compact.last
          cmd || abort("Unknown command: #{args.join(' ')}")
          opts = Parser.new(cmd.opts, args).opts unless cmd == Help
          [cmd, args - cmds_for(cmd, args), opts]
        end

        def cmds_for(cmd, args)
          name = cmd.registry_key.to_s
          args.take_while do |arg|
            # ???
            name = name.sub(/#{arg}(:|$)/, '') if name =~ /#{arg}(:|$)/
          end
        end

        def keys_for(args)
          args.inject([]) { |keys, key| keys << [keys.last, key].compact.join(':') }
        end

        def abort(msg)
          ctx.abort(msg)
        end
    end
  end
end
