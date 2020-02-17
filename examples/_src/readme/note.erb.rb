#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    class Add < Cl::Cmd
      register :add

      opt '--to GROUP', note: 'needs to be a group'
    end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add --help))" %>

<%= out sq(<<-'str')
    Usage: owners add [options]

    Options:

      --to GROUP      type: string, note: needs to be a group
      --help          Get help on this command
  str
%>
