describe Cl, 'help' do
  before do
    module Cmds
      module Help
        class A < Cl::Cmd
          cmd 'Use this to a the a'
          args :foo, :bar
          opts.clear
          opt('-a', '--aaa', 'the flag A') { opts[:a] = true }
          opt('-b', '--bbb BBB', 'the value B') { |b| opts[:b] = b }
          register 'basic:a'
        end

        class B < Cl::Cmd
          cmd 'Use this to b the b'
          opts.clear
          opt('-a', '--aaa', 'the flag A') { opts[:a] = true }
          opt('-b', '--bbb BBB', 'the value B') { |b| opts[:b] = b }
          register 'basic:b'
        end
      end
    end
  end

  before { Cl::Help.register :help }
  before { Cl.registry.delete_if { |key, _| key.to_s !~ /(help|basic)/ } }
  after  { Cmds.send(:remove_const, :Help) }

  describe 'listing commands' do
    let(:help) { Cl.runner('help').cmd.help }

    it do
      expect(help).to include <<~str.chomp
        Type "rspec help COMMAND [SUBCOMMAND]" for more details:
      str
    end

    it do
      expect(help).to include <<~str.chomp
        rspec basic a [foo] [bar] [options] # Use this to a the a
        rspec basic b [options]             # Use this to b the b
      str
    end
  end

  it 'command details' do
    expect(Cl.runner('help', 'basic', 'a').cmd.help).to include <<~help.chomp
      Use this to a the a

      Usage: rspec basic a [foo] [bar] [options]

      -a --aaa     # the flag A
      -b --bbb BBB # the value B
    help
  end
end
