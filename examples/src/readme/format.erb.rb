#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    class Add < Cl::Cmd
      opt '--to GROUP', format: /^\w+$/

      def run
        p to: to
      end
    end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add --to one))" %>

<%= out '{:to=>"one"}' %>

<%= run "Cl.new('owners').run(['add', '--to', 'does not match!'])" %>

<%= out sq(<<-'str')
    Invalid format: to (format: /^\w+$/)

    Usage: owners add [options]

    Options:

      --to GROUP      type: string, format: /^\w+$/
      --help          Get help on this command
  str
%>
