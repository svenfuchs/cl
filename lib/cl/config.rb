require 'cl/config/env'
require 'cl/config/files'
require 'cl/helper'

class Cl
  class Config
    include Merge

    attr_reader :name, :opts

    def initialize(name)
      @name = name
      @opts = load
    end

    def to_h
      opts
    end

    private

      def load
        merge(*sources.map(&:load))
      end

      def sources
        [Files.new(name), Env.new(name)]
      end
  end
end
