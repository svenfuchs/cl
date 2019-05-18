describe Cl, 'help' do
  describe 'format' do
    before do
      Cl::Help.register :help

      Class.new(Cl::Cmd) do
        register :a
        opt '--aaa AAA'
        opt '--bbb BBB', internal: true
      end
    end

    describe 'command details' do
      let(:args) { ['a', '--help'] }

      before { run }

      it do
        expect(ctx.stdout.string).to eq unindent(<<-str)
          Usage: rspec a [options]

          Options:

            --aaa AAA      type: string
            --help         Get help on this command
        str
      end
    end
  end
end
