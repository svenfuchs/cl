describe Cl, 'help' do
  describe 'no commands' do
    before do
      Cl::Help.register :help
    end

    describe 'listing commands' do
      let(:args) { ['help'] }

      before { run }

      it do
        expect(ctx.stdout.string).to eq <<~str
         Type "rspec help COMMAND [SUBCOMMAND]" for more details:

         [no commands]
        str
      end
    end

    describe 'command details' do
      let(:args) { ['help', 'test:a'] }

      it { expect { run }.to raise_error 'Unknown command: test:a' }
    end
  end
end
