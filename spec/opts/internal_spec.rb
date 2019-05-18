describe Cl, 'opts' do
  let!(:const) { Class.new(Cl::Cmd, &opts).register(:cmd) }
  let(:opts) { ->(*) { opt('--one STR', internal: true) } }

  it { expect(cmd(%w(cmd --one one)).opts[:one]).to eq 'one' }
  it { expect(const.opts[:one]).to be_internal }
end
