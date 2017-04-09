describe Cl, 'help' do
  before do
    module Cmds
      module Help
        class A
          include Cl::Cmd
          purpose 'Use this to a the a'
          args :foo, :bar
          opts.clear
          on('-a', '--aaa', 'the flag A') { opts[:a] = true }
          on('-b', '--bbb BBB', 'the value B') { |b| opts[:b] = b }
          register 'basic:a'
        end

        class B
          include Cl::Cmd
          purpose 'Use this to b the b'
          opts.clear
          on('-a', '--aaa', 'the flag A') { opts[:a] = true }
          on('-b', '--bbb BBB', 'the value B') { |b| opts[:b] = b }
          register 'basic:b'
        end
      end
    end
  end

  before { Cl::Help.register :help }
  after  { Cl.registry.clear }

  it do
    expect(Cl::Runner.new('help').cmd.help).to eq <<~help.chomp
      Type "/usr/local/bin/rspec help COMMAND [SUBCOMMAND]" for more details:

      /usr/local/bin/rspec basic a [foo] [bar] [options] # Use this to a the a
      /usr/local/bin/rspec basic b [options]             # Use this to b the b
    help
  end

  it do
    expect(Cl::Runner.new('help', 'basic', 'a').cmd.help).to eq <<~help.chomp
      Use this to a the a

      Usage: basic a [foo] [bar] [options]

      -a --aaa     # the flag A
      -b --bbb BBB # the value B
    help
  end
end
