class Cl
  class Help
    class Usage < Struct.new(:ctx, :cmd)
      def format
        usage = [executable, name]
        usage += cmd.args.map(&:to_s) # { |arg| "[#{arg}]" }
        usage << '[options]' if opts?
        usage.join(' ')
      end

      def executable
        ctx.name
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
