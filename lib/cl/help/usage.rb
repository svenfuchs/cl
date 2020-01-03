class Cl
  class Help
    class Usage < Struct.new(:ctx, :cmd)
      def format
        cmd.registry_keys.map do |key|
          line(key)
        end
      end

      def line(key)
        usage = [executable, key.to_s.gsub(':', ' ')]
        usage += cmd.args.map(&:to_s) # { |arg| "[#{arg}]" }
        usage << '[options]' if opts?
        usage.join(' ')
      end

      def executable
        ctx.name
      end

      def opts?
        cmd.opts.any?
      end
    end
  end
end
