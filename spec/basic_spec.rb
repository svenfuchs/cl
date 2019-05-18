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
      opt('-a') { opts[:a] = true }
      opt('-b') { opts[:b] = true }
      def run; [args, opts] end
    end
  end

  let(:args) { %w(b c d -b) }

  it { expect(cmd).to be_a b }
  it { expect(cmd.run[0]).to eq %w(c d) }
  it { expect(cmd.run[1]).to eq b: true }

  it { expect(b.opts.map(&:strs).flatten).to eq %w(-a -b --help) }
end
