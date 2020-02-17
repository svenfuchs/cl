#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    class Add < Cl::Cmd
      register :add

      opt '--target GROUP', deprecated: 'Deprecated.'

      def run
        p target: target, deprecations: deprecations
      end
    end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add --target one))" %>

<%= out '{:target=>"one", :deprecations=>{:target=>"Deprecated."}}' %>
