describe Cl, 'opts' do
  let!(:const) { Class.new(Cl::Cmd, &opts).register(:cmd) }

  describe 'string' do
    let(:opts) { ->(*) { opt('-s', '--str STR', 'A str') } }

    it { expect(cmd(%w(cmd --str str)).opts[:str]).to eq 'str' }
    it { expect(cmd(%w(cmd -s str)).opts[:str]).to eq 'str' }

    it { expect(cmd(%w(cmd -s str)).str).to eq 'str' }
    it { expect(cmd(%w(cmd -s str)).str?).to be true }
  end

  describe 'string, given a block' do
    let(:opts) { ->(*) { opt('-s', '--str STR', 'A str') { |obj| opts[:str] = obj + '.' } } }

    it { expect(cmd(%w(cmd --str str)).opts[:str]).to eq 'str.' }
    it { expect(cmd(%w(cmd -s str)).opts[:str]).to eq 'str.' }
  end

  describe 'integer' do
    let(:opts) { ->(*) { opt('-i', '--int INT', 'An int', type: :int) } }

    it { expect(cmd(%w(cmd --int 1)).opts[:int]).to eq 1 }
    it { expect(cmd(%w(cmd -i 1)).opts[:int]).to eq 1 }

    it { expect(cmd(%w(cmd -i 1)).int).to eq 1 }
    it { expect(cmd(%w(cmd -i 1)).int?).to be true }
  end

  describe 'array' do
    let(:opts) { ->(*) { opt('-s', '--strs STRS', 'A array', type: :array) } }

    it { expect(cmd(%w(cmd --strs a --strs b)).opts[:strs]).to eq %w(a b) }
    it { expect(cmd(%w(cmd -s a -s b)).opts[:strs]).to eq %w(a b) }

    it { expect(cmd(%w(cmd -s a)).strs).to eq %w(a) }
    it { expect(cmd(%w(cmd -s a)).strs?).to be true }
    it { expect(cmd(%w(cmd)).strs?).to be false }
  end

  describe 'flag' do
    let(:opts) { ->(*) { opt('-f', '--[no-]flag', 'A flag') } }

    it { expect(cmd(%w(cmd --no-flag)).opts[:flag]).to be false }
    it { expect(cmd(%w(cmd --no_flag)).opts[:flag]).to be false }
    it { expect(cmd(%w(cmd --flag)).opts[:flag]).to be true }
    it { expect(cmd(%w(cmd -f)).opts[:flag]).to be true }

    it { expect(cmd(%w(cmd -f)).flag).to be true }
    it { expect(cmd(%w(cmd -f)).flag?).to be true }
  end

  describe 'flag, default true' do
    let(:opts) { ->(*) { opt('--flag', default: true) } }

    it { expect(cmd(%w(cmd)).opts[:flag]).to be true }
    it { expect(cmd(%w(cmd --flag)).opts[:flag]).to be true }
    it { expect(cmd(%w(cmd --no-flag)).opts[:flag]).to be false }
  end

  describe 'flag, default true (given [no-])' do
    let(:opts) { ->(*) { opt('--[no-]flag', default: true) } }

    it { expect(cmd(%w(cmd)).opts[:flag]).to be true }
    it { expect(cmd(%w(cmd --flag)).opts[:flag]).to be true }
    it { expect(cmd(%w(cmd --no-flag)).opts[:flag]).to be false }
  end

  describe 'flag, given a block' do
    let(:opts) { ->(*) { opt('-f', '--[no-]flag', 'A flag') { |obj| opts[:unflag] = !obj } } }

    it { expect(cmd(%w(cmd --no-flag)).opts[:unflag]).to be true }
    it { expect(cmd(%w(cmd --flag)).opts[:unflag]).to be false }
    it { expect(cmd(%w(cmd -f)).opts[:unflag]).to be false }
  end

  describe 'flag starting with --no, dasherized' do
    let(:opts) { ->(*) { opt('--no-flag', 'No flag') } }

    it { expect(cmd(%w(cmd --no-flag)).no_flag?).to be true }
    it { expect(cmd(%w(cmd --no_flag)).no_flag?).to be true }
  end

  describe 'flag starting with --no, underscored' do
    let(:opts) { ->(*) { opt('--no_flag', 'No flag') } }

    it { expect(cmd(%w(cmd --no-flag)).no_flag?).to be true }
    it { expect(cmd(%w(cmd --no_flag)).no_flag?).to be true }
  end

  describe 'flag with an alias, underscored' do
    let(:opts) { ->(*) { opt('--a_flag', 'A flag', alias: 'b_flag') } }

    it { expect(cmd(%w(cmd --a-flag)).a_flag?).to be true }
    it { expect(cmd(%w(cmd --a_flag)).a_flag?).to be true }

    it { expect(cmd(%w(cmd --b-flag)).a_flag?).to be true }
    it { expect(cmd(%w(cmd --b_flag)).a_flag?).to be true }
  end

  describe 'flag with an alias, dasherized' do
    let(:opts) { ->(*) { opt('--a-flag', 'A flag', alias: 'b-flag') } }

    it { expect(cmd(%w(cmd --a-flag)).a_flag?).to be true }
    it { expect(cmd(%w(cmd --a_flag)).a_flag?).to be true }

    it { expect(cmd(%w(cmd --b-flag)).a_flag?).to be true }
    it { expect(cmd(%w(cmd --b_flag)).a_flag?).to be true }
  end

  describe 'dashed opts' do
    let(:opts) { ->(*) { opt('--one_two') } }

    it { expect(cmd(%w(cmd --one_two)).opts[:one_two]).to be true }
    it { expect(cmd(%w(cmd --one_two)).one_two?).to be true }

    it { expect(cmd(%w(cmd --one-two)).opts[:one_two]).to be true }
    it { expect(cmd(%w(cmd --one-two)).one_two?).to be true }
  end

  describe 'does not dasherize values' do
    let(:opts) { ->(*) { opt('--str STR') } }
    it { expect(cmd(%w(cmd --str one_two)).opts[:str]).to eq 'one_two' }
  end
end
