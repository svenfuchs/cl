describe Cl, 'multi' do
  let!(:a) do
    Class.new(Cl::Cmd) do
      register 'rakeish:foo'
      arg :a, type: :int
      arg :b, type: :int
      opt('-c') { opts[:c] = true }
      def run; [args, opts] end
    end
  end

  let!(:b) do
    Class.new(Cl::Cmd) do
      register 'rakeish:bar'
      arg :d, type: :int
      opt('-e') { opts[:e] = true }
      def run; [args, opts] end
    end
  end

  let(:runner) { Cl.new(ctx, runner: :multi).runner(args) }
  let(:args)   { %w(rakeish:foo 1 2 -c rakeish:bar 3 -e) }

  it { expect(runner.cmds[0]).to be_a a }
  it { expect(runner.cmds[0].args).to eq [1, 2] }
  it { expect(runner.run[0][0]).to eq [1, 2] }
  it { expect(runner.run[0][1]).to eq c: true }

  it { expect(runner.cmds[1]).to be_a b }
  it { expect(runner.cmds[1].args).to eq [3] }
  it { expect(runner.run[1][0]).to eq [3] }
  it { expect(runner.run[1][1]).to eq e: true }
end
