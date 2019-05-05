module Cl
  class Help
    class Usage < Struct.new(:cmd)
      def format
        usage = [$0.split('/').last, name]
        usage += cmd.args.map(&:to_s) # { |arg| "[#{arg}]" }
        usage << '[options]' if opts?
        usage.join(' ')
      end

      def name
        cmd.registry_key.to_s.gsub(':', ' ')
      end

      def opts?
        cmd.opts.any?
      end
    end
  end
end
