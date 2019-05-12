require 'cl/cmd'
require 'cl/help'
require 'cl/runner/default'
require 'cl/runner/multi'

class Cl
  class Error < StandardError
    MSGS = {
      missing_args:   'Missing arguments (given: %s, required: %s)',
      too_many_args:  'Too many arguments (given: %s, allowed: %s)',
      wrong_type:     'Wrong argument type (given: %s, expected: %s)',
      exceeding_max:  'Exceeds max value: %s',
      invalid_format: 'Invalid format: %s',
      unknown_values: 'Unknown value: %s',
      required_opt:   'Missing required option: %s',
      required_opts:  'Missing required options: %s',
      requires_opt:   'Missing option: %s',
      requires_opts:  'Missing options: %s',
    }

    def initialize(msg, *args)
      super(MSGS[msg] ? MSGS[msg] % args : msg)
    end
  end

  ArgumentError = Class.new(Error)
  OptionError = Class.new(Error)
  RequiredOpts = Class.new(OptionError)

  class RequiresOpts < OptionError
    def initialize(opts)
      msg = opts.size == 1 ? :requires_opt : :requires_opts
      opts = opts.map { |one, other| "#{one} (required by #{other})" }.join(', ')
      super(msg, opts)
    end
  end

  class ExceedingMax < OptionError
    def initialize(opts)
      opts = opts.map { |opt, max| "#{opt} (max: #{max})" }.join(', ')
      super(:exceeding_max, opts)
    end
  end

  class InvalidFormat < OptionError
    def initialize(opts)
      opts = opts.map { |opt, format| "#{opt} (format: #{format})" }.join(', ')
      super(:invalid_format, opts)
    end
  end

  class UnknownValues < OptionError
    def initialize(opts)
      opts = opts.map { |(key, value, known)| "#{key}=#{value} (known values: #{known.join(', ')})" }.join(', ')
      super(:unknown_values, opts)
    end
  end

  attr_reader :ctx, :name, :opts

  def initialize(*args)
    ctx   = args.shift if args.first.is_a?(Ctx)
    @opts = args.last.is_a?(Hash) ? args.pop : {}
    @name = args.shift || $0
    @ctx  = ctx || Ctx.new(name, opts)
  end

  def run(args)
    runner(args).run
  rescue Error => e
    abort [e.message, runner(['help', args.first]).cmd.help].join("\n\n")
  end

  def runner(args)
    runner = :default if args.first.to_s == 'help'
    runner ||= opts[:runner] || :default
    Runner.const_get(runner.to_s.capitalize).new(ctx, args)
  end

  # def help(*args)
  #   runner(:help, *args).run
  # end
end
