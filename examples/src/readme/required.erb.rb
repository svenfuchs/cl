#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
  require 'cl'

  class Add < Cl::Cmd
    opt '--to GROUP', required: true

    def run
      p to: to
    end
  end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add --to one))" %>

<%= out '{:to=>"one"}' %>

<%= run "Cl.new('owners').run(%w(add))" %>

<%= out sq(<<-'str')
  Missing required option: to

  Usage: owners add [options]

  Options:

    --to GROUP      type: string, required: true
    --help          Get help on this command
  str
%>
