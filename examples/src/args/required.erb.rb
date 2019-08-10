#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    class Required < Cl::Cmd
      arg :one, required: true
      arg :two

      def run
        p cmd: registry_key, one: one, two: two
      end
    end
  rb
-%>

<%= run 'Cl.new($0).run(%w(required one two))' %>

<%= out '{:cmd=>:required, :one=>"one", :two=>"two"}' %>

<%= run 'Cl.new($0).run(%w(required one))' %>

<%= out '{:cmd=>:required, :one=>"one", :two=>nil}' %>

<%= run 'Cl.new($0).run(%w(required))' %>

<%= out sq(<<-'str')
    Missing arguments (given: 0, required: 1)

    Usage: bin/examples required one [two] [options]

    Arguments:

      one         type: string, required: true
      two         type: string

    Options:

      --help      Get help on this command
  str
%>

<%= run 'Cl.new($0).run(%w(required one two three))' %>

<%= out sq(<<-'str')
    Too many arguments (given: 3, allowed: 2)

    Usage: bin/examples required one [two] [options]

    Arguments:

      one         type: string, required: true
      two         type: string

    Options:

      --help      Get help on this command
  str
%>

