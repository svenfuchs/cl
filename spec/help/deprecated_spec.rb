describe Cl, 'help' do
  before do
    Cl::Help.register :help
    const = Class.new(Cl::Cmd, &opts)
    const.register :a
  end

  let(:args) { ['a', '--help'] }
  before { run }

  describe 'deprecated: true' do
    let(:opts) { ->(*) { opt '--aaa AAA', deprecated: 'msg' } }

    it do
      expect(ctx.stdout.string).to eq unindent(<<-str)
        Usage: rspec a [options]

        Options:

          --aaa AAA      type: string, deprecated (msg)
          --help         Get help on this command (type: flag)
      str
    end
  end

  describe 'deprecated: alias' do
    let(:opts) { ->(*) { opt '--aaa AAA', alias: :bbb, deprecated: :bbb } }

    it do
      expect(ctx.stdout.string).to eq unindent(<<-str)
        Usage: rspec a [options]

        Options:

          --aaa AAA      type: string, alias: bbb (deprecated, please use aaa)
          --help         Get help on this command (type: flag)
      str
    end
  end
end
