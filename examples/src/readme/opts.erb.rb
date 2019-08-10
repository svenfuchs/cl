#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    class Add < Cl::Cmd
      opt '--to GROUP', 'Target group to add owners to'

      def run
        p opts: opts, to: to, to?: to?
      end
    end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add --to one))" %>

<%= out '{:opts=>{:to=>"one"}, :to=>"one", :to?=>true}' %>

<%= run "Cl.new('owners').run(%w(add --help))" %>

<%= out sq(<<-'str')
    Usage: owners add [options]

    Options:

      --to GROUP      Target group to add owners to (type: string)
      --help          Get help on this command
  str
%>
