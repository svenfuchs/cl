require 'cl/cmd'
require 'cl/help'
require 'cl/runner'
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
    abort [e.message, help(args.first)].join("\n\n")
  end

  def runner(args)
    runner = :default if args.first.to_s == 'help'
    runner ||= opts[:runner] || :default
    Runner[runner].new(ctx, args)
  end

  def help(*args)
    runner(['help', *args]).cmd.help
  end
end
