#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
  class Add < Cl::Cmd
    register :add

    opt '--to GROUP'
    opt '--other GROUP', requires: :to

    def run
      p to: to, other: other
    end
  end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add --to one --other two))" %>

<%= out '{:to=>"one", :other=>"two"}' %>

<%= run "Cl.new('owners').run(%w(add --other two))" %>

<%= out sq(<<-'str')
  Missing option: to (required by other)

  Usage: owners add [options]

  Options:

    --to GROUP         type: string
    --other GROUP      type: string, requires: to
    --help             Get help on this command
  str
%>
