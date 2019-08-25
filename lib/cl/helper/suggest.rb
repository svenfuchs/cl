class Cl
  module Suggest
    include DidYouMean if defined?(DidYouMean)

    def suggest(dict, value)
      return [] unless defined?(DidYouMean)
      Array(value).map do |value|
        SpellChecker.new(dictionary: dict.map(&:to_s)).correct(value.to_s)
      end.flatten
    end
  end
end
