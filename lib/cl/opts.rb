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
      opts = with_defaults(cmd, opts)
      opts = cast(opts)
      validate(cmd, opts) unless opts[:help]
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

      def validate(cmd, opts)
        validate_requireds(cmd, opts)
        validate_required(opts)
        validate_requires(opts)
        validate_max(opts)
        validate_format(opts)
        validate_enum(opts)
      end

      def validate_requireds(cmd, opts)
        opts = missing_requireds(cmd, opts)
        raise RequiredsOpts.new(opts) if opts.any?
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

      def validate_max(opts)
        opts = exceeding_max(opts)
        raise ExceedingMax.new(opts) if opts.any?
      end

      def validate_format(opts)
        opts = invalid_format(opts)
        raise InvalidFormat.new(opts) if opts.any?
      end

      def validate_enum(opts)
        opts = unknown_values(opts)
        raise UnknownValues.new(opts) if opts.any?
      end

      def missing_requireds(cmd, opts)
        opts = cmd.class.required.map do |alts|
          alts if alts.none? { |alt| Array(alt).all? { |key| opts.key?(key) } }
        end.compact
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

      def exceeding_max(opts)
        select(&:max?).map do |opt|
          [opt.name, opt.max] if opts[opt.name] > opt.max
        end.compact
      end

      def invalid_format(opts)
        select(&:format?).map do |opt|
          [opt.name, opt.format] unless opt.formatted?(opts[opt.name])
        end.compact
      end

      def unknown_values(opts)
        select(&:enum?).map do |opt|
          [opt.name, opts[opt.name], opt.enum] unless opt.known?(opts[opt.name])
        end.compact
      end

      def with_defaults(cmd, opts)
        select(&:default?).inject(opts) do |opts, opt|
          next opts if opts.key?(opt.name)
          value = opt.default
          value = resolve(cmd, opts, value) if value.is_a?(Symbol)
          opts.merge(opt.name => value)
        end
      end

      def resolve(cmd, opts, key)
        opts[key] || cmd.respond_to?(key) && cmd.send(key)
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
