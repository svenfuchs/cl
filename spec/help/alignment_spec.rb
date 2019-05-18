describe Cl, 'help' do
  describe 'alignment (long common opt)' do
    before do
      Cl::Help.register :help

      base = Class.new(Cl::Cmd) do
        opt '--bbbbbbbbb bbbbbbbbb', 'The long B'
      end

      Class.new(base) do
        register :'test:a'
        opt '-a', '--aaa aaa', 'The short A'
      end
    end

    before { run }

    describe 'listing commands' do
      let(:args) { ['help', 'test:a'] }

      it do
        expect(ctx.stdout.string).to eq unindent(<<-str)
          Usage: rspec test a [options]

          Options:

            -a --aaa aaa               The short A (type: string)

          Common Options:

            --bbbbbbbbb bbbbbbbbb      The long B (type: string)
            --help                     Get help on this command
        str
      end
    end
  end

  describe 'alignment (long opt)' do
    before do
      Cl::Help.register :help

      base = Class.new(Cl::Cmd) do
        opt '--bbb bbb', 'The short B'
      end

      Class.new(base) do
        register :'test:a'
        opt '-a', '--aaaaaaaaa aaaaaaaaa', 'The long A'
      end
    end

    before { run }

    describe 'listing commands' do
      let(:args) { ['help', 'test:a'] }

      it do
        expect(ctx.stdout.string).to eq unindent(<<-str)
          Usage: rspec test a [options]

          Options:

            -a --aaaaaaaaa aaaaaaaaa      The long A (type: string)

          Common Options:

            --bbb bbb                     The short B (type: string)
            --help                        Get help on this command
        str
      end
    end
  end
end
