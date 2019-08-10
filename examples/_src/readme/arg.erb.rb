#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    class Add < Cl::Cmd
      arg :owner

      def run
        p owner: owner
      end
    end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add one))" %>

<%= out '{:owner=>"one"}' %>
