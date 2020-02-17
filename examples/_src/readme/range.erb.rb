#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    class Add < Cl::Cmd
      register :add

      opt '--retries COUNT', type: :integer, min: 1, max: 5

      def run
        p retries: retries
      end
    end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add --retries 1))" %>

<%= out '{:retries=>1}' %>

<%= run "Cl.new('owners').run(%w(add --retries 10))" %>

<%= out sq(<<-'str')
    Out of range: retries (min: 1, max: 5)

    Usage: owners add [options]

    Options:

      --retries COUNT      type: integer, min: 1, max: 5
      --help               Get help on this command
  str
%>
