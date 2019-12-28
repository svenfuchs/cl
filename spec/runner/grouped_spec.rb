describe Cl, 'grouped' do
  let!(:a) do
    Class.new(Cl::Cmd) do
      register 'grouped:a'
      args :foo, :bar
      opt('-a') { opts[:a] = true }
    end
  end

  let!(:b) do
    Class.new(Cl::Cmd) do
      register 'grouped:b'
      args :foo, :bar
      opt('-b') { opts[:b] = true }
      opt('-c') { opts[:c] = true }
      opt('-d') { opts[:d] = true }
    end
  end

  describe 'args (1)' do
    let(:args) { %w(grouped a b c -a) }
    it { expect(a.opts.map(&:first).flatten).to eq %w(-a --help) }
    it { expect(cmd).to be_a a }
    it { expect(cmd.args).to eq %w(b c) }
    it { expect(cmd.opts).to eq a: true }
  end

  describe 'args (2)' do
    let(:args) { %w(grouped b c d -b -c -d) }
    it { expect(b.opts.map(&:first).flatten).to eq %w(-b -c -d --help) }
    it { expect(cmd).to be_a b }
    it { expect(cmd.args).to eq %w(c d) }
    it { expect(cmd.opts).to eq b: true, c: true, d: true }
  end
end
