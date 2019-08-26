describe Cl, 'enum' do
  let!(:const) { Class.new(Cl::Cmd, &opts).register(:cmd) }

  describe 'with a flag' do
    let(:opts) { ->(*) { opt('--one', enum: [true]) } }
    it { expect(cmd(%w(cmd --one)).opts[:one]).to be true }
    it { expect { cmd(%w(cmd --no-one)) }.to raise_error 'Unknown value: one=false (known values: true)' }
  end

  describe 'with an int' do
    let(:opts) { ->(*) { opt('--one INT', type: :int, enum: [1]) } }
    it { expect(cmd(%w(cmd --one 1)).opts[:one]).to eq 1 }
    it { expect { cmd(%w(cmd --one 2)) }.to raise_error 'Unknown value: one=2 (known values: 1)' }
  end

  describe 'with a string' do
    let(:opts) { ->(*) { opt('--one STR', enum: ['one', /^two$/]) } }
    it { expect(cmd(%w(cmd --one one)).opts[:one]).to eq 'one' }
    it { expect(cmd(%w(cmd --one two)).opts[:one]).to eq 'two' }
    it { expect { cmd(%w(cmd --one three)) }.to raise_error 'Unknown value: one=three (known values: one, /^two$/)' }
  end

  describe 'with an array' do
    let(:opts) { ->(*) { opt('--one STRS', type: :array, enum: ['one', /^two$/]) } }
    it { expect(cmd(%w(cmd --one one --one two)).opts[:one]).to eq ['one', 'two'] }
    it { expect { cmd(%w(cmd --one on --one two --one three)) }.to raise_error 'Unknown value: one=on one=three (known values: one, /^two$/)' }
    it { expect { cmd(%w(cmd --one on --one two --one three)) }.to suggest 'one' } if RUBY_VERSION >= '2.4'
  end
end
