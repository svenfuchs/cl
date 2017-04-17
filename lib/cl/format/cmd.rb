require 'cl/format/table'
require 'cl/format/usage'

module Cl
  class Format
    class Cmd < Struct.new(:cmd)
      def format
        [banner, Table.new(opts).format].join("\n")
      end

      def banner
        banner = []
        banner << "#{cmd.description}\n" if cmd.description
        banner << "Usage: #{Usage.new(cmd).format}\n"
        banner
      end

      def opts
        cmd.opts.map do |opts, block|
          comment = opts.detect { |opt| !opt?(opt) }
          opts = opts.select { |opt| opt?(opt) }
          [opts.sort_by(&:size).join(' '), comment]
        end
      end

      def opt?(str)
        str.start_with?('-')
      end
    end
  end
end
