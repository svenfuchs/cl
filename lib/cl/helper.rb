class Cl
  module Merge
    MERGE = ->(key, lft, rgt) do
      lft.is_a?(Hash) && rgt.is_a?(Hash) ? lft.merge(rgt, &MERGE) : rgt
    end

    def merge(*objs)
      objs.inject({}) { |lft, rgt| lft.merge(rgt, &MERGE) }
    end
  end

  module Regex
    def format_regex(str)
      return str unless str.is_a?(Regexp)
      "/#{str.to_s.sub('(?-mix:', '').sub(/\)$/, '')}/"
    end
  end

  module Wrap
    def wrap(str, opts = {})
      width = opts[:width] || 80
      str.lines.map do |line|
        line.size > width ? line.gsub(/(.{1,#{width}})(\s+|$)/, "\\1\n").strip : line
      end.join("\n")
    end
  end

  extend Merge, Regex, Wrap
end

if RUBY_VERSION == '2.0.0'
  Array.class_eval do
    def to_h
      Hash[self]
    end
  end
end
