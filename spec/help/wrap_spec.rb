describe Cl, 'help' do
  before do
    Cl::Help.register :help
    const = Class.new(Cl::Cmd, &opts)
    const.register :a
  end

  describe 'enum' do
    let(:opts) { ->(*) { opt '--aaa AAA', 'The quick brown fox jumps over the lazy dog ' * 5 } }
    let(:args) { ['a', '--help'] }
    before { run }

    it do
      expect(ctx.stdout.string).to eq <<~str
        Usage: rspec a [options]

        Options:

          --aaa AAA      The quick brown fox jumps over the lazy dog The quick brown fox jumps over the
                         lazy dog The quick brown fox jumps over the lazy dog The quick brown fox jumps
                         over the lazy dog The quick brown fox jumps over the lazy dog (type: string)
          --help         Get help on this command (type: flag)
      str
    end
  end
end
