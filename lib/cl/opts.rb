require 'cl/opt'
require 'cl/opts/validate'

class Cl
  class Opts
    include Enumerable, Validate

    def define(const, *args, &block)
      opts = args.last.is_a?(Hash) ? args.pop : {}
      strs = args.select { |arg| arg.start_with?('-') }
      opts[:description] = args.-(strs).first

      opt = Opt.new(strs, opts, block)
      opt.define(const)
      self << opt
    end

    def apply(cmd, opts)
      return opts if opts[:help]
      cmd.deprecations = deprecations(cmd, opts)
      opts = with_defaults(cmd, opts)
      opts = downcase(opts)
      opts = cast(opts)
      opts = taint(opts)
      validate(cmd, self, opts)
      opts
    end

    def <<(opt)
      delete(opt)
      # keep the --help option at the end for help output
      opts.empty? ? opts << opt : opts.insert(-2, opt)
    end

    def [](key)
      opts.detect { |opt| opt.name == key }
    end

    def each(&block)
      opts.each(&block)
    end

    def delete(opt)
      opts.delete(opts.detect { |o| o.strs == opt.strs })
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

      def deprecations(cmd, opts)
        defs = cmd.class.opts.select(&:deprecated?)
        defs = defs.select { |opt| opts.key?(opt.deprecated[0]) }
        defs.map(&:deprecated).to_h
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

      def downcase(opts)
        select(&:downcase?).inject(opts) do |opts, opt|
          next opts unless value = opts[opt.name]
          opts.merge(opt.name => value.to_s.downcase)
        end
      end

      def cast(opts)
        opts.map do |key, value|
          [key, self[key] ? self[key].cast(value) : value]
        end.to_h
      end

      def taint(opts)
        opts.map do |key, value|
          [key, self[key] && self[key].secret? ? value.taint : value]
        end.to_h
      end
  end
end
