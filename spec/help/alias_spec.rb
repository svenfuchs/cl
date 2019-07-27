describe Cl, 'help' do
  before do
    Cl::Help.register :help

    Class.new(Cl::Cmd) do
      register :a
      opt '--aaa AAA', alias: :bbb
    end
  end

  describe 'command details' do
    let(:args) { ['a', '--help'] }

    before { run }

    it do
      expect(ctx.stdout.string).to eq unindent(<<-str)
        Usage: cl a [options]

        Options:

          --aaa AAA      type: string, alias: bbb
          --help         Get help on this command
      str
    end
  end
end
