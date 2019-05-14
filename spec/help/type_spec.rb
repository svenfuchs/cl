describe Cl, 'help' do
  before do
    Cl::Help.register :help
    const = Class.new(Cl::Cmd, &opts)
    const.register :a
  end

  let(:args) { ['a', '--help'] }

  before { run }

  describe 'type :int' do
    let(:opts) { ->(*) { opt '--aaa AAA', type: :int } }

    it do
      expect(ctx.stdout.string).to eq unindent(<<-str)
        Usage: rspec a [options]

        Options:

          --aaa AAA      type: integer
          --help         Get help on this command (type: flag)
      str
    end
  end

  describe 'type :array' do
    let(:opts) { ->(*) { opt '--aaa AAA', type: :array } }

    it do
      expect(ctx.stdout.string).to eq unindent(<<-str)
        Usage: rspec a [options]

        Options:

          --aaa AAA      type: array (string, can be given multiple times)
          --help         Get help on this command (type: flag)
      str
    end
  end
end
