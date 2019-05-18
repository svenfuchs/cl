require 'cl/cmd'
require 'cl/help'
require 'cl/runner/default'
require 'cl/runner/multi'
require 'cl/errors'

class Cl
  attr_reader :ctx, :name, :opts

  def initialize(*args)
    ctx   = args.shift if args.first.is_a?(Ctx)
    @opts = args.last.is_a?(Hash) ? args.pop : {}
    @name = args.shift || $0
    @ctx  = ctx || Ctx.new(name, opts)
  end

  def run(args)
    runner(args.map(&:dup)).run
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
