require 'cl/opt'

module Cl
  class Opts
    include Enumerable

    def define(const, *args, &block)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      strs = args.select { |arg| arg.start_with?('-') }
      opts[:description] = args.-(strs).first

      opt = Opt.new(strs, opts, block)
      opt.define(const)
      self << opt
    end

    def apply(cmd, opts)
      opts = cmd.class.defaults.merge(opts)
      opts = cast(opts)
      validate(opts)
      opts
    end

    def <<(opt)
      opts.empty? ? opts << opt : opts.insert(-2, opt) # keep the --help option at the end
    end

    def [](key)
      opts.detect { |opt| opt.name == key }
    end

    def each(&block)
      opts.each(&block)
    end

    def to_a
      opts
    end

    attr_writer :opts

    def opts
      @opts ||= []
    end

    def dup
      super.tap { |obj| obj.opts = opts.dup }
    end

    private

      # make sure we do not accept unnamed required options
      def validate(opts)
        return unless opt = required.detect { |opt| !opts.key?(opt.name) }
        raise OptionError.new(:missing_opt, opt.name)
      end

      def cast(opts)
        opts.map do |key, value|
          [key, self[key] ? self[key].cast(value) : value]
        end.to_h
      end

      def required
        select(&:required?)
      end
  end
end
