#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    class Add < Cl::Cmd
      register :add

      arg :owners, type: :array, sep: ','

      def run
        p owners: owners
      end
    end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add one,two))" %>

<%= out '{:owners=>["one", "two"]}' %>
