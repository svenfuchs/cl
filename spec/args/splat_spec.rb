describe Cl, 'args splat' do
  let!(:foo) do
    Class.new(Cl::Cmd) do
      register :foo
      arg :a, type: :array, splat: true
      arg :b
      arg :c
    end
  end

  let!(:bar) do
    Class.new(Cl::Cmd) do
      register :bar
      arg :a
      arg :b, type: :array, splat: true
      arg :c
    end
  end

  let!(:baz) do
    Class.new(Cl::Cmd) do
      register :baz
      arg :a
      arg :b
      arg :c, type: :array, splat: true
    end
  end

  describe 'splats (left)' do
    let(:args) { %w(foo a b c d e) }
    it { expect(cmd).to be_a foo }
    it { expect(cmd.a).to eq %w(a b c) }
    it { expect(cmd.b).to eq 'd' }
    it { expect(cmd.c).to eq 'e' }
  end

  describe 'splats (middle)' do
    let(:args) { %w(bar a b c d e) }
    it { expect(cmd).to be_a bar }
    it { expect(cmd.a).to eq 'a' }
    it { expect(cmd.b).to eq %w(b c d) }
    it { expect(cmd.c).to eq 'e' }
  end

  describe 'splats (right)' do
    let(:args) { %w(baz a b c d e) }
    it { expect(cmd).to be_a baz }
    it { expect(cmd.a).to eq 'a' }
    it { expect(cmd.b).to eq 'b' }
    it { expect(cmd.c).to eq %w(c d e) }
  end

  describe 'does not raise on missing arguments (empty splat, 1)' do
    let(:args) { %w(foo) }
    it { expect { cmd }.to_not raise_error }
  end

  describe 'does not raise on missing arguments (empty splat, 2)' do
    let(:args) { %w(bar a) }
    it { expect { cmd }.to_not raise_error }
  end

  describe 'does not raise on missing arguments (empty splat, 3)' do
    let(:args) { %w(baz a b) }
    it { expect { cmd }.to_not raise_error }
  end
end
