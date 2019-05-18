describe Cl, 'basic' do
  let!(:a) do
    Class.new(Cl::Cmd) do
      register :a
      opt('-a') { opts[:a] = true }
    end
  end

  let!(:b) do
    Class.new(Cl::Cmd) do
      register :b
      opt('-a') { opts[:a] = true }
      opt('-b') { opts[:b] = true }
    end
  end

  describe 'args and opts' do
    let(:args) { %w(b c d -b) }
    it { expect(cmd).to be_a b }
    it { expect(cmd.args).to eq %w(c d) }
    it { expect(cmd.opts).to eq b: true }
    it { expect(b.opts.map(&:strs).flatten).to eq %w(-a -b --help) }
  end

  describe 'unknown cmd' do
    let(:args) { %w(unknown a b) }
    it { expect { cmd }.to raise_error 'Unknown command: unknown a b' }
  end
end
