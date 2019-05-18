describe Cl, 'opts' do
  let!(:const) { Class.new(Cl::Cmd, &opts).register(:cmd) }
  let(:opts) { ->(*) { opt('--one STR', enum: ['one', /^two$/]) } }

  it { expect(cmd(%w(cmd --one one)).opts[:one]).to eq 'one' }
  it { expect(cmd(%w(cmd --one two)).opts[:one]).to eq 'two' }
  it { expect { cmd(%w(cmd --one three)) }.to raise_error 'Unknown value: one=three (known values: one, /^two$/)' }
end
