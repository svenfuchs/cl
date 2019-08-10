#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    class Add < Cl::Cmd
      opt '--to GROUP', downcase: true

      def run
        p to: to
      end
    end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add --to ONE))" %>

<%= out '{:to=>"one"}' %>
