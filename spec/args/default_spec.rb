describe Cl, 'args default' do
  describe 'left' do
    let!(:foo) do
      Class.new(Cl::Cmd) do
        register :foo
        arg :a, default: '0'
        arg :b
        arg :c
      end
    end

    describe 'given 1 2 3' do
      let(:args) { %w(foo 1 2 3) }
      it { expect(cmd.args).to eq %w(1 2 3) }
      it { expect(cmd.a).to eq '1' }
      it { expect(cmd.b).to eq '2' }
      it { expect(cmd.c).to eq '3' }
    end

    describe 'given 1 2' do
      let(:args) { %w(foo 1 2) }
      it { expect(cmd.args).to eq %w(1 2) }
      it { expect(cmd.a).to eq '1' }
      it { expect(cmd.b).to eq '2' }
      it { expect(cmd.c).to be_nil }
    end

    describe 'given 1' do
      let(:args) { %w(foo 1) }
      it { expect(cmd.args).to eq %w(1) }
      it { expect(cmd.a).to eq '1' }
      it { expect(cmd.b).to be_nil }
    end

    describe 'given nothing' do
      let(:args) { %w(foo) }
      it { expect(cmd.args).to eq %w(0) }
      it { expect(cmd.a).to eq '0' }
      it { expect(cmd.b).to be_nil }
    end
  end

  describe 'middle' do
    let!(:foo) do
      Class.new(Cl::Cmd) do
        register :foo
        arg :a
        arg :b, default: 0
        arg :c
      end
    end

    describe 'given 1 2 3' do
      let(:args) { %w(foo 1 2 3) }
      it { expect(cmd.args).to eq %w(1 2 3) }
      it { expect(cmd.a).to eq '1' }
      it { expect(cmd.b).to eq '2' }
      it { expect(cmd.c).to eq '3' }
    end

    describe 'given 1 2' do
      let(:args) { %w(foo 1 2) }
      it { expect(cmd.args).to eq %w(1 2) }
      it { expect(cmd.a).to eq '1' }
      it { expect(cmd.b).to eq '2' }
      it { expect(cmd.c).to be_nil }
    end

    describe 'given 1' do
      let(:args) { %w(foo 1) }
      it { expect(cmd.args).to eq %w(1 0) }
      it { expect(cmd.a).to eq '1' }
      it { expect(cmd.b).to eq '0' }
      it { expect(cmd.c).to be_nil }
    end

    describe 'given nothing' do
      let(:args) { %w(foo) }
      it { expect(cmd.args).to eq [nil, '0'] }
      it { expect(cmd.a).to be_nil }
      it { expect(cmd.b).to eq '0' }
      it { expect(cmd.c).to be_nil }
    end
  end

  describe 'right' do
    let!(:foo) do
      Class.new(Cl::Cmd) do
        register :foo
        arg :a
        arg :b
        arg :c, default: 0
      end
    end

    describe 'given 1 2 3' do
      let(:args) { %w(foo 1 2 3) }
      it { expect(cmd.args).to eq %w(1 2 3) }
      it { expect(cmd.a).to eq '1' }
      it { expect(cmd.b).to eq '2' }
      it { expect(cmd.c).to eq '3' }
    end

    describe 'given 1 2' do
      let(:args) { %w(foo 1 2) }
      it { expect(cmd.args).to eq %w(1 2 0) }
      it { expect(cmd.a).to eq '1' }
      it { expect(cmd.b).to eq '2' }
      it { expect(cmd.c).to eq '0' }
    end

    describe 'given 1' do
      let(:args) { %w(foo 1) }
      it { expect(cmd.args).to eq ['1', nil, '0'] }
      it { expect(cmd.a).to eq '1' }
      it { expect(cmd.b).to be_nil }
      it { expect(cmd.c).to eq '0' }
    end

    describe 'given nothing' do
      let(:args) { %w(foo) }
      it { expect(cmd.args).to eq [nil, nil, '0'] }
      it { expect(cmd.a).to be_nil }
      it { expect(cmd.b).to be_nil }
      it { expect(cmd.c).to eq '0' }
    end
  end
end
