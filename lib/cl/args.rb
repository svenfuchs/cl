require 'cl/arg'

class Cl
  class Args
    include Enumerable

    def define(const, name, *args)
      opts = args.last.is_a?(Hash) ? args.pop.dup : {}
      opts[:description] = args.shift if args.any?

      arg = Arg.new(name, opts)
      arg.define(const)
      self.args << arg
    end

    def apply(cmd, values, opts)
      values = splat(values) if splat?
      validate(values)
      return values if args.empty?
      args.zip(values).map { |(arg, value)| arg.set(cmd, value) }.flatten(1).compact
    end

    def each(&block)
      args.each(&block)
    end

    def index(*args, &block)
      self.args.index(*args, &block)
    end

    attr_writer :args

    def args
      @args ||= []
    end

    def clear
      args.clear
    end

    def dup
      args = super
      args.args = args.args.dup
      args
    end

    private

      def validate(args)
        # raise ArgumentError.new(:unknown_arg, arg) if unknown?(arg)
        raise ArgumentError.new(:missing_args, args.size, required) if args.size < required
        raise ArgumentError.new(:too_many_args, args.join(' '), args.size, allowed) if args.size > allowed && !splat?
      end

      def allowed
        args.size
      end

      def splat?
        any?(&:splat?)
      end

      def required
        select(&:required?).size
      end

      def splat(values)
        args.each.with_index.inject([]) do |group, (arg, ix)|
          count = arg && arg.splat? ? [values.size - args.size + ix + 1] : []
          group << values.shift(*count)
        end
      end
  end
end
