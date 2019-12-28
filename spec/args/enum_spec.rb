describe Cl, 'args default' do
  let!(:foo) do
    Class.new(Cl::Cmd) do
      register :foo
      arg :a, enum: %w(one two)
    end
  end

  describe 'given one' do
    let(:args) { %w(foo one) }
    it { expect(cmd.args).to eq %w(one) }
    it { expect(cmd.a).to eq 'one' }
  end

  describe 'given two' do
    let(:args) { %w(foo two) }
    it { expect(cmd.args).to eq %w(two) }
    it { expect(cmd.a).to eq 'two' }
  end

  describe 'given three' do
    let(:args) { %w(foo three) }
    it { expect { cmd }.to raise_error Cl::UnknownArgumentValue, 'Unknown argument value: three (known: one, two)' }
  end
end
