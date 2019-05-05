describe Cl, 'help' do
  before do
    Cl::Help.register :help

    base = Class.new(Cl::Cmd) do
      opt '-d', '--ddd DDD', 'the inherited D'
      opt '--eee EEE', 'the inherited E'
    end

    Class.new(base) do
      register :'test:a'

      summary 'Use this to a the a'
      description 'Description of the a'

      arg :foo, 'The foo', required: true, type: :integer
      args :bar, :baz

      opt '-a', '--aaa', 'the flag A'
      opt '-b', '--bbb BBB', 'the value B'
      opt '--ccc CCC', 'the extra C'
    end

    Class.new(base) do
      register :'test:b'

      summary 'Use this to b the b'

      opt '-a', '--aaa', 'the flag A'
      opt '-b', '--bbb BBB', 'the value B'
    end
  end

  describe 'listing commands' do
    it do
      expect(Cl.runner('help').cmd.help).to eq <<~str.chomp
       Type "rspec help COMMAND [SUBCOMMAND]" for more details:

       rspec test a foo:int [bar] [baz] [options]         Use this to a the a
       rspec test b [options]                             Use this to b the b
      str
    end
  end

  it 'command details' do
    expect(Cl.runner('help', 'test:a').cmd.help).to eq <<~str.chomp
      Usage: rspec test a foo:int [bar] [baz] [options]

      Arguments:

        foo               The foo (integer, required)
        bar
        baz

      Options:

        -a --aaa          the flag A (boolean)
        -b --bbb BBB      the value B
           --ccc CCC      the extra C

      Common Options:

        -d --ddd DDD      the inherited D
           --eee EEE      the inherited E

      Summary:

        Use this to a the a

      Description:

        Description of the a
    str
  end
end
