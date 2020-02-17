#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    class Add < Cl::Cmd
      register :add

      opt '--notifications', 'Send out notifications to the team', negate: %w(skip)

      def run
        p notifications?
      end
    end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add --notifications))" %>

<%= out 'true' %>

<%= run "Cl.new('owners').run(%w(add --no_notifications))" %>

<%= out 'false' %>

<%= run "Cl.new('owners').run(%w(add --no-notifications))" %>

<%= out 'false' %>

<%= run "Cl.new('owners').run(%w(add --skip_notifications))" %>

<%= out 'false' %>

<%= run "Cl.new('owners').run(%w(add --skip-notifications))" %>

<%= out 'false' %>
