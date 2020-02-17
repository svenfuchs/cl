#!/usr/bin/env ruby
$: << File.expand_path('lib')

require 'cl'

<%= run sq(<<-'rb')
    require 'cl'

    class Add < Cl::Cmd
      register :add

      opt '--to GROUP'
      opt '--hidden', internal: true
    end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add --help))" %>

<%= out sq(<<-'str')
    Usage: owners add [options]

    Options:

      --to GROUP      type: string
      --help          Get help on this command
  str
%>
