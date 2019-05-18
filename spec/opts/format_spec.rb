describe Cl, 'opts' do
  let!(:const) { Class.new(Cl::Cmd, &opts).register(:cmd) }
  let(:opts) { ->(*) { opt('--one STR', format: /^one$/) } }

  it { expect(cmd(%w(cmd --one one)).opts[:one]).to eq 'one' }
  it { expect { cmd(%w(cmd --one two)) }.to raise_error 'Invalid format: one (format: /^one$/)' }
end
