describe Cl, 'opts' do
  let!(:const) { Class.new(Cl::Cmd, &opts).register(:cmd) }

  describe 'downcase' do
    let(:opts) { ->(*) { opt('--one STR', downcase: true) } }

    it { expect(cmd(%w(cmd --one one)).opts[:one]).to eq 'one' }
    it { expect(cmd(%w(cmd --one One)).opts[:one]).to eq 'one' }
    it { expect(cmd(%w(cmd --one ONE)).opts[:one]).to eq 'one' }
  end

  describe 'enum, downcase' do
    let(:opts) { ->(*) { opt('--one STR', enum: ['one'], downcase: true) } }

    it { expect(cmd(%w(cmd --one one)).opts[:one]).to eq 'one' }
    it { expect(cmd(%w(cmd --one ONE)).opts[:one]).to eq 'one' }
    it { expect { cmd(%w(cmd --one two)) }.to raise_error 'Unknown value: one=two (known values: one)' }
  end
end
