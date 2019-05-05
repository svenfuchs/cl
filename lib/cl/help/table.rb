module Cl
  class Help
    class Table < Struct.new(:data)
      attr_reader :padding

      def format(padding = 8)
        @padding = padding
        rows.join("\n")
      end
      alias to_s format

      def rows
        data.map { |row| cells(row).join(' ').rstrip }
      end

      def cells(row)
        row.map.with_index { |cell, ix| cell.to_s.ljust(widths[ix]) }
      end

      def width
        widths = cols[0..-2].map { |col| col.max_by(&:size).size }.inject(&:+)
        widths + cols.size - 1
      end

      def widths
        cols.map.with_index do |col, ix|
          width = col.compact.max_by(&:size)&.size
          ix < cols.size - 2 ? width : width + padding.to_i
        end
      end

      def cols
        @cols ||= data.transpose
      end
    end
  end
end
