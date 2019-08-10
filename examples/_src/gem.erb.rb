#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    module Gem
      module Release
        module Cmds
          class Release < Cl::Cmd
            arg :gemspec

            opt '-h', '--host HOST', 'Push to a compatible host other than rubygems.org'
            opt '-k', '--key KEY',   'Rubygems API key to use'
            opt '-q', '--quiet',     'Silence output'

            def run
              p cmd: registry_key, args: args, opts: opts
            end
          end

          class Bump < Cl::Cmd
            opt '-v', '--version VERSION', 'The version to bump to [1.1.1|major|minor|patch|pre|rc|release]'
            opt '--[no-]commit',           'Bump the version, but do not commit'

            def run
              p cmd: registry_key, args: args, opts: opts
            end
          end
        end
      end
    end
  rb
-%>

<%= run "Cl.new('gem').run(%w(help))" %>

<%= out sq(<<-'str')
    Type "gem help COMMAND [SUBCOMMAND]" for more details:

    gem release [gemspec] [options]
    gem bump [options]
  str
%>


<%= run "Cl.new('gem').run(%w(help release))" %>
# or:
#
#   Cl.new('gem').run(%w(release --help)))
#   Cl.new('gem').run(%w(release -h)))
#
<%= out sq(<<-'str')
    Usage: gem release [gemspec] [options]

    Arguments:

      gemspec              type: string

    Options:

      -h --host HOST       Push to a compatible host other than rubygems.org (type: string)
      -k --key KEY         Rubygems API key to use (type: string)
      -q --[no-]quiet      Silence output
         --help            Get help on this command
  str
%>


<%= run "Cl.new('gem').run(%w(help bump))" %>
# or:
#
#   Cl.new('gem').run(%w(bump --help)))
#   Cl.new('gem').run(%w(bump -h)))
#
<%= out sq(<<-'str')
    Usage: gem bump [options]

    Options:

      -v --version VERSION      The version to bump to [1.1.1|major|minor|patch|pre|rc|release] (type: string)
         --[no-]commit          Bump the version, but do not commit
         --help                 Get help on this command
  str
%>


<%= run "Cl.new('gem').run(%w(bump -v 1.1.1))" %>

<%= out '{:cmd=>:bump, :args=>[], :opts=>{:version=>"1.1.1"}}' %>


<%= run "Cl.new('gem').run(%w(release foo.gemspec -h host -k key -q))" %>

<%= out '{:cmd=>:release, :args=>["foo.gemspec"], :opts=>{:host=>"host", :key=>"key", :quiet=>true}}' %>
