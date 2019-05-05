describe Cl, 'nested' do
  let!(:a) do
    Class.new(Cl::Cmd) do
      register 'nested:a'
      opt('-a') { opts[:a] = true }
    end
  end

  let!(:b) do
    Class.new(a) do
      register 'nested:a:b'
      opt('-b') { opts[:b] = true }
    end
  end

  let!(:c) do
    Class.new(b) do
      register 'nested:a:b:c'
      opt('-c') { opts[:c] = true }
    end
  end

  let(:cl) { Cl.runner(ctx, %w(nested a b c d e -a -b -c)) }

  it { expect(a.opts.map(&:first).flatten).to eq %w(-a) }
  it { expect(b.opts.map(&:first).flatten).to eq %w(-a -b) }
  it { expect(c.opts.map(&:first).flatten).to eq %w(-a -b -c) }

  it { expect(cl.cmd).to be_a c }
  it { expect(cl.args).to eq %w(d e) }
  it { expect(cl.opts).to eq a: true, b: true, c: true }
end
