describe Cl, 'args inheritance' do
  let!(:foo) do
    Class.new(Cl::Cmd) do
      register :foo
      arg :a
    end
  end

  let!(:bar) do
    Class.new(foo) do
      register :'foo:bar'
      arg :b
    end
  end

  describe 'parent' do
    let(:args) { %w(foo 1) }
    it { expect(cmd.args).to eq %w(1) }
  end

  describe 'child' do
    let(:args) { %w(foo bar 1 2) }
    it { expect(cmd.args).to eq %w(1 2) }
  end
end
