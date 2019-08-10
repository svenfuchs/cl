#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
  class Add < Cl::Cmd
    # read DNF, i.e. "token OR user AND pass
    required :token, [:user, :pass]

    opt '--token TOKEN'
    opt '--user NAME'
    opt '--pass PASS'

    def run
      p token: token, user: user, pass: pass
    end
  end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add --token token))" %>

<%= out '{:token=>"token", :user=>nil, :pass=>nil}' %>

<%= run "Cl.new('owners').run(%w(add --user user --pass pass))" %>

<%= out '{:token=>nil, :user=>"user", :pass=>"pass"}' %>

<%= run "Cl.new('owners').run(%w(add))" %>

<%= out sq(<<-'str')
  Missing options: token, or user and pass

  Usage: owners add [options]

  Options:

    Either token, or user and pass are required.

    --token TOKEN      type: string
    --user NAME        type: string
    --pass PASS        type: string
    --help             Get help on this command
  str
%>
