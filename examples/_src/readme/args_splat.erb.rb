#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    class Lft < Cl::Cmd
      register :lft

      arg :a, type: :array, splat: true
      arg :b
      arg :c

      def run
        p [a, b, c]
      end
    end

    class Mid < Cl::Cmd
      register :mid

      arg :a
      arg :b, type: :array, splat: true
      arg :c

      def run
        p [a, b, c]
      end
    end

    class Rgt < Cl::Cmd
      register :rgt

      arg :a
      arg :b
      arg :c, type: :array, splat: true

      def run
        p [a, b, c]
      end
    end
  rb
-%>

<%= run "Cl.new('splat').run(%w(lft 1 2 3 4 5))" %>

<%= out '[["1", "2", "3"], "4", "5"]' %>

<%= run "Cl.new('splat').run(%w(mid 1 2 3 4 5))" %>

<%= out '["1", ["2", "3", "4"], "5"]' %>

<%= run "Cl.new('splat').run(%w(rgt 1 2 3 4 5))" %>

<%= out '["1", "2", ["3", "4", "5"]]' %>
