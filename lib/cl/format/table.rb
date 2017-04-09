module Cl
  class Format
    class Table < Struct.new(:data, :separator)
      def format
        rows.join("\n")
      end

      def rows
        rows = data.map { |lft, rgt| [lft.ljust(width), rgt] }
        rows = rows.map { |lft, rgt| "#{lft} #{"# #{rgt}" if rgt}".strip }
        rows.map(&:strip)
      end

      def width
        @width ||= data.map(&:first).max_by(&:size).size
      end
    end
  end
end
