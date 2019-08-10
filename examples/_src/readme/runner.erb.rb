#!/usr/bin/env ruby
$: << File.expand_path('lib')

<%= run sq(<<-'rb')
  module Git
    class Pull < Cl::Cmd
      register :'git:pull'

      def run
        p cmd: registry_key, args: args
      end
    end
  end
  rb
-%>

# With this class registered (and assuming the executable that calls `Cl` is
# `bin/run`) the default runner would recognize and run it:
#
# ```
# $ bin/run git:pull master # instantiates Git::Pull, and passes ["master"] as args
# $ bin/run git pull master # does the same
# ```

<%= run "Cl.new('run').run(%w(git:pull master))" %>
<%= out '{:cmd=>:"git:pull", :args=>["master"]}' %>

<%= run "Cl.new('run').run(%w(git pull master))" %>
<%= out '{:cmd=>:"git:pull", :args=>["master"]}' %>
