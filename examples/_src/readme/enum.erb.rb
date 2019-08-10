#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    class Add < Cl::Cmd
      opt '--to GROUP', enum: %w(one two)

      def run
        p to: to
      end
    end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add --to one))" %>

<%= out '{:to=>"one"}' %>

<%= run "Cl.new('owners').run(%w(add --to unknown))" %>

<%= out sq(<<-'str')
    Unknown value: to=unknown (known values: one, two)

    Usage: owners add [options]

    Options:

      --to GROUP      type: string, known values: one, two
      --help          Get help on this command
  str
%>
