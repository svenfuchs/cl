require 'cl/cmd'
require 'cl/help'
require 'cl/runner'
require 'cl/errors'

class Cl
  attr_reader :ctx, :name, :opts

  # @overload initialize(ctx, name, opts)
  #   @param ctx  [Cl::Ctx] the current execution context (optional)
  #   @param name [String] the program (executable) name (optional, defaults to the last segment of $0)
  #   @param opts [Hash] options (optional)
  #   @option opts [Cl::Runner] :runner registry key for a runner (optional, defaults to :default)
  #   @option opts [Cl::Ui] :ui the ui for handling user interaction
  def initialize(*args)
    ctx   = args.shift if args.first.is_a?(Ctx)
    @opts = args.last.is_a?(Hash) ? args.pop : {}
    @name = args.shift || $0.split('/').last
    @ctx  = ctx || Ctx.new(name, opts)
  end

  # Runs the command.
  #
  # Instantiates a runner with the given arguments, and runs it.
  #
  # If the command fails (raises a Cl::Error) then the exception is caught, and
  # the process aborted with the error message and help output for the given
  # command.
  #
  # @param args [Array<String>] arguments (usually ARGV)
  def run(args)
    runner(untaint(args)).run
  rescue UnknownCmd => e
    ctx.abort e
  rescue Error => e
    ctx.abort e, help(args.first)
  end

  # Returns a runner instance for the given arguments.
  def runner(args)
    runner = :default if args.first.to_s == 'help'
    runner ||= opts[:runner] || :default
    Runner[runner].new(ctx, args)
  end

  # Returns help output for the given command
  def help(*args)
    runner(['help', *args]).cmd.help
  rescue
  end

  private

    # Tainting is being used for identifying values on options that have
    # been declared as secret. Ruby taints incoming arguments, so we want to
    # untaint them here.
    def untaint(args)
      args.map(&:dup).each(&:untaint)
    end
end
