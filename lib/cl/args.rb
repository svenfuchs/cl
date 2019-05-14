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

    def apply(cmd, args, opts)
      return args if self.args.empty? || opts[:help]
      args = grouped(args)
      validate(args)
      args.map { |(arg, value)| arg.set(cmd, value) }.flatten(1)
    end

    def each(&block)
      args.each(&block)
    end

    def index(*args, &block)
      self.args.index(*args, &block)
    end

    def args
      @args ||= []
    end

    private

      def validate(args)
        raise ArgumentError.new(:missing_args, args.size, required) if args.size < required
        raise ArgumentError.new(:too_many_args, args.size, allowed) if args.size > allowed && !splat?
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

      def grouped(values)
        values.inject([0, {}]) do |(ix, group), value|
          arg = args[ix]
          if arg && arg.splat?
            group[arg] ||= []
            group[arg] << value
            ix += 1 if args.size + group[arg].size > values.size
          else
            group[arg] = value
            ix += 1
          end
          [ix, group]
        end.last
      end
  end
end
