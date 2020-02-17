#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    class Add < Cl::Cmd
      register :add

      opt '--to GROUP', alias: :target, deprecated: :target

      def run
        p to: to, deprecations: deprecations
      end
    end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add --target one))" %>

<%= out '{:to=>"one", :deprecations=>{:target=>:to}}' %>
