module Cl
  class Format
    class Usage < Struct.new(:cmd)
      def format
        usage = [name]
        usage += cmd.args.map { |arg| "[#{arg}]" }
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
