describe Cl, 'opts, alias' do
  let!(:const) { Class.new(Cl::Cmd, &opts).register(:cmd) }
  let(:opts) { ->(*) { opt('-s', '--str STR', alias: :other) } }

  it { expect(cmd(%w(cmd --str str)).opts[:str]).to eq 'str' }
  it { expect(cmd(%w(cmd --other str)).opts[:str]).to eq 'str' }
  it { expect(cmd(%w(cmd --other str)).opts[:other]).to eq 'str' }
end
