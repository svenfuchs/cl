describe Cl, 'help' do
  let(:args) { ['a', '--help'] }

  before do
    Cl::Help.register :help
    Class.new(Cl::Cmd, &body).register :a
  end

  before { run }

  describe 'min' do
    let(:body) { ->(*) { opt '--aaa AAA', type: :integer, min: 1 } }

    it do
      expect(ctx.stdout.string).to eq unindent(<<-str)
        Usage: cl a [options]

        Options:

          --aaa AAA      type: integer, min: 1
          --help         Get help on this command
      str
    end
  end

  describe 'max' do
    let(:body) { ->(*) { opt '--aaa AAA', type: :integer, max: 5 } }

    it do
      expect(ctx.stdout.string).to eq unindent(<<-str)
        Usage: cl a [options]

        Options:

          --aaa AAA      type: integer, max: 5
          --help         Get help on this command
      str
    end
  end

  describe 'min and max' do
    let(:body) { ->(*) { opt '--aaa AAA', type: :integer, min: 1, max: 5 } }

    it do
      expect(ctx.stdout.string).to eq unindent(<<-str)
        Usage: cl a [options]

        Options:

          --aaa AAA      type: integer, min: 1, max: 5
          --help         Get help on this command
      str
    end
  end
end
