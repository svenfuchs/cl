require 'cl/options'

module Cl
  class Cmds < Struct.new(:args)
    def lookup
      cmd || abort("Unknown command: #{args.join(' ')}")
      opts = Options.new(cmd.opts, args).opts
      [cmd, args - cmds, opts]
    end

    private

      def cmds
        name = cmd.registry_key.to_s
        args.take_while do |arg|
          name = name.sub(/#{arg}(:|$)/, '') if name =~ /#{arg}(:|$)/
        end
      end

      def cmd
        @cmd ||= keys.map { |key| Cl[key] }.compact.last
      end

      def keys
        @keys ||= args.inject([]) { |keys, key| keys << [keys.last, key].compact.join(':') }
      end
  end
end
