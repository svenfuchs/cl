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
        examples 'Examples for using the a'

        arg :foo, 'The foo', required: true, type: :integer
        args :bar, :baz

        opt '-a', '--aaa', 'the flag A'
        opt '-b', '--bbb BBB', 'the value B', example: 'B', see: 'http://docs.com/b', note: 'note'
        opt '--ccc CCC', 'the extra C'
      end

      Class.new(base) do
        register :'test:b'

        summary 'Use this to b the b'

        opt '-a', '--aaa', 'the flag A'
        opt '-b', '--bbb BBB', 'the value B'
      end
    end

    before { run }

    describe 'listing commands' do
      let(:args) { ['help'] }

      it do
        expect(ctx.stdout.string).to eq unindent(<<-str)
         Type "cl help COMMAND [SUBCOMMAND]" for more details:

         cl test a foo:int [bar] [baz] [options]         Use this to a the a
         cl test b [options]                             Use this to b the b
        str
      end
    end

    describe 'command details' do
      let(:args) { ['test', 'a', '--help'] }

      it do
        expect(ctx.stdout.string).to eq unindent(<<-str)
          Usage: cl test a foo:int [bar] [baz] [options]

          Summary:

            Use this to a the a

          Description:

            Description of the a

          Arguments:

            foo                The foo (type: integer, required: true)
            bar                type: string
            baz                type: string

          Options:

            -a --[no-]aaa      the flag A
            -b --bbb BBB       the value B (type: string, e.g.: B, note: note, see: http://docs.com/b)
               --ccc CCC       the extra C (type: string)

          Common Options:

            -d --ddd DDD       the inherited D (type: string)
               --eee EEE       the inherited E (type: string)
               --help          Get help on this command

          Examples:

            Examples for using the a
        str
      end
    end
  end
end
