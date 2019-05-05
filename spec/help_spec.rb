describe Cl, 'help' do
  describe 'full example' do
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

    before { Cl.runner(ctx, *args).cmd.run }

    describe 'listing commands' do
      let(:args) { ['help'] }

      it do
        expect(ctx.stdout.string).to eq <<~str
         Type "rspec help COMMAND [SUBCOMMAND]" for more details:

         rspec test a foo:int [bar] [baz] [options]         Use this to a the a
         rspec test b [options]                             Use this to b the b
        str
      end
    end

    describe 'command details' do
      let(:args) { ['help', 'test:a'] }

      it do
        expect(ctx.stdout.string).to eq <<~str
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
  end

  describe 'no commands' do
    before do
      Cl::Help.register :help
    end

    describe 'listing commands' do
      let(:args) { ['help'] }

      before { Cl.runner(ctx, *args).cmd.run }

      it do
        expect(ctx.stdout.string).to eq <<~str
         Type "rspec help COMMAND [SUBCOMMAND]" for more details:

         [no commands]
        str
      end
    end

    describe 'command details' do
      let(:args) { ['help', 'test:a'] }

      it { expect { Cl.runner(ctx, *args).cmd.run }.to raise_error 'Unknown command: test:a' }
    end
  end

  describe 'alignment (long common opt)' do
    before do
      Cl::Help.register :help

      base = Class.new(Cl::Cmd) do
        opt '--bbbbbbbbb bbbbbbbbb', 'the long B'
      end

      Class.new(base) do
        register :'test:a'
        opt '-a', '--aaa aaa', 'the short A'
      end
    end

    before { Cl.runner(ctx, *args).cmd.run }

    describe 'listing commands' do
      let(:args) { ['help', 'test:a'] }

      it do
        expect(ctx.stdout.string).to eq <<~str
          Usage: rspec test a [options]

          Options:

            -a --aaa aaa               the short A

          Common Options:

            --bbbbbbbbb bbbbbbbbb      the long B
        str
      end
    end
  end

  describe 'alignment (long opt)' do
    before do
      Cl::Help.register :help

      base = Class.new(Cl::Cmd) do
        opt '--bbb bbb', 'the short B'
      end

      Class.new(base) do
        register :'test:a'
        opt '-a', '--aaaaaaaaa aaaaaaaaa', 'the long A'
      end
    end

    before { Cl.runner(ctx, *args).cmd.run }

    describe 'listing commands' do
      let(:args) { ['help', 'test:a'] }

      it do
        expect(ctx.stdout.string).to eq <<~str
          Usage: rspec test a [options]

          Options:

            -a --aaaaaaaaa aaaaaaaaa      the long A

          Common Options:

            --bbb bbb                     the short B
        str
      end
    end
  end
end
