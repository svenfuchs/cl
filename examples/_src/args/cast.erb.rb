#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
    require 'cl'

    module Cast
      class Bool < Cl::Cmd
        register :bool

        arg :bool, type: :bool

        def run
          p cmd: registry_key, bool: bool
        end
      end

      class Types < Cl::Cmd
        register :types

        arg :a, type: :bool
        arg :b, type: :int
        arg :c, type: :float
        arg :d

        def run
          p cmd: registry_key, a: a, b: b, c: c, d: d
        end
      end
    end
  rb
-%>

<%= run 'Cl.new($0).run(%w(bool on))' %>

<%= out '{:cmd=>:bool, :bool=>true}' %>

<%= run 'Cl.new($0).run(%w(types true 1 1.2 foo))' %>

<%= out '{:cmd=>:types, :a=>true, :b=>1, :c=>1.2, :d=>"foo"}' %>

<%= run 'Cl.new($0).run(%w(types true 1 1.2 foo bar))' %>

<%= out sq(<<-'str')
    Too many arguments: true 1 1.2 foo bar (given: 5, allowed: 4)

    Usage: bin/examples types [a:bool] [b:int] [c:float] [d] [options]

    Arguments:

      a           type: bool
      b           type: int
      c           type: float
      d           type: string

    Options:

      --help      Get help on this command
  str
%>

<%= run 'Cl.new($0).run(%w(types true one 1.2))' %>

<%= out sq(<<-'str')
    Wrong argument type (given: "one", expected: int)

    Usage: bin/examples types [a:bool] [b:int] [c:float] [d] [options]

    Arguments:

      a           type: bool
      b           type: int
      c           type: float
      d           type: string

    Options:

      --help      Get help on this command
  str
%>

<%= run 'Cl.new($0).run(%w(types true 1 one))' %>

<%= out sq(<<-'str')
    Wrong argument type (given: "one", expected: float)

    Usage: bin/examples types [a:bool] [b:int] [c:float] [d] [options]

    Arguments:

      a           type: bool
      b           type: int
      c           type: float
      d           type: string

    Options:

      --help      Get help on this command
  str
%>
