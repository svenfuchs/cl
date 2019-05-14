describe Cl, 'help' do
  before do
    Cl::Help.register :help

    base = Class.new(Cl::Cmd) do
      register :a
      abstract
    end

    Class.new(base) do
      register :b
    end
  end

  describe 'listing commands' do
    let(:args) { ['help'] }

    before { run }

    it do
      expect(ctx.stdout.string).to eq <<~str
       Type "rspec help COMMAND [SUBCOMMAND]" for more details:

       rspec b [options]
      str
    end
  end
end
