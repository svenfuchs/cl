describe Cl, 'opts' do
  let!(:const) { Class.new(Cl::Cmd, &opts).register(:cmd) }

  describe 'min' do
    let(:opts) { ->(*) { opt('--int INT', type: :int, min: 2) } }

    it { expect { cmd(%w(cmd --int 1)) }.to raise_error 'Out of range: int (min: 2)' }
    it { expect(cmd(%w(cmd --int 2)).opts[:int]).to eq 2 }
  end

  describe 'max' do
    let(:opts) { ->(*) { opt('--int INT', type: :int, max: 1) } }

    it { expect(cmd(%w(cmd --int 1)).opts[:int]).to eq 1 }
    it { expect { cmd(%w(cmd --int 2)) }.to raise_error 'Out of range: int (max: 1)' }
  end

  describe 'min and max' do
    let(:opts) { ->(*) { opt('--int INT', type: :int, min: 2, max: 3) } }

    it { expect { cmd(%w(cmd --int 1)) }.to raise_error 'Out of range: int (min: 2, max: 3)' }
    it { expect(cmd(%w(cmd --int 2)).opts[:int]).to eq 2 }
    it { expect { cmd(%w(cmd --int 4)) }.to raise_error 'Out of range: int (min: 2, max: 3)' }
  end
end
