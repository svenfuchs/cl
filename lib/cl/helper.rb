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

  extend Merge, Regex
end
