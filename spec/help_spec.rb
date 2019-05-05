describe Cl, 'help' do
  before do
    Cl::Help.register :help

    Class.new(Cl::Cmd) do
      register :'test:a'

      summary 'Use this to a the a'

      arg :foo, 'The foo', required: true, type: :integer
      args :bar, :baz

      opt('-a', '--aaa', 'the flag A') { opts[:a] = true }
      opt('-b', '--bbb BBB', 'the value B') { |b| opts[:b] = b }
      opt('--ccc CCC', 'the extra C') { |c| opts[:c] = c }
    end

    Class.new(Cl::Cmd) do
      register :'test:b'

      summary 'Use this to b the b'

      opt('-a', '--aaa', 'the flag A') { opts[:a] = true }
      opt('-b', '--bbb BBB', 'the value B') { |b| opts[:b] = b }
    end
  end

  describe 'listing commands' do
    it do
      expect(Cl.runner('help').cmd.help).to include <<~str.chomp
       Type "rspec help COMMAND [SUBCOMMAND]" for more details:

       rspec test a foo:int [bar] [baz] [options]         Use this to a the a
       rspec test b [options]                             Use this to b the b
      str
    end
  end

  it 'command details' do
    expect(Cl.runner('help', 'test:a').cmd.help).to include <<~str.chomp
      Usage: rspec test a foo:int [bar] [baz] [options]

      Arguments:

        foo               The foo (integer, required)
        bar
        baz

      Options:

        -a --aaa          the flag A (boolean)
        -b --bbb BBB      the value B
           --ccc CCC      the extra C

      Summary:

        Use this to a the a
    str
  end
end
