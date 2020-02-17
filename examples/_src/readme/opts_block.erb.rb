#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    class Add < Cl::Cmd
      register :add

      # depending on its arity the block can receive:
      #
      # * value
      # * value, name
      # * value, name, type
      # * value, name, type, opts
      opt '--to GROUP' do |value|
        opts[:to] = "group-#{value}"
      end

      def run
        p to: to
      end
    end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add --to one))" %>

<%= out '{:to=>"group-one"}' %>

