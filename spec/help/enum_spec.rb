describe Cl, 'help' do
  before do
    Cl::Help.register :help
    const = Class.new(Cl::Cmd, &opts)
    const.register :a
  end

  describe 'enum' do
    let(:opts) { ->(*) { opt '--aaa AAA', enum: ['one', /two/] } }
    let(:args) { ['a', '--help'] }
    before { run }

    it do
      expect(ctx.stdout.string).to eq <<~str
        Usage: rspec a [options]

        Options:

          --aaa AAA      type: string, known values: one, /two/
          --help         Get help on this command (type: flag)
      str
    end
  end

  describe 'enum, downcase' do
    let(:opts) { ->(*) { opt '--aaa AAA', enum: %w(one), downcase: true } }
    let(:args) { ['a', '--help'] }
    before { run }

    it do
      expect(ctx.stdout.string).to eq <<~str
        Usage: rspec a [options]

        Options:

          --aaa AAA      type: string, known values: one, downcase: true
          --help         Get help on this command (type: flag)
      str
    end
  end
end
