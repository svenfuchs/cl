describe Cl, 'help' do
  before do
    Cl::Help.register :help

    Class.new(Cl::Cmd) do
      register :a
      opt '--aaa AAA', enum: %w(one two)
    end
  end

  describe 'command details' do
    let(:args) { ['a', '--help'] }

    before { run }

    it do
      expect(ctx.stdout.string).to eq <<~str
        Usage: rspec a [options]

        Options:

          --aaa AAA      type: string, known values: one, two
          --help         Get help on this command (type: flag)
      str
    end
  end
end
