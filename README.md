# Cl [![Build Status](https://travis-ci.org/svenfuchs/cl.svg?branch=master)](https://travis-ci.org/svenfuchs/cl) [![Code Climate](https://api.codeclimate.com/v1/badges/870e448eb8162d3e1ed7/maintainability)](https://codeclimate.com/github/svenfuchs/cl) [![Code Coverage](https://coveralls.io/repos/github/svenfuchs/cl/badge.svg?branch=master)](https://coveralls.io/github/svenfuchs/cl?branch=master) [![Gem Version](https://img.shields.io/gem/v/cl?cache=2019-08-10)](http://rubygems.org/gems/cl) [![Rubydocs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/svenfuchs/cl)

OptionParser based CLI support for rapid CLI development in an object-oriented
context.

This library wraps Ruby's OptionParser for parsing your options under the hood,
so you get all the goodness that the Ruby standard library provides.

On top of that it adds a rich and powerful DSL for defining, validating, and
normalizing options, as well as automatic and gorgeous help output (modeled
after `gem --help`).

Further documentation is available on [rubydoc.info](https://www.rubydoc.info/github/svenfuchs/cl)

Examples in this README are included from [examples/readme](https://github.com/svenfuchs/cl/tree/master/examples/readme).
More examples can be found in [examples](https://github.com/svenfuchs/cl/tree/master/examples).
All examples are guaranteed to be up to date by the way of being [verified](https://github.com/svenfuchs/cl/blob/master/.travis.yml#L14)
on CI.

## Table of Contents

* [Basic Usage](#basic-usage)
* [Command Registry](#command-registry)
* [Runners](#runners)
* [Command DSL](#command-dsl)
  * [Commands](#commands)
    * [Description, Summary, Examples](#description-summary-examples)
    * [Abstract](#abstract)
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
    * [Negations](#negations)
    * [Note](#note)
    * [Secret](#secret)
    * [See Also](#see-also)
    * [Types](#types)
    * [Required Options](#required-options)
* [Config Files](#config-files)
* [Environment Variables](#environment-variables)

## Basic Usage

```ruby
module Owners
  class Add < Cl::Cmd
    register :add

    summary 'Add one or more owners to an existing owner group'

    description <<~str
      Use this command to add one or more owners to an existing
      owner group.

      [...]
    str

    args :owner

    opt '-t', '--to TO', 'An existing owner group'

    def run
      # implement adding the owner as given in `owner` (as well as `args`)
      # to the group given in `to` (as well as `opts[:to]`).
      p owner: owner, to: to, to?: to?, args: args, opts: opts
    end
  end
end

# Running this, e.g. using `bin/owners add one,two --to group` will instantiate the
# class `Owners::Add`, and call the method `run` on it.

# e.g. bin/owners
#
# args normally would be ARGV
args = %w(add one --to group)

Cl.new('owners').run(args)

# Output:
#
#   {:owner=>"one", :to=>"group", :to?=>true, :args=>["one"], :opts=>{:to=>"group"}}

Cl.new('owners').run(%w(add --help))

# Output:
#
#   Usage: owners add [owner] [options]
#
#   Summary:
#
#     Add one or more owners to an existing owner group
#
#   Description:
#
#     Use this command to add one or more owners to an existing
#     owner group.
#
#     [...]
#
#   Arguments:
#
#     owner           type: string
#
#   Options:
#
#     -t --to TO      An existing owner group (type: string)
#        --help       Get help on this command

```

### Command Registry

Commands are Ruby classes that extend the class `Cl::Cmd`.

They register to a [Ruby class registry](https://github.com/svenfuchs/registry) in order
to decouple looking up command classes from their Ruby namespace.

For example:

```ruby
module Cmd
  class One < Cl::Cmd
    register :one
  end

  class Two < Cl::Cmd
    register :two
  end
end

p Cl::Cmd[:one] # => Cmd::One
p Cl::Cmd[:two] # => Cmd::Two

```

Commands can be registered like so:

```ruby
module One
  class Cmd < Cl::Cmd
    register :'cmd:one'
  end
end
```

By default commands auto register themselves with the underscored name of the
last part of their class name (as seen in the example above). It is possible to
turn this off using:

```ruby
Cl::Cmd.auto_register = false
```

Command auto-registration can cause name clashes when namespaced commands have
the same demodulized class name. For example:

```ruby
class Git < Cl::Cmd
  # auto-registers as :git
end

module Heroku
  class Git < Cl::Cmd
    # also auto-registers as :git
  end
end
```

It is recommended to turn auto-registration off when using such module
structures.


### Runners

Runners lookup the command to execute from the registry, by checking the
arguments given by the user for registered command keys.

With the two command classes `One` and `Two` from the example above (and
assuming that the executable that calls `Cl` is `bin/run`) the default runner
would recognize and run the following commands:

```
$ bin/run one something else
# instantiates One, passing the args array `["something", "else"]`, and calls the instance method `run`

$ bin/run two
# instantiates Two, passing an empty args arry `[]`, and calls the instance method `run`
```

The default runner also supports nested namespaces, and checks for command classes
with keys separated by colons. For instance:

```ruby
module Git
  class Pull < Cl::Cmd
    register :'git:pull'

    arg :branch

    def run
      p cmd: registry_key, args: args
    end
  end
end

# With this class registered (and assuming the executable that calls `Cl` is
# `bin/run`) the default runner would recognize and run it:
#
# $ bin/run git:pull master # instantiates Git::Pull, and passes ["master"] as args
# $ bin/run git pull master # does the same

Cl.new('run').run(%w(git:pull master))
# Output:
#
#   {:cmd=>:"git:pull", :args=>["master"]}

Cl.new('run').run(%w(git pull master))
# Output:
#
#   {:cmd=>:"git:pull", :args=>["master"]}

```

Runners are registered on the module `Cl::Runner`. It is possible to register custom
runners, and use them by passing the option `runner` to `Cl.new`:

```ruby
module Git
  class Pull < Cl::Cmd
    register :'git:pull'

    arg :branch

    def run
      p cmd: registry_key, args: args
    end
  end
end

# With this class registered (and assuming the executable that calls `Cl` is
# `bin/run`) the default runner would recognize and run it:
#
# $ bin/run git:pull master # instantiates Git::Pull, and passes ["master"] as args
# $ bin/run git pull master # does the same

Cl.new('run').run(%w(git:pull master))
# Output:
#
#   {:cmd=>:"git:pull", :args=>["master"]}

Cl.new('run').run(%w(git pull master))
# Output:
#
#   {:cmd=>:"git:pull", :args=>["master"]}

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

### Commands

Commands are classes that are derived from the base class `Cl::Cmd`.

#### Description, Summary, Examples

The description, summary, and examples are used in the help output.

```ruby
module Owners
  class Add < Cl::Cmd
    register :add

    summary 'Add one or more owners to an existing owner group'

    description <<~str
      Use this command to add one or more owners to an existing
      owner group.
    str

    examples <<~str
      Adding a single user to the group admins:

        owners add user --to admins

      Adding a several users at once:

        owners add one two three --to admins
    str
  end
end

Cl.new('owners').run(%w(add --help))

# Output:
#
#   Usage: owners add [options]
#
#   Summary:
#
#     Add one or more owners to an existing owner group
#
#   Description:
#
#     Use this command to add one or more owners to an existing
#     owner group.
#
#   Options:
#
#     --help      Get help on this command
#
#   Examples:
#
#     Adding a single user to the group admins:
#
#       owners add user --to admins
#
#     Adding a several users at once:
#
#       owners add one two three --to admins

```

#### Abstract

Command base classes can be declared abstract in order to prevent them from
being identified as a runnable command and to  omit them from help output.

This is only relevant if a command base class is registered. See [Command
Registry](#command-registry) for details.

```ruby
class Base < Cl::Cmd
  abstract
end

class Add < Base
  register :add

  def run
    puts 'Success'
  end
end

Cl.new('owners').run(%w(add))

# Output:
#
#   Success

Cl.new('owners').run(%w(base))

# Output:
#
#   Unknown command: base

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
  register :add

  arg :owner

  def run
    p owner: owner
  end
end

Cl.new('owners').run(%w(add one))

# Output:
#
#   {:owner=>"one"}

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
  register :add

  arg :owners, type: :array, sep: ','

  def run
    p owners: owners
  end
end

Cl.new('owners').run(%w(add one,two))

# Output:
#
#   {:owners=>["one", "two"]}

```

Other types cast the given argument to the expected Ruby type.

```ruby
class Cmd < Cl::Cmd
  register :cmd

  arg :one, type: :integer
  arg :two, type: :float
  arg :three, type: :boolean

  def run
    p [one.class, two.class, three.class]
  end
end

Cl.new('owners').run(%w(cmd 1 2.1 yes))

# Output:
#
#   [Integer, Float, TrueClass]

```

#### Splat

Array arguments support splats, modeled after Ruby argument splats.

For example:

```ruby
class Lft < Cl::Cmd
  register :lft

  arg :a, type: :array, splat: true
  arg :b
  arg :c

  def run
    p [a, b, c]
  end
end

class Mid < Cl::Cmd
  register :mid

  arg :a
  arg :b, type: :array, splat: true
  arg :c

  def run
    p [a, b, c]
  end
end

class Rgt < Cl::Cmd
  register :rgt

  arg :a
  arg :b
  arg :c, type: :array, splat: true

  def run
    p [a, b, c]
  end
end

Cl.new('splat').run(%w(lft 1 2 3 4 5))

# Output:
#
#   [["1", "2", "3"], "4", "5"]

Cl.new('splat').run(%w(mid 1 2 3 4 5))

# Output:
#
#   ["1", ["2", "3", "4"], "5"]

Cl.new('splat').run(%w(rgt 1 2 3 4 5))

# Output:
#
#   ["1", "2", ["3", "4", "5"]]

```

### Options

Declaring options can be done by calling the method `opt` on the class body.

This will add the option, if given by the user, to the hash `opts` on the `Cmd` instance.
It also defines a reader method that returns the respective value from the `opts` hash,
and a predicate that will be true if the option has been given.

For example:

```ruby
class Add < Cl::Cmd
  register :add

  opt '--to GROUP', 'Target group to add owners to'

  def run
    p opts: opts, to: to, to?: to?
  end
end

Cl.new('owners').run(%w(add --to one))

# Output:
#
#   {:opts=>{:to=>"one"}, :to=>"one", :to?=>true}

Cl.new('owners').run(%w(add --help))

# Output:
#
#   Usage: owners add [options]
#
#   Options:
#
#     --to GROUP      Target group to add owners to (type: string)
#     --help          Get help on this command

```

Options optionally accept a block in case custom normalization is needed.

Depending on the block's arity the following arguments are passed to the block:
option value, option name, option type, collection of all options defined on
the command.

```ruby
class Add < Cl::Cmd
  register :add

  # depending on its arity the block can receive:
  #
  # * value
  # * value, name
  # * value, name, type
  # * value, name, type, opts
  opt '--to GROUP' do |value|
    opts[:to] = "group-#{value}"
  end

  def run
    p to: to
  end
end

Cl.new('owners').run(%w(add --to one))

# Output:
#
#   {:to=>"group-one"}


```

#### Aliases

Options can have one or many alias names, given as a Symbol or Array of Symbols:

```ruby
class Add < Cl::Cmd
  register :add

  opt '--to GROUP', alias: :group

  def run
    # p opts: opts, to: to, to?: to?, group: group, group?: group?
    p opts: opts, to: to, to?: to?
  end
end

Cl.new('owners').run(%w(add --group one))

# Output:
#
#   {:opts=>{:to=>"one", :group=>"one"}, :to=>"one", :to?=>true}

```

#### Defaults

Options can have a default value.

I.e. this value is going to be used if the user does not provide the option:

```ruby
class Add < Cl::Cmd
  register :add

  opt '--to GROUP', default: 'default'

  def run
    p to: to
  end
end

Cl.new('owners').run(%w(add))

# Output:
#
#   {:to=>"default"}

```

#### Deprecations

Options, and option alias name can be deprecated.

For a deprecated option:

```ruby
class Add < Cl::Cmd
  register :add

  opt '--target GROUP', deprecated: 'Deprecated.'

  def run
    p target: target, deprecations: deprecations
  end
end

Cl.new('owners').run(%w(add --target one))

# Output:
#
#   {:target=>"one", :deprecations=>{:target=>"Deprecated."}}

```

For a deprecated option alias name:

```ruby
class Add < Cl::Cmd
  register :add

  opt '--to GROUP', alias: :target, deprecated: :target

  def run
    p to: to, deprecations: deprecations
  end
end

Cl.new('owners').run(%w(add --target one))

# Output:
#
#   {:to=>"one", :deprecations=>{:target=>:to}}

```

#### Downcase

Options can be declared to be downcased.

For example:

```ruby
class Add < Cl::Cmd
  register :add

  opt '--to GROUP', downcase: true

  def run
    p to: to
  end
end

Cl.new('owners').run(%w(add --to ONE))

# Output:
#
#   {:to=>"one"}

```

#### Enum

Options can be enums (i.e. have known values).

If an unknown values is given by the user the parser will reject the option,
and print the help output for this command.

For example:

```ruby
class Add < Cl::Cmd
  register :add

  opt '--to GROUP', enum: %w(one two)

  def run
    p to: to
  end
end

Cl.new('owners').run(%w(add --to one))

# Output:
#
#   {:to=>"one"}

Cl.new('owners').run(%w(add --to unknown))

# Output:
#
#   Unknown value: to=unknown (known values: one, two)
#
#   Usage: owners add [options]
#
#   Options:
#
#     --to GROUP      type: string, known values: one, two
#     --help          Get help on this command

```

#### Example

Options can have examples that will be printed in the help output.

```ruby
class Add < Cl::Cmd
  register :add

  opt '--to GROUP', example: 'group-one'
end

Cl.new('owners').run(%w(add --help))

# Output:
#
#   Usage: owners add [options]
#
#   Options:
#
#     --to GROUP      type: string, e.g.: group-one
#     --help          Get help on this command

```

#### Format

Options can have a required format.

If a value is given by the user that does not match the format then the parser
will reject the option, and print the help output for this command.

For example:

```ruby
class Add < Cl::Cmd
  register :add

  opt '--to GROUP', format: /^\w+$/

  def run
    p to: to
  end
end

Cl.new('owners').run(%w(add --to one))

# Output:
#
#   {:to=>"one"}

Cl.new('owners').run(['add', '--to', 'does not match!'])

# Output:
#
#   Invalid format: to (format: /^\w+$/)
#
#   Usage: owners add [options]
#
#   Options:
#
#     --to GROUP      type: string, format: /^\w+$/
#     --help          Get help on this command

```

#### Internal

Options can be declared to be internal, hiding the option from the help output.

For example:

```ruby
class Add < Cl::Cmd
  register :add

  opt '--to GROUP'
  opt '--hidden', internal: true
end

Cl.new('owners').run(%w(add --help))

# Output:
#
#   Usage: owners add [options]
#
#   Options:
#
#     --to GROUP      type: string
#     --help          Get help on this command

```

#### Min and Max

Options can have mininum and/or maximum values.

If a value is given by the user that does not match the required min and/or max
values then the parser will reject the option, and print the help output for
this command.

For example:

```ruby
class Add < Cl::Cmd
  register :add

  opt '--retries COUNT', type: :integer, min: 1, max: 5

  def run
    p retries: retries
  end
end

Cl.new('owners').run(%w(add --retries 1))

# Output:
#
#   {:retries=>1}

Cl.new('owners').run(%w(add --retries 10))

# Output:
#
#   Out of range: retries (min: 1, max: 5)
#
#   Usage: owners add [options]
#
#   Options:
#
#     --retries COUNT      type: integer, min: 1, max: 5
#     --help               Get help on this command

```

#### Negations

Flags (boolean options) automatically allow negation using `--no-*` and
`--no_*` using OptionParser's support for these. However, sometimes it can be
convenient to allow other terms for negating an option. Flags therefore accept
an option `negate` like so:

```ruby
class Add < Cl::Cmd
  register :add

  opt '--notifications', 'Send out notifications to the team', negate: %w(skip)

  def run
    p notifications?
  end
end

Cl.new('owners').run(%w(add --notifications))

# Output:
#
#   true

Cl.new('owners').run(%w(add --no_notifications))

# Output:
#
#   false

Cl.new('owners').run(%w(add --no-notifications))

# Output:
#
#   false

Cl.new('owners').run(%w(add --skip_notifications))

# Output:
#
#   false

Cl.new('owners').run(%w(add --skip-notifications))

# Output:
#
#   false

```

#### Note

Options can have a note that will be printed in the help output.

```ruby
class Add < Cl::Cmd
  register :add

  opt '--to GROUP', note: 'needs to be a group'
end

Cl.new('owners').run(%w(add --help))

# Output:
#
#   Usage: owners add [options]
#
#   Options:
#
#     --to GROUP      type: string, note: needs to be a group
#     --help          Get help on this command

```

#### Secret

Options can be declared as secret.

This makes it possible for client code to inspect if a given option is secret.
Also, option values given by the user will be tainted, so client code can rely
on this in order to, for example, obfuscate values from log output.

```ruby
class Add < Cl::Cmd
  register :add

  opt '--pass PASS', secret: true

  def run
    p(
      secret?: self.class.opts[:pass].secret?,
      tainted?: pass.tainted?
    )
  end
end

Cl.new('owners').run(%w(add --pass pass))

# Output:
#
#   {:secret?=>true, :tainted?=>true}

```

#### See Also

Options can refer to documentation using the `see` option. This will be printed
in the help output.

For example:

```ruby
class Add < Cl::Cmd
  register :add

  opt '--to GROUP', see: 'https://docs.io/cli/owners/add'
end

Cl.new('owners').run(%w(add --help))

# Output:
#
#   Usage: owners add [options]
#
#   Options:
#
#     --to GROUP      type: string, see: https://docs.io/cli/owners/add
#     --help          Get help on this command

```

#### Types

Options can have a type. Known types are: `:array`, `:string`, `:integer`,
`:float`, `:boolean`.

The type `:array` allows an option to be given multiple times, and makes sure
the value accessible on the `Cmd` instance is a Ruby Array. (This currently
only supports arrays of strings).

```ruby
class Add < Cl::Cmd
  register :add

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
  register :add

  opt '--active BOOL', type: :boolean
  opt '--retries INT', type: :integer
  opt '--sleep FLOAT', type: :float

  def run
    p active: active.class, retries: retries.class, sleep: sleep.class
  end
end

Cl.new('owners').run(%w(add --active yes --retries 1 --sleep 0.1))

# Output:
#
#   {:active=>TrueClass, :retries=>Integer, :sleep=>Float}

```

#### Required Options

There are three ways options can be required:

* using `required: true` on the option: the option itself is required to be given
* using `requires: :other`on the option: the option requires another option to be given
* using `required :one, [:two, :three]` on the class: either `one` or both `two` and `three` must be given

For example, this simply requires the option `--to`:

```ruby
class Add < Cl::Cmd
  register :add

  opt '--to GROUP', required: true

  def run
    p to: to
  end
end

Cl.new('owners').run(%w(add --to one))

# Output:
#
#   {:to=>"one"}

Cl.new('owners').run(%w(add))

# Output:
#
#   Missing required option: to
#
#   Usage: owners add [options]
#
#   Options:
#
#     --to GROUP      type: string, required
#     --help          Get help on this command

```

This will make the option `--retries` depend on the option `--to`:

```ruby
class Add < Cl::Cmd
  register :add

  opt '--to GROUP'
  opt '--other GROUP', requires: :to

  def run
    p to: to, other: other
  end
end

Cl.new('owners').run(%w(add --to one --other two))

# Output:
#
#   {:to=>"one", :other=>"two"}

Cl.new('owners').run(%w(add --other two))

# Output:
#
#   Missing option: to (required by other)
#
#   Usage: owners add [options]
#
#   Options:
#
#     --to GROUP         type: string
#     --other GROUP      type: string, requires: to
#     --help             Get help on this command

```

This requires either the option `--api_key` or both options `--username` and
`--password` to be given:

```ruby
class Add < Cl::Cmd
  register :add

  # read DNF, i.e. "token OR user AND pass
  required :token, [:user, :pass]

  opt '--token TOKEN'
  opt '--user NAME'
  opt '--pass PASS'

  def run
    p token: token, user: user, pass: pass
  end
end

Cl.new('owners').run(%w(add --token token))

# Output:
#
#   {:token=>"token", :user=>nil, :pass=>nil}

Cl.new('owners').run(%w(add --user user --pass pass))

# Output:
#
#   {:token=>nil, :user=>"user", :pass=>"pass"}

Cl.new('owners').run(%w(add))

# Output:
#
#   Missing options: token, or user and pass
#
#   Usage: owners add [options]
#
#   Options:
#
#     Either token, or user and pass are required.
#
#     --token TOKEN      type: string
#     --user NAME        type: string
#     --pass PASS        type: string
#     --help             Get help on this command

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
