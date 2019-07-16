describe Cl, 'help' do
  before do
    Cl::Help.register :help
    const = Class.new(Cl::Cmd, &opts)
    const.register :a
  end

  describe 'flag, dasherized' do
    let(:opts) { ->(*) { opt '--a-flag', 'A flag' } }
    let(:args) { ['a', '--help'] }
    before { run }

    it do
      expect(ctx.stdout.string).to eq unindent(<<-str)
        Usage: rspec a [options]

        Options:

          --[no-]a-flag      A flag
          --help             Get help on this command
      str
    end
  end

  describe 'flag, underscored' do
    let(:opts) { ->(*) { opt '--a_flag', 'A flag' } }
    let(:args) { ['a', '--help'] }
    before { run }

    it do
      expect(ctx.stdout.string).to eq unindent(<<-str)
        Usage: rspec a [options]

        Options:

          --[no-]a_flag      A flag
          --help             Get help on this command
      str
    end
  end
end
