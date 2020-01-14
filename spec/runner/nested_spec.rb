describe Cl, 'nested' do
  let!(:a) do
    Class.new(Cl::Cmd) do
      register 'nested:a'
      arg :foo
      opt('-a') { opts[:a] = true }
    end
  end

  let!(:b) do
    Class.new(a) do
      register 'nested:a:b'
      arg :bar
      opt('-b') { opts[:b] = true }
    end
  end

  let!(:c) do
    Class.new(b) do
      register 'nested:a:b:c'
      opt('-c') { opts[:c] = true }
    end
  end

  let(:args) { %w(nested a b c d e -a -b -c) }

  it { expect(a.opts.map(&:first).flatten).to eq %w(-a --help) }
  it { expect(b.opts.map(&:first).flatten).to eq %w(-b -a --help) }
  it { expect(c.opts.map(&:first).flatten).to eq %w(-c -b -a --help) }

  it { expect(cmd).to be_a c }
  it { expect(cmd.args).to eq %w(d e) }
  it { expect(cmd.opts).to eq a: true, b: true, c: true }
end
