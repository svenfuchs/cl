describe Cl, 'basic' do
  let!(:a) do
    Class.new(Cl::Cmd) do
      register :a
      opt('-a') { opts[:a] = true }
      def run; [args, opts] end
    end
  end

  let!(:b) do
    Class.new(Cl::Cmd) do
      register :b
      opt('-b') { opts[:b] = true }
      def run; [args, opts] end
    end
  end

  let(:cl) { Cl.runner(ctx, %w(b c d -b)) }

  it { expect(cl.cmd).to be_a b }
  it { expect(cl.run[0]).to eq %w(c d) }
  it { expect(cl.run[1]).to eq b: true }
end
