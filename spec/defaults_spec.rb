describe Cl, 'defaults' do
  let!(:a) do
    Class.new(Cl::Cmd) do
      register 'a'
      defaults a: 'a'
      opt '-a A'
    end
  end

  let!(:b) do
    Class.new(a) do
      register 'a:b'
      defaults b: 'b'
      opt '-b B'
    end
  end

  let!(:c) do
    Class.new(b) do
      register 'a:b:c'
      opt '--c C', default: 'c'
    end
  end

  let!(:d) do
    Class.new(Cl::Cmd) do
      register 'd'
      opt '--d D', default: 'd'
    end
  end

  def opts(args)
    cmd(args).opts
  end

  it { expect(a.defaults).to eq a: 'a' }
  it { expect(b.defaults).to eq a: 'a', b: 'b' }
  it { expect(c.defaults).to eq a: 'a', b: 'b', c: 'c' }

  it { expect(opts(%w(a))[:a]).to eq 'a' }
  it { expect(opts(%w(a))[:b]).to be_nil }
  it { expect(opts(%w(a))[:c]).to be_nil }
  it { expect(opts(%w(a))[:d]).to be_nil }

  it { expect(opts(%w(a b))[:a]).to eq 'a' }
  it { expect(opts(%w(a b))[:b]).to eq 'b' }
  it { expect(opts(%w(a b))[:c]).to be_nil }
  it { expect(opts(%w(a b))[:d]).to be_nil }

  it { expect(opts(%w(a b c))[:a]).to eq 'a' }
  it { expect(opts(%w(a b c))[:b]).to eq 'b' }
  it { expect(opts(%w(a b c))[:c]).to eq 'c' }
  it { expect(opts(%w(a b c))[:d]).to be_nil }

  it { expect(opts(%w(d))[:a]).to be_nil }
  it { expect(opts(%w(d))[:b]).to be_nil }
  it { expect(opts(%w(d))[:c]).to be_nil }
  it { expect(opts(%w(d))[:d]).to eq 'd' }
end
