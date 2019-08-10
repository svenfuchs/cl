#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
  require 'cl'

  class Add < Cl::Cmd
    opt '--to GROUP', see: 'https://docs.io/cli/owners/add'
  end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add --help))" %>

<%= out sq(<<-'str')
  Usage: owners add [options]

  Options:

    --to GROUP      type: string, see: https://docs.io/cli/owners/add
    --help          Get help on this command
  str
%>
