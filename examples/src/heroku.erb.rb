#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    module Heroku
      module Apps
        class Create < Cl::Cmd
          register 'apps:create'

          arg :name, required: true

          opt '-o', '--org ORG'

          def run
            p cmd: registry_key, args: args, opts: opts
          end
        end

        class List < Cl::Cmd
          register 'apps:info'

          opt '-a', '--app APP'

          def run
            p cmd: registry_key, args: args, opts: opts
          end
        end
      end
    end
  rb
-%>

<%= run "Cl.new('heroku').run(%w(apps:create name -o org))" %>
# or:
#
#   Cl.new('heroku').run(%w(apps create name -o org))

<%= out '{:cmd=>:"apps:create", :args=>["name"], :opts=>{:org=>"org"}}' %>

<%= run "Cl.new('heroku').run(%w(apps:info -a app))" %>
# or:
#
#   Cl.new('heroku').run(%w(apps info -a app))

<%= out '{:cmd=>:"apps:info", :args=>[], :opts=>{:app=>"app"}}' %>
