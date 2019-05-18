describe Cl, 'multi' do
  let!(:a) do
    Class.new(Cl::Cmd) do
      register 'rakeish:foo'
      arg :a, type: :int
      arg :b, type: :int
      opt('-c') { opts[:c] = true }
    end
  end

  let!(:b) do
    Class.new(Cl::Cmd) do
      register 'rakeish:bar'
      arg :d, type: :int
      opt('-e') { opts[:e] = true }
    end
  end

  let(:runner) { Cl.new(ctx, runner: :multi).runner(args) }
  let(:args)   { %w(rakeish:foo 1 2 -c rakeish:bar 3 -e) }

  it { expect(runner.cmds[0]).to be_a a }
  it { expect(runner.cmds[0].args).to eq [1, 2] }
  it { expect(runner.cmds[0].opts).to eq c: true }

  it { expect(runner.cmds[1]).to be_a b }
  it { expect(runner.cmds[1].args).to eq [3] }
  it { expect(runner.cmds[1].opts).to eq e: true }
end
