class Cl
  class Help
    class Table
      include Wrap

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
        row.map.with_index do |cell, ix|
          indent(wrap(cell.to_s), widths[ix - 1]).ljust(widths[ix])
        end
      end

      def indent(str, width)
        return str if str.empty? || !width
        [str.lines[0], *str.lines[1..-1].map { |str| ' ' * (width + 1) + str }].join.rstrip
      end

      def width
        widths = cols[0..-2].map { |col| col.max_by(&:size).size }.inject(&:+).to_i
        widths + cols.size - 1
      end

      def widths
        cols.map.with_index do |col, ix|
          max = col.compact.max_by(&:size)
          width = max ? max.size : 0
          ix < cols.size - 2 ? width : width + padding.to_i
        end
      end

      def cols
        @cols ||= data.transpose
      end
    end
  end
end
