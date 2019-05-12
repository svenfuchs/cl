require 'cl/opt'

class Cl
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
      opts = with_defaults(cmd, opts) if cmd.class.defaults
      opts = cast(opts)
      validate(opts)
      opts
    end

    def <<(opt)
      # keep the --help option at the end for help output
      opts.empty? ? opts << opt : opts.insert(-2, opt)
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

    def deprecated
      map(&:deprecated).flatten.compact
    end

    def dup
      super.tap { |obj| obj.opts = opts.dup }
    end

    private

      def validate(opts)
        validate_required(opts)
        validate_requires(opts)
      end

      def validate_required(opts)
        opts = missing_required(opts)
        # make sure we do not accept unnamed required options
        raise RequiredOpts.new(opts.map(&:name)) if opts.any?
      end

      def validate_requires(opts)
        opts = missing_requires(opts)
        raise RequiresOpts.new(invert(opts)) if opts.any?
      end

      def missing_required(opts)
        select(&:required?).select { |opt| !opts.key?(opt.name) }
      end

      def missing_requires(opts)
        select(&:requires?).map do |opt|
          missing = opt.requires.select { |key| !opts.key?(key) }
          [opt.name, missing] if missing.any?
        end.compact
      end

      def with_defaults(cmd, opts)
        cmd.class.defaults.inject(opts) do |opts, (key, value)|
          next opts if opts.key?(key)
          value = opts[value] || cmd.send(value) if value.is_a?(Symbol)
          opts[key] = value
          opts
        end
      end

      def cast(opts)
        opts.map do |key, value|
          [key, self[key] ? self[key].cast(value) : value]
        end.to_h
      end

      def invert(hash)
        hash.map { |key, obj| Array(obj).map { |obj| [obj, key] } }.flatten(1).to_h
      end
  end
end
