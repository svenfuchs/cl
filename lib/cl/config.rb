require 'cl/config/env'
require 'cl/config/files'

class Cl
  class Config
    attr_reader :name, :opts

    def initialize(name)
      @name = name
      @opts = load
    end

    def [](key)
      opts[key]
    end

    def for(key)
      common.merge(self[key] || {})
    end

    def common
      opts.reject { |_, value| value.is_a?(Hash) }
    end

    private

      def load
        sources.map(&:load).inject(&:merge)
      end

      def sources
        [Env.new(name), Files.new(name)]
      end
  end
end
