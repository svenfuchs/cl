class Cl
  module Merge
    MERGE = ->(key, lft, rgt) do
      lft.is_a?(Hash) && rgt.is_a?(Hash) ? lft.merge(rgt, &MERGE) : rgt
    end

    def merge(*objs)
      objs.inject({}) { |lft, rgt| lft.merge(rgt, &MERGE) }
    end
  end
end
