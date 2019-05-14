describe Cl, 'help' do
  describe 'format' do
    before do
      Cl::Help.register :help

      Class.new(Cl::Cmd) do
        register :a
        opt '--aaa AAA', type: :integer, max: 5
      end
    end

    describe 'command details' do
      let(:args) { ['a', '--help'] }

      before { run }

      it do
        expect(ctx.stdout.string).to eq <<~str
          Usage: rspec a [options]

          Options:

            --aaa AAA      type: integer, max: 5
            --help         Get help on this command (type: flag)
        str
      end
    end
  end
end
