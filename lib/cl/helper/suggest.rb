class Cl
  module Suggest
    def suggest(dict, value)
      return [] unless defined?(DidYouMean::SpellChecker)
      Array(value).map do |value|
        DidYouMean::SpellChecker.new(dictionary: dict.map(&:to_s)).correct(value.to_s)
      end.flatten
    end
  end
end
