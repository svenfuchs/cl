#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    class Add < Cl::Cmd
      register :add

      opt '--to GROUP', alias: :group

      def run
        # p opts: opts, to: to, to?: to?, group: group, group?: group?
        p opts: opts, to: to, to?: to?
      end
    end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add --group one))" %>

<%= out '{:opts=>{:to=>"one", :group=>"one"}, :to=>"one", :to?=>true}' %>
