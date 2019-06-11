describe Cl, 'opts' do
  let!(:const) { Class.new(Cl::Cmd, &opts).register(:cmd) }

  describe 'on a str' do
    let(:opts) { ->(*) { opt('--one STR', format: /^one$/) } }
    it { expect(cmd(%w(cmd --one one)).opts[:one]).to eq 'one' }
    it { expect { cmd(%w(cmd --one two)) }.to raise_error 'Invalid format: one (format: /^one$/)' }
  end

  describe 'on an array' do
    let(:opts) { ->(*) { opt('--one STR', format: /^(one|two)$/, type: :array) } }
    it { expect(cmd(%w(cmd --one one --one two)).opts[:one]).to eq ['one', 'two'] }
    # it { expect { cmd(%w(cmd --one two)) }.to raise_error 'Invalid format: one (format: /^one$/)' }
  end
end
