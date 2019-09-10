require 'cl/helper'

class Cl
  class Cmd
    module Dsl
      include Merge, Underscore

      def abstract
        unregister
        @abstract = true
      end

      def abstract?
        !!@abstract
      end

      # Declare multiple arguments at once
      #
      # See {Cl::Cmd::Dsl#arg} for more details.
      def args(*args)
        return @args ||= Args.new unless args.any?
        opts = args.last.is_a?(Hash) ? args.pop : {}
        args.each { |arg| arg(arg, opts) }
      end

      # Declares an argument
      #
      # Use this method to declare arguments the command accepts.
      #
      # For example:
      #
      #   ```ruby
      #   class GitPush < Cl::Cmd
      #     arg remote, 'The Git remote to push to.', type: :string
      #   end
      #   ```
      #
      # Arguments do not need to be declared, in order to be passed to the Cmd
      # instance, but it is useful to do so for more explicit help output, and
      # in order to define extra properties on the arguments (e.g. their type).
      #
      # @overload arg(name, description, opts)
      #   @param name [String] the argument name
      #   @param description [String] description for the argument, shown in the help output
      #   @param opts [Hash] argument options
      #   @option opts [Symbol] :type the argument type (`:array`, `:string`, `:integer`, `:float`, `:boolean`)
      #   @option opts [Boolean] :required whether the argument is required
      #   @option opts [String] :sep separator to split strings by, if the argument is an array
      #   @option opts [Boolean] :splat whether to splat the argument, if the argument is an array
      def arg(*args)
        self.args.define(self, *args)
      end

      # Declare a description for this command
      #
      # This is the description that will be shown in the command details help output.
      #
      # For example:
      #
      #   ```ruby
      #   class Api::Login < Cl::Cmd
      #     description <<~str
      #       Use this command to login to our API.
      #       [...]
      #     str
      #   end
      #   ```
      #
      # @return [String] the description if no argument was given
      def description(description = nil)
        description ? @description = description : @description
      end

      # Declare an example text for this command
      #
      # This is the example text that will be shown in the command details help output.
      #
      # For example:
      #
      #   ```ruby
      #   class Api::Login < Cl::Cmd
      #     example <<~str
      #       For example, in order to login to our API with your username and
      #       password, you can use:
      #
      #         ./api --username [username] --password [password]
      #     str
      #   end
      #   ```
      #
      # @return [String] the description if no argument was given
      def examples(examples = nil)
        examples ? @examples = examples : @examples
      end

      # Declares an option
      #
      # Use this method to declare options a command accepts.
      #
      # See [this section](/#Options) for a full explanation on each feature supported by command options.
      #
      # @overload opt(name, description, opts)
      #   @param name [String] the option name
      #   @param description [String] description for the option, shown in the help output
      #   @param opts [Hash] option options
      #   @option opts [Symbol or Array<Symbol>] :alias alias name(s) for the option
      #   @option opts [Object] :default default value for the option
      #   @option opts [String or Symbol] :deprecated deprecation message for the option, or if given a Symbol, deprecated alias name
      #   @option opts [Boolean] :downcase whether to downcase the option value
      #   @option opts [Boolean] :upcase whether to upcase the option value
      #   @option opts [Array<Object>] :enum list of acceptable option values
      #   @option opts [String] :example example(s) for the option, shown in help output
      #   @option opts [Regexp] :format acceptable option value format
      #   @option opts [Boolean] :internal whether to hide the option from help output
      #   @option opts [Numeric] :min minimum acceptable value
      #   @option opts [Numeric] :max maximum acceptable value
      #   @option opts [String] :see see also reference (e.g. documentation URL)
      #   @option opts [Symbol] :type the option value type (`:array`, `:string`, `:integer`, `:float`, `:boolean`)
      #   @option opts [Boolean] :required whether the option is required
      #   @option opts [Array<Symbol> or Symbol] :requires (an)other options required this option depends on
      def opt(*args, &block)
        self.opts.define(self, *args, &block)
      end

      # Collection of options supported by this command
      #
      # This collection is being inherited from super classes.
      def opts
        @opts ||= self == Cmd ? Opts.new : superclass.opts.dup
      end

      # Whether any alternative option requirements have been declared.
      #
      # See [this section](/#Required_Options) for a full explanation of how
      # alternative option requirements can be used.
      def required?
        !!@required
      end

      # Declare alternative option requirements.
      #
      # Alternative (combinations of) options can be required. These need to be declared on the class body.
      #
      # For example,
      #
      #   ```ruby
      #   class Api::Login < Cl::Cmd
      #     # DNF, read as: api_key OR username AND password
      #     required :api_key, [:username, :password]
      #
      #     opt '--api_key KEY'
      #     opt '--username NAME'
      #     opt '--password PASS'
      #   end
      #   ```
      # Will require either the option `api_key`, or both the options `username` and `password`.
      #
      # See [this section](/#Required_Options) for a full explanation of how
      # alternative option requirements can be used.
      def required(*required)
        required.any? ? self.required << required : @required ||= []
      end

      # Declare a summary for this command
      #
      # This is the summary that will be shown in both the command list, and command details help output.
      #
      # For example:
      #
      #   ```ruby
      #   class Api::Login < Cl::Cmd
      #     summary 'Login to the API'
      #   end
      #   ```
      #
      # @return [String] the summary if no argument was given
      def summary(summary = nil)
        summary ? @summary = summary : @summary
      end
    end
  end
end
