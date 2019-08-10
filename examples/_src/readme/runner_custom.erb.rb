<%= run sq(<<-'rb')
  # anywhere in your library

  require 'cl'

  class Runner
    Cl::Runner.register :custom, self

    def initialize(ctx, args)
      # ...
    end

    def run
      const = identify_cmd_class_from_args
      const.new(ctx, args).run
    end
  end
  rb
-%>

# in bin/run
Cl.new('run', runner: :custom).run(ARGV)

<% run "p Cl.new('run', runner: :custom).runner([]).class" %>
<% out 'Runner' %>
