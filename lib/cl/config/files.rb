require 'yaml'
require 'cl/helper'

class Cl
  class Config
    class Files < Struct.new(:name)
      include Merge

      PATHS = %w(
        ~/.%s.yml
        ./.%s.yml
      )

      def load
        configs.any? ? symbolize(merge(*configs)) : {}
      end

      private

        def configs
          @configs ||= paths.map { |path| YAML.load_file(path) || {} }
        end

        def paths
          paths = PATHS.map { |path| File.expand_path(path % name) }
          paths.select { |path| File.exist?(path) }
        end

        def symbolize(hash, first_pass = true)
          hash.map { |key, value|
            [key.to_sym, (first_pass && value.is_a?(Hash)) ? symbolize(value, false) : value]
          }.to_h
        end
    end
  end
end
