#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    module Rakeish
      module Db
        class Create < Cl::Cmd
          register 'db:create'

          arg :name

          def run
            p cmd: registry_key, args: args, opts: opts
          end
        end

        class Drop < Cl::Cmd
          register 'db:drop'

          arg :name

          opt '-f', '--force'

          def run
            p cmd: registry_key, args: args, opts: opts
          end
        end

        class Migrate < Cl::Cmd
          register 'db:migrate'

          arg :name

          opt '-v', '--version VERSION'

          def run
            p cmd: registry_key, args: args, opts: opts
          end
        end
      end
    end
  rb
-%>

<%= run "Cl.new('rake', runner: :multi).run(%w(db:drop production -f db:create db:migrate production -v 1))" %>

<%= out sq(<<-'str')
    {:cmd=>:"db:drop", :args=>["production"], :opts=>{:force=>true}}
    {:cmd=>:"db:create", :args=>[], :opts=>{}}
    {:cmd=>:"db:migrate", :args=>["production"], :opts=>{:version=>"1"}}
  str
%>
