#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    class Cmd < Cl::Cmd
      register :cmd

      arg :one, type: :integer
      arg :two, type: :float
      arg :three, type: :boolean

      def run
        p [one.class, two.class, three.class]
      end
    end
  rb
-%>

<%= run "Cl.new('owners').run(%w(cmd 1 2.1 yes))" %>

<%= out "[#{RUBY_VERSION < '2.4' ? 'Fixnum' : 'Integer'}, Float, TrueClass]" %>
