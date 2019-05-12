class Cl
  class Help
    class Table
      attr_reader :data, :padding

      def initialize(data)
        @data = data
      end

      def any?
        data.any?
      end

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
        widths = cols[0..-2].map { |col| col.max_by(&:size).size }.inject(&:+).to_i
        widths + cols.size - 1
      end

      def widths
        cols.map.with_index do |col, ix|
          width = col.compact.max_by(&:size)&.size
          ix < cols.size - 2 ? width.to_i : width.to_i + padding.to_i
        end
      end

      def cols
        @cols ||= data.transpose
      end
    end
  end
end
