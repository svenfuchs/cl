require 'cl/cmd'
require 'cl/help'
require 'cl/runner/default'
require 'cl/runner/multi'

class Cl
  class Error < StandardError
    MSGS = {
      missing_args:  'Missing arguments (given: %s, required: %s)',
      too_many_args: 'Too many arguments (given: %s, allowed: %s)',
      wrong_type:    'Wrong argument type (given: %s, expected: %s)',
      missing_opt:   'Missing required option --%s',
    }

    def initialize(msg, *args)
      super(MSGS[msg] ? MSGS[msg] % args : msg)
    end
  end

  ArgumentError = Class.new(Error)
  OptionError = Class.new(Error)

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
    abort [e.message, runner(:help, *args).cmd.help].join("\n\n")
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
