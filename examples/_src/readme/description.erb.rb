#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
  require 'cl'

  module Owners
    class Add < Cl::Cmd
      register :add

      summary 'Add one or more owners to an existing owner group'

      description <<~str
        Use this command to add one or more owners to an existing
        owner group.
      str

      examples <<~str
        Adding a single user to the group admins:

          owners add user --to admins

        Adding a several users at once:

          owners add one two three --to admins
      str
    end
  end
  rb
-%>

<%= run "Cl.new('owners').run(%w(add --help))" %>

<%= out sq(<<-'str')
  Usage: owners add [options]

  Summary:

    Add one or more owners to an existing owner group

  Description:

    Use this command to add one or more owners to an existing
    owner group.

  Options:

    --help      Get help on this command

  Examples:

    Adding a single user to the group admins:

      owners add user --to admins

    Adding a several users at once:

      owners add one two three --to admins
  str
%>
