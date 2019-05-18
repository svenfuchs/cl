# Cl [![Build Status](https://travis-ci.org/svenfuchs/cl.svg?branch=master)](https://travis-ci.org/svenfuchs/cl)

This library wraps Ruby's `OptionParser` in order to make it easier to use it
in an object oriented context.

It uses `OptionParser` for parsing your options, so you get all the goodness that
this gem from Ruby's stoneage provides.

But on top of that it also provides a rich DSL for defining, validating, and
normalizing options, as well as automatic and gorgeous help output (modeled
after Rubygem's `gem --help` output).

## Table of Contents

* [Basic Usage](#basic-usage)
* [Command Registry](#command-registry)
* [Runners](#runners)
* [Command DSL](#command-dsl)
  * [Description, Summary, Examples](#description-summary-examples)
  * [Arguments](#arguments)
    * [Types](#types)
    * [Splat](#splat)
  * [Options](#options)
    * [Aliases](#aliases)
    * [Defaults](#defaults)
    * [Deprecations](#deprecations)
    * [Downcase](#downcase)
    * [Enum](#enum)
    * [Example](#example)
    * [Format](#format)
    * [Internal](#internal)
    * [Min and Max](#min-and-max)
    * [See Also](#see-also)
    * [Types](#types)
    * [Required Options](#required-options)
* [Config Files](#config-files)
* [Environment Variables](#environment-variables)

## Basic Usage

```ruby
# lib/cli/owners/add.rb
module Owners
  class Add < Cl::Cmd
    summary 'Add one or more owners to an existing owner group'

    description <<~str
      Use this command to add one or more owners to an existing
      owner group.

      [...]
    str

    args :owners

    opt '-t', '--to TO', 'An existing owner group'

    def run
      # add owners as listed in `owners` to the group given in
      # `to`, as well as `opts[:to]`.
    end
  end
end

# bin/owners
Cl.new('owners').run(ARGV)
```

Running this, e.g. using `bin/owners add one,two --to group` will instantiate the
class `Owners::Add`, and call the method `run` on it.

Help output:

```txt
Usage: owners add [owners] [options]

Summary:

  Add one or more owners to an existing owner group

Description:

  Use this command to add one or more owners to an existing
  owner group.

  These will be visible in [...]

Arguments:

  owners          type: string

Options:

  -t --to TO      An existing owner group (type: string, required: true)
     --help       Get help on this command (type: flag)
```

### Command Registry

Commands are Ruby classes that extend the class `Cl::Cmd`.

They register to a [Ruby class registry](https://github.com/svenfuchs/registry) in order
to decouple looking up command classes from their Ruby namespace.

For example:

```ruby
module One
  class Cmd < Cl::Cmd
    register :one
  end
end

module Two
  class Cmd < Cl::Cmd
    register :two
  end
end

Cl::Cmd[:one] # => One::Cmd
Cl::Cmd[:two] # => Two::Cmd
```

Commands auto register themselves with the underscored name of the last part of
their class name (as seen in the example above). It is possible to ovewrite this
key by manually registering the class, like so:

```ruby
module One
  class Cmd < Cl::Cmd
    register :'cmd:one'
  end
end
```

### Runners

Runners lookup the command to execute from the registry, by checking the
arguments given by the user for registered command keys.

With the two command classes `One` and `Two` from the example above (and
assuming that the executable that calls `Cl` is `bin/run`) the default runner
would recognize and run the following commands:

```
$ bin/run one something else
# instantiates One, passing the args array `["something", "else"]`, and calls `run`

$ bin/run two something else
# instantiates One, passing an empty args arry `[]`, and calls `run`
```

The default runner also supports nested namespaces, and checks for command classes
with keys separated by colons. For instance:

```ruby
module Git
  class Pull < Cl::Cmd
    register :'git:pull'
  end
end

module Git
  class Push < Cl::Cmd
    register :'git:push'
  end
end
```

With these classes registered (and assuming the executable that calls `Cl` is
`bin/git`) the default runner would recognize and run the following commands:

```
$ bin/git pull:master # instantiates Git::Pull, and passes ["master"] as args
$ bin/git pull master # does the same

$ bin/git push:master # instantiates Git::Push, and passes ["master"] as args
$ bin/git push master # does the same
```

Runners are registered on the module `Cl::Runner`. It is possible to register custom
runners, and use them by passing the option `runner` to `Cl.new`:

```
# in bin/run
Cli.new('run', runner: :custom).run(ARGV)

# anywhere in your library
class Runner
  Cl::Runner.register :custom, self

  def initialize(ctx, args)
    # ...
  end

  def run
    const = identify_cmd_class_from_args
    const.new(ctx, args).run
  end
end
```

See `Cl::Runner::Default` for more details.

There also is an experimental runner `:multi`, which supports rake-style
execution of multiple commands at once, like so:

```
bin/rake db:drop production -f db:create db:migrate production -v 1
```

See the example [rakeish](blob/master/examples/rakeish) for more details.

## Command DSL

The DSL is defined on the class body.

## Description, Summary, Examples

The description, summary, and examples are used in the help output.

```
module Owners
  class Add < Cl::Cmd
    summary 'Add one or more owners to an existing owner group'

    description <<~str
      Use this command to add one or more owners to an existing
      owner group.
    str

    examples <<~str
      Adding a single user to the group admins:

        ./bin/owners add user --to admins

      Adding a several users at once:

        ./bin/owners add one two three --to admins
    str
  end
end
```

### Arguments

Arguments can be declared like so:

```ruby
arg :arg_name, description: 'arg description', type: :[array|string|integer|float|boolean]
```

This will define an `attr_accessor` on the `Cmd` class. I.e. in the following
example the method `ownsers` will be available on the `Cmd` instance:

```ruby
class Add < Cl::Cmd
  arg :owner

  def run
    p owner
  end
end

Cl.new('owners').run(%w(add one))

# => "one"

```

#### Types

Arguments can have a type. Known types are: `:array`, `:string`, `:integer`,
`:float`, `:boolean`.

The type `:array` makes sure the argument accessible on the `Cmd` instance is a
Ruby Array. (This currently only supports arrays of strings).

If the option `sep` is given on the argument, then the argument value is split
using this separator.

```ruby
class Add < Cl::Cmd
  arg :owners, type: :array, sep: ','

  def run
    p owners
  end
end

Cl.new('owners').run(%w(add one,two))

# => ["one", "two"]

```

Other types cast the given argument to the expected Ruby type.

```ruby
class Cmd < Cl::Cmd
  arg :one, type: :integer
  arg :two, type: :float
  arg :three, type: :boolean

  def run
    p [one.class, two.class, three.class]
  end
end

Cl.new('owners').run(%w(cmd 1 2.1 yes))

# => [Integer, Float, TrueClass]

```

#### Splat

Array arguments support splats, modeled after Ruby argument splats.

For example:

```ruby
class Cmd < Cl::Cmd
  arg :one, type: :integer
  arg :two, type: :float
  arg :three, type: :boolean

  def run
    p [one.class, two.class, three.class]
  end
end

Cl.new('owners').run(%w(cmd 1 2.1 yes))

# => [Integer, Float, TrueClass]

```

### Options

Declaring options can be done by calling the method `opt` on the class body.

This will add the option, if given by the user, to the hash `opts` on the `Cmd` instance.
It also defines a reader method that returns the respective value from the `opts` hash,
and a predicate that will be true if the option has been given.

For example:

```ruby
class Add < Cl::Cmd
  opt '--to GROUP', 'Target group to add owners to'

  def run
    p opts, to, to?
  end
end

Cl.new('owners').run(%w(add --to one))

# Output:
#
#   {"to" => "one"}
#   "one"
#   true

Cl.new('owners').run(%w(add --help))

# Usage: opts add [options]
#
# Options:
#
#   --to GROUP      Target group to add owners to (type: string)
#   --help          Get help on this command

```

Options optionally accept a block in case custom normalization is needed.

Depending on the block's arity the following arguments are passed to the block:
option value, option name, option type, collection of all options defined on
the command.

```ruby
class Add < Cl::Cmd
  # depending on its arity the block can receive:
  #
  # * value
  # * value, name
  # * value, name, type
  # * value, name, type, opts
  opt '--to GROUP' do |value|
    opts[:to] = "#{value.upcase}!"
  end

  def run
    p to
  end
end

Cl.new('owners').run(%w(add --to one))

# Output:
#
#   "ONE!"

```

#### Aliases

Options can have one or many alias names, given as a Symbol or Array of Symbols:

```ruby
class Add < Cl::Cmd
  opt '--to GROUP', alias: :group

  def run
    p opts, to, to?, group, group?
  end
end

Cl.new('owners').run(%w(add --to one))

# Output:
#
#   {"to" => "one"}
#   "one"
#   true
#   "one"
#   true

```

#### Defaults

Options can have a default value.

I.e. this value is going to be used if the user does not provide the option:

```ruby
class Add < Cl::Cmd
  opt '--to GROUP', default: 'default'

  def run
    p to
  end
end

Cl.new('owners').run(%w(add))

# Output:
#
#   "default"

```

#### Deprecations

Options, and option alias name can be deprecated.

For a deprecated option:

```ruby
class Add < Cl::Cmd
  opt '--to GROUP'
  opt '--target GROUP', deprecated: 'Deprecated: --target'

  def run
    p to, deprecated_opts
  end
end

Cl.new('owners').run(%w(add --target one))

# Output:
#
#   "one"
#   {:target=>'Deprecated: --target'}


```

For a deprecated option alias name:

```ruby
class Add < Cl::Cmd
  opt '--to GROUP', alias: :target, deprecated: :target

  def run
    p to, deprecated_opts
  end
end

Cl.new('owners').run(%w(add --target one))

# Output:
#
#   "one"
#   {:target=>:to}


```

#### Downcase

Options can be declared to be downcased.

For example:

```ruby
class Add < Cl::Cmd
  opt '--to GROUP', downcase: true

  def run
    p to
  end
end

Cl.new('owners').run(%w(add --to ONE))

# Output:
#
#   "one"

```

#### Enum

Options can be enums (i.e. have known values).

If an unknown values is given by the user the parser will reject the option,
and print the help output for this command.

For example:

```ruby
class Add < Cl::Cmd
  opt '--to GROUP', enum: %w(one two)

  def run
    p to
  end
end

Cl.new('owners').run(%w(add --to one))

# Output:
#
#   "one"

Cl.new('owners').run(%w(add --to unknown))

# Unknown value: to=unknown (known values: one, two)
#
# Usage: enum add [options]
#
# Options: ...

```

#### Example

Options can have examples that will be printed in the help output.

```ruby
class Add < Cl::Cmd
  opt '--to GROUP', example: 'group-one'
end

Cl.new('owners').run(%w(add --help))

# Usage: example add [options]
#
# Options:
#
#   --to GROUP      type: string, e.g.: group-one
#   --help          Get help on this command

```

#### Format

Options can have a required format.

If a value is given by the user that does not match the format then the parser
will reject the option, and print the help output for this command.

For example:

```ruby
class Add < Cl::Cmd
  opt '--to GROUP', format: /^\w+$/

  def run
    p to
  end
end

Cl.new('owners').run(%w(add --to one))

# Output:
#
#   "one"

Cl.new('owners').run(['add', '--to', 'does not match!'])

Invalid format: to (format: /^\w+$/)

Usage: format add [options]

Options:

  --to GROUP      type: string, format: /^\w+$/
  --help          Get help on this command

```

#### Internal

Options can be declared to be internal, hiding the option from the help output.

For example:

```ruby
class Add < Cl::Cmd
  opt '--to GROUP'
  opt '--hidden', internal: true
end

Cl.new('owners').run(%w(add --help))

# Usage: example add [options]
#
# Options:
#
#   --to GROUP      type: string, e.g.: group-one
#   --help          Get help on this command

```

#### Min and Max

Options can have mininum and/or maximum values.

If a value is given by the user that does not match the required min and/or max
values then the parser will reject the option, and print the help output for
this command.

For example:

```ruby
class Add < Cl::Cmd
  opt '--retries COUNT', type: :integer, min: 1, max: 5

  def run
    p retries
  end
end

Cl.new('owners').run(%w(add --retries 1))

# Output:
#
#   1

Cl.new('owners').run(%w(add --retries 10))

# Out of range: retries (max: 5)
#
# Usage: max add [options]
#
# Options:
#
#   --retries COUNT      type: integer, min: 1, max: 5
#   --help               Get help on this command

```

#### See Also

Options can refer to documentation using the `see` option. This will be printed
in the help output.

For example:

```ruby
class Add < Cl::Cmd
  opt '--to GROUP', see: 'https://docs.io/cli/owners/add'

  def run
    p retries
  end
end

Cl.new('owners').run(%w(add --help))

# Usage: see add [options]
#
# Options:
#
#   --to GROUP      type: string, see: https://docs.io/cli/owners/add
#   --help          Get help on this command

```

#### Types

Options can have a type. Known types are: `:array`, `:string`, `:integer`,
`:float`, `:boolean`.

The type `:array` allows an option to be given multiple times, and makes sure
the value accessible on the `Cmd` instance is a Ruby Array. (This currently
only supports arrays of strings).

```ruby
class Add < Cl::Cmd
  opt '--to GROUP', type: :array

  def run
    p to
  end
end

Cl.new('owners').run(%w(add --to one --to two))

# Output:
#
#   ["one", "two"]

```

Other types cast the given value to the expected Ruby type.

```ruby
class Add < Cl::Cmd
  opt '--active BOOL', type: :boolean
  opt '--retries INT', type: :integer
  opt '--sleep FLOAT', type: :float

  def run
    p active.class, retries.class, sleep.class
  end
end

Cl.new('owners').run(%w(add --active yes --retries 1 --sleep 0.1))

# Output:
#
#   TrueClass
#   Integer
#   Float

```

#### Required Options

There are three ways options can be required:

* using `required: true` on the option: the option itself is required to be given
* using `requires: :other`on the option: the option requires another option to be given
* using `required :one, [:two, :three]` on the class: either `one` or both `two` and `three` must be given

For example, this simply requires the option `--to`:

```ruby
class Add < Cl::Cmd
  opt '--to GROUP', required: true

  def run
    p to
  end
end

Cl.new('owners').run(%w(add --to one))

# Output:
#
#   "one"

Cl.new('owners').run(%w(add))

# Missing required option: to
#
# Usage: required add [options]
#
# Options:
#
#   --to GROUP      type: string, required: true
#   --help          Get help on this command

```

This will make the option `--retries` depend on the option `--to`:

```ruby
class Add < Cl::Cmd
  opt '--to GROUP'
  opt '--retries INT', requires: :to

  def run
    p to, retries
  end
end

Cl.new('owners').run(%w(add --to one --retries 1))

# Output:
#
#   "one"
#   1

Cl.new('owners').run(%w(add --retries 1))

# Missing option: to (required by retries)
#
# Usage: requires add [options]
#
# Options:
#
#   --to GROUP         type: string
#   --retries INT      type: string, requires: to
#   --help             Get help on this command

```

This requires either the option `--api_key` or both options `--username` and
`--password` to be given:

```ruby
class Add < Cl::Cmd
  # read DNF, i.e. "apikey OR username AND password
  required :api_key, [:username, :password]

  opt '--api_key KEY'
  opt '--username NAME'
  opt '--password PASS'

  def run
    p to, retries
  end
end

Cl.new('owners').run(%w(add --to one --retries 1))

# Output:
#
#   "one"
#   1

Cl.new('owners').run(%w(add --retries 1))

# Missing option: to (required by retries)
#
# Usage: requires add [options]
#
# Options:
#
#   --to GROUP         type: string
#   --retries INT      type: string, requires: to
#   --help             Get help on this command

```

### Config Files

Cl automatically reads config files that match the given executable name (inspired by
[gem-release](https://github.com/svenfuchs/gem-release)), stored either in the
user directory or the current working directory.

For example:

```ruby
module Api
  class Login < Cl::Cmd
    opt '--username USER'
    opt '--password PASS'
  end
end

# bin/api
CL.new('api').run(ARGV)

# ~/api.yml
login:
  username: 'someone'
  password: 'password'

# ./api.yml
login:
  username: 'someone else'
```

then running

```
$ bin/api login
```

instantiates `Api::Login`, and passes the hash

```ruby
{ username: 'someone else', password: 'password' }
```

as `opts`.

Options passed by the user take precedence over defaults defined in config
files.

### Environment Variables

Cl automatically defaults options to environment variables that are prefixed
with the given executable name (inspired by [gem-release](https://github.com/svenfuchs/gem-release)).

```ruby
module Api
  class Login < Cl::Cmd
    opt '--username USER'
    opt '--password PASS'
  end
end

# bin/api
CL.new('api').run(ARGV)
```

then running

```
$ API_USERNAME=someone API_PASSWORD=password bin/api login
```

instantiates `Api::Login`, and passes the hash

```ruby
{ username: 'someone', password: 'password' }
```

Options passed by the user take precedence over defaults given as environment
variables, and environment variables take precedence over defaults defined in
config files.
