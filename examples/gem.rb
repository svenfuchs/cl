require 'cl'

module Gem
  module Release
    module Cmds
      class Release < Cl::Cmd
        arg :gemspec

        opt '-h', '--host HOST' do |value|
          opts[:host] = value
        end

        opt '-k', '--key KEY' do |value|
          opts[:key] = value
        end

        opt '-q', '--quiet' do
          opts[:version] = true
        end

        def run
          [self.registry_key, args, opts]
        end
      end

      class Bump < Cl::Cmd
        OPTS = {
          commit: true
        }

        opt '-v', '--version VERSION', 'the version to bump to [1.1.1|major|minor|patch|pre|rc|release]' do  |value|
          opts[:version] = value
        end

        opt '--no-commit', 'bump the version, but do not commit' do
          opts[:commit] = false
        end

        def run
          [self.registry_key, args, opts]
        end
      end
    end
  end
end

Cl.runner = :multi
Cl.run($1, *%w(help))
puts

# Type "gem.rb help COMMAND [SUBCOMMAND]" for more details:
#
# gem.rb release [gemspec] [options]
# gem.rb bump [options]

Cl.run($1, *%w(help release))
puts

# Usage: gem.rb release [gemspec] [options]
#
# -h --host HOST
# -k --key KEY
# -q --quiet

Cl.run($1, *%w(help bump))
puts

# Usage: gem.rb bump [options]
#
# -v --version VERSION # the version to bump to [1.1.1|major|minor|patch|pre|rc|release]
# --no-commit          # bump the version, but do not commit

cmds = Cl.run($1, *%w(bump -v 1.1.1 release foo.gemspec -h host -k key -q))
puts 'Commands run:'
cmds.each do |(cmd, args, opts)|
  puts "#{cmd} with args=#{args} opts=#{opts}"
end

# Commands run:
# bump with args=[] opts={:version=>"1.1.1"}
# release with args=["foo.gemspec"] opts={:host=>"host", :key=>"key", :version=>true}
