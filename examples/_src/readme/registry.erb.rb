#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
  module Cmd
    class One < Cl::Cmd
      register :one
    end

    class Two < Cl::Cmd
      register :two
    end
  end
  rb
-%>

<%= run 'p Cl::Cmd[:one]' %> <%= out 'Cmd::One', short: true %>
<%= run 'p Cl::Cmd[:two]' %> <%= out 'Cmd::Two', short: true %>
