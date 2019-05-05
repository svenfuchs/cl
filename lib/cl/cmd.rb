require 'cl/args'
require 'cl/registry'

module Cl
  class Opt < Struct.new(:strs, :description, :opts, :block)
    def type
      strs.any? { |str| str.split(' ').size > 1 } ? :string : :boolean
    end

    def required?
      !!opts[:required]
    end
  end

  class Cmd < Struct.new(:args, :opts)
    include Registry

    class << self
      inherited = ->(const) do
        const.register [registry_key, underscore(const.name.split('::').last)].compact.join(':') if const.name
        const.define_singleton_method(:inherited, &inherited)
      end

      define_method(:inherited, &inherited)

      def summary(summary = nil)
        summary ? @summary = summary : @summary
      end
      alias purpose summary

      def description(description = nil)
        description ? @description = description : @description
      end

      def args(*args)
        return @args ||= Args.new unless args.any?
        opts = args.last.is_a?(Hash) ? args.pop : {}
        args.each { |arg| arg(arg, opts) }
      end

      def arg(name, *args)
        opts = args.last.is_a?(Hash) ? args.pop : {}
        opts[:description] = args.shift
        self.args.define(self, name, opts)
      end

      def opt(*args, &block)
        opts = args.last.is_a?(Hash) ? args.pop : {}
        strs = args.select { |arg| arg.start_with?('-') }
        desc = args.-(strs).first
        self.opts << Opt.new(strs, desc, opts, block)
      end

      def opts
        @opts ||= superclass != Cmd && superclass.respond_to?(:opts) ? superclass.opts.dup : []
      end

      def underscore(string)
        string.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        downcase
      end
    end

    def initialize(args, opts)
      args = self.class.args.apply(self, args)
      opts = self.class::OPTS.merge(opts) if self.class.const_defined?(:OPTS)
      super
    end

    def name
      registry_key
    end
  end
end
