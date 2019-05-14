require 'fileutils'
require 'yaml'

module Support
  module File
    def self.included(base)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods
      def file(*args)
        before { write(*args) }
      end

      def yaml(obj)
        YAML.dump(obj)
      end
    end

    # memfs does not support File.write?
    def write(path, content)
      path = ::File.expand_path(path)
      FileUtils.mkdir_p(::File.dirname(path))
      ::File.open(path, 'w+') { |f| f.write(content) }
    end

    def yaml(obj)
      YAML.dump(obj)
    end
  end
end
