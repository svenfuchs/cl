#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    class Add < Cl::Cmd
      opt '--to GROUP', type: :array

      def run
        p to
      end
    end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add --to one --to two))" %>

<%= out '["one", "two"]' %>
