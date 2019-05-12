describe Cl, 'help' do
  before do
    Cl::Help.register :help
    const = Class.new(Cl::Cmd, &opts)
    const.register :a
  end

  let(:args) { ['a', '--help'] }
  before { run }

  describe 'default: str' do
    let(:opts) { ->(*) { opt '--aaa AAA', default: 'str' } }

    it do
      expect(ctx.stdout.string).to eq <<~str
        Usage: rspec a [options]

        Options:

          --aaa AAA      type: string, default: str
          --help         Get help on this command (type: flag)
      str
    end
  end

  describe 'default: sym' do
    let(:opts) { ->(*) { opt '--aaa AAA', default: :foo_bar } }

    it do
      expect(ctx.stdout.string).to eq <<~str
        Usage: rspec a [options]

        Options:

          --aaa AAA      type: string, default: foo bar
          --help         Get help on this command (type: flag)
      str
    end
  end

  describe 'default: true on a flag' do
    let(:opts) { ->(*) { opt '--aaa', default: true } }

    it do
      expect(ctx.stdout.string).to eq <<~str
        Usage: rspec a [options]

        Options:

          --[no-]aaa      type: flag, default: true
          --help          Get help on this command (type: flag)
      str
    end
  end
end
