#!/usr/bin/env ruby
$: << File.expand_path('lib')

require 'cl'

<%= run sq(<<-'rb')
    class Base < Cl::Cmd
      abstract
    end

    class Add < Base
      def run
        puts 'Success'
      end
    end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add))" %>

<%= out 'Success' %>

<%= run "Cl.new('owners').run(%w(base))" %>

<%= out 'Unknown command: base' %>
