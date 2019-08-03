describe Cl, 'opts' do
  let!(:const) { Class.new(Cl::Cmd, &opts).register(:cmd) }

  describe 'flag' do
    let(:opts) { ->(*) { opt('-f', '--flag', 'A flag') } }

    it { expect(cmd(%w(cmd --no-flag)).opts[:flag]).to be false }
    it { expect(cmd(%w(cmd --no_flag)).opts[:flag]).to be false }
    it { expect(cmd(%w(cmd --flag)).opts[:flag]).to be true }
    it { expect(cmd(%w(cmd -f)).opts[:flag]).to be true }

    it { expect(cmd(%w(cmd -f)).flag).to be true }
    it { expect(cmd(%w(cmd -f)).flag?).to be true }
  end
  describe 'flag, given [no-]' do
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

  describe 'flag with negtions' do
    let(:opts) { ->(*) { opt('--flag', negate: %w(skip without)) } }

    it { expect(cmd(%w(cmd --flag)).flag?).to be true }
    it { expect(cmd(%w(cmd --no-flag)).flag?).to be false }
    it { expect(cmd(%w(cmd --skip-flag)).flag?).to be false }
    it { expect(cmd(%w(cmd --without-flag)).flag?).to be false }
    it { expect(cmd(%w(cmd --no_flag)).flag?).to be false }
    it { expect(cmd(%w(cmd --skip_flag)).flag?).to be false }
    it { expect(cmd(%w(cmd --without_flag)).flag?).to be false }
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

  describe 'flag, optional argument, no default' do
    let(:opts) { ->(*) { opt('-f', '--flag') } }

    it { expect(cmd(%w(cmd)).flag?).to be false }
    it { expect(cmd(%w(cmd --flag)).flag).to be true }
    it { expect(cmd(%w(cmd --flag yes)).flag).to be true }
    it { expect(cmd(%w(cmd --flag true)).flag).to be true }
    it { expect(cmd(%w(cmd --flag no)).flag).to be false }
    it { expect(cmd(%w(cmd --flag false)).flag).to be false }

    it { expect(cmd(%w(cmd --no-flag)).flag).to be false }
    it { expect(cmd(%w(cmd --no-flag yes)).flag).to be false }
    it { expect(cmd(%w(cmd --no-flag true)).flag).to be false }

    # looks like option parser just does not support these?
    # it { expect(cmd(%w(cmd --no-flag no)).flag).to be true }
    # it { expect(cmd(%w(cmd --no-flag false)).flag).to be true }
  end

  describe 'flag, optional argument, default true' do
    let(:opts) { ->(*) { opt('-f', '--flag', default: true) } }

    it { expect(cmd(%w(cmd)).flag?).to be true }
    it { expect(cmd(%w(cmd --flag)).flag).to be true }
    it { expect(cmd(%w(cmd --flag yes)).flag).to be true }
    it { expect(cmd(%w(cmd --flag true)).flag).to be true }
    it { expect(cmd(%w(cmd --flag no)).flag).to be false }
    it { expect(cmd(%w(cmd --flag false)).flag).to be false }

    it { expect(cmd(%w(cmd --no-flag)).flag).to be false }
    it { expect(cmd(%w(cmd --no-flag yes)).flag).to be false }
    it { expect(cmd(%w(cmd --no-flag true)).flag).to be false }
  end

  describe 'flag, optional argument, default false' do
    let(:opts) { ->(*) { opt('-f', '--flag', default: false) } }

    it { expect(cmd(%w(cmd)).flag?).to be false }
    it { expect(cmd(%w(cmd --flag)).flag).to be true }
    it { expect(cmd(%w(cmd --flag yes)).flag).to be true }
    it { expect(cmd(%w(cmd --flag true)).flag).to be true }
    it { expect(cmd(%w(cmd --flag no)).flag).to be false }
    it { expect(cmd(%w(cmd --flag false)).flag).to be false }

    it { expect(cmd(%w(cmd --no-flag)).flag).to be false }
    it { expect(cmd(%w(cmd --no-flag yes)).flag).to be false }
    it { expect(cmd(%w(cmd --no-flag true)).flag).to be false }
  end
end
