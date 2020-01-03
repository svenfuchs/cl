describe Cl, 'help' do
  describe 'requireds' do
    before do
      Cl::Help.register :help

      Class.new(Cl::Cmd) do
        register :a
        required :aaa, [:bbb, :ccc]
        opt '--aaa AAA'
        opt '--bbb BBB'
        opt '--ccc CCC'
      end
    end

    describe 'command details' do
      let(:args) { ['a', '--help'] }

      before { run }

      it do
        expect(ctx.stdout.string).to eq unindent(<<-str)
          Usage: cl a [options]

          Options:

            Either aaa, or bbb and ccc are required.

            --aaa AAA      type: string
            --bbb BBB      type: string
            --ccc CCC      type: string
            --help         Get help on this command
        str
      end
    end
  end

  describe 'required' do
    before do
      Cl::Help.register :help

      base = Class.new(Cl::Cmd) do
        opt '--bbb BBB', required: true
      end

      Class.new(base) do
        register :a
        opt '--aaa AAA', required: true
      end
    end

    describe 'command details' do
      let(:args) { ['a', '--help'] }

      before { run }

      it do
        expect(ctx.stdout.string).to eq unindent(<<-str)
          Usage: cl a [options]

          Options:

            --aaa AAA      type: string, required

          Common Options:

            --bbb BBB      type: string, required
            --help         Get help on this command
        str
      end
    end
  end

  describe 'requires' do
    before do
      Cl::Help.register :help

      base = Class.new(Cl::Cmd) do
        opt '--ccc CCC'
      end

      Class.new(base) do
        register :a
        opt '--aaa AAA', requires: [:bbb, :ccc]
        opt '--bbb BBB'
      end
    end

    describe 'command details' do
      let(:args) { ['a', '--help'] }

      before { run }

      it do
        expect(ctx.stdout.string).to eq unindent(<<-str)
          Usage: cl a [options]

          Options:

            --aaa AAA      type: string, requires: bbb, ccc
            --bbb BBB      type: string

          Common Options:

            --ccc CCC      type: string
            --help         Get help on this command
        str
      end
    end
  end
end
