#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
  class Add < Cl::Cmd
    register :add

    opt '--pass PASS', secret: true

    def run
      p(
        secret?: self.class.opts[:pass].secret?,
        tainted?: pass.tainted?
      )
    end
  end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add --pass pass))" %>

<%= out '{:secret?=>true, :tainted?=>true}' %>
