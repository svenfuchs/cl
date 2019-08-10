describe Cl, 'opts' do
  let!(:const) { Class.new(Cl::Cmd, &opts).register(:cmd) }

  describe 'upcase' do
    let(:opts) { ->(*) { opt('--one STR', upcase: true) } }

    it { expect(cmd(%w(cmd --one one)).opts[:one]).to eq 'ONE' }
    it { expect(cmd(%w(cmd --one One)).opts[:one]).to eq 'ONE' }
    it { expect(cmd(%w(cmd --one ONE)).opts[:one]).to eq 'ONE' }
  end

  describe 'enum, upcase' do
    let(:opts) { ->(*) { opt('--one STR', enum: ['ONE'], upcase: true) } }

    it { expect(cmd(%w(cmd --one one)).opts[:one]).to eq 'ONE' }
    it { expect(cmd(%w(cmd --one ONE)).opts[:one]).to eq 'ONE' }
    it { expect { cmd(%w(cmd --one two)) }.to raise_error 'Unknown value: one=TWO (known values: ONE)' }
  end
end
