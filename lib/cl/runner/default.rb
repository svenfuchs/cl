require 'cl/options'

module Cl
  module Runner
    class Default
      attr_reader :const, :args, :opts

      def initialize(*args)
        args = args.flatten.map(&:to_s)
        @const, @args, @opts = lookup(args)
      end

      def run
        cmd.run
      end

      def cmd
        const.new(args, opts)
      end

      private

        def lookup(args)
          cmd = keys_for(args).map { |key| Cl[key] }.compact.last
          cmd || abort("Unknown command: #{args.join(' ')}")
          opts = Options.new(cmd.opts, args).opts
          [cmd, args - cmds_for(cmd, args), opts]
        end

        def cmds_for(cmd, args)
          name = cmd.registry_key.to_s
          args.take_while do |arg|
            name = name.sub(/#{arg}(:|$)/, '') if name =~ /#{arg}(:|$)/
          end
        end

        def keys_for(args)
          args.inject([]) { |keys, key| keys << [keys.last, key].compact.join(':') }
        end
    end
  end
end
