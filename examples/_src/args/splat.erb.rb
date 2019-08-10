#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    module Splat
      class Left < Cl::Cmd
        register :left

        arg :one, type: :array, splat: true
        args :two, :three

        def run
          p cmd: registry_key, one: one, two: two, three: three
        end
      end

      class Middle < Cl::Cmd
        register :middle

        arg :one
        arg :two, type: :array, splat: true
        arg :three

        def run
          p cmd: registry_key, one: one, two: two, three: three
        end
      end

      class Right < Cl::Cmd
        register :right

        args :one, :two
        arg :three, type: :array, splat: true

        def run
          p cmd: registry_key, one: one, two: two, three: three
        end
      end
    end
  rb
-%>

<%= run "Cl.new('splat').run(%w(left foo bar baz buz))" %>

<%= out '{:cmd=>:left, :one=>["foo", "bar"], :two=>"baz", :three=>"buz"}' %>

<%= run "Cl.new('splat').run(%w(middle foo bar baz buz))" %>

<%= out '{:cmd=>:middle, :one=>"foo", :two=>["bar", "baz"], :three=>"buz"}' %>

<%= run "Cl.new('splat').run(%w(right foo bar baz buz))" %>

<%= out '{:cmd=>:right, :one=>"foo", :two=>"bar", :three=>["baz", "buz"]}' %>
