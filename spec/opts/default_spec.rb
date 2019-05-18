describe Cl, 'opts' do
  let!(:const) { Class.new(Cl::Cmd, &opts).register(:cmd) }

  describe 'default (string)' do
    let(:opts) { ->(*) { opt('--str STR', default: 'default') } }
    it { expect(cmd(%w(cmd)).opts[:str]).to eq 'default' }
    it { expect(cmd(%w(cmd --str str)).opts[:str]).to eq 'str' }
  end

  describe 'default (symbol)' do
    let(:opts) { ->(*) { opt('-s', '--str STR', default: :other); opt('--other STR') } }
    it { expect(cmd(%w(cmd)).opts[:str]).to be nil }
    it { expect(cmd(%w(cmd --other other)).opts[:str]).to eq 'other' }
    it { expect(cmd(%w(cmd --str str)).opts[:str]).to eq 'str' }
  end
end
