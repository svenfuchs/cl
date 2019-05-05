describe Cl, 'opts' do
  let!(:const) { Class.new(Cl::Cmd, &opts).register(:cmd) }

  def cmd(args)
    Cl.runner(ctx, args).cmd
  end

  describe 'string' do
    let(:opts) { ->(*) { opt('-s', '--str STR', 'A str') } }

    it { expect(cmd(%w(cmd --str str)).opts[:str]).to eq 'str' }
    it { expect(cmd(%w(cmd -s str)).opts[:str]).to eq 'str' }

    it { expect(cmd(%w(cmd -s str)).str).to eq 'str' }
    it { expect(cmd(%w(cmd -s str)).str?).to be true }
  end

  describe 'string, default' do
    let(:opts) { ->(*) { opt('-s', '--str STR') } }

    before { const.defaults(str: 'default') }

    it { expect(cmd(%w(cmd)).opts[:str]).to eq 'default' }
    it { expect(cmd(%w(cmd --str str)).opts[:str]).to eq 'str' }
  end

  describe 'string, required' do
    let(:opts) { ->(*) { opt('--str STR', required: true) } }

    it { expect(cmd(%w(cmd --str str)).opts[:str]).to eq 'str' }
    it { expect { cmd(%(cmd)) }.to raise_error Cl::OptionError }
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

  describe 'flag' do
    let(:opts) { ->(*) { opt('-f', '--[no-]flag', 'A flag') } }

    it { expect(cmd(%w(cmd --no-flag)).opts[:flag]).to be false }
    it { expect(cmd(%w(cmd --flag)).opts[:flag]).to be true }
    it { expect(cmd(%w(cmd -f)).opts[:flag]).to be true }

    it { expect(cmd(%w(cmd -f)).flag).to be true }
    it { expect(cmd(%w(cmd -f)).flag?).to be true }
  end

  describe 'flag, default' do
    let(:opts) { ->(*) { opt('-f', '--[no-]flag') } }

    before { const.defaults(flag: true) }

    it { expect(cmd(%w(cmd)).opts[:flag]).to be true }
    it { expect(cmd(%w(cmd --flag)).opts[:flag]).to be true }
  end

  describe 'flag, given a block' do
    let(:opts) { ->(*) { opt('-f', '--[no-]flag', 'A flag') { |obj| opts[:unflag] = !obj } } }

    it { expect(cmd(%w(cmd --no-flag)).opts[:unflag]).to be true }
    it { expect(cmd(%w(cmd --flag)).opts[:unflag]).to be false }
    it { expect(cmd(%w(cmd -f)).opts[:unflag]).to be false }
  end

  # describe 'casts' do
  #   let(:args) { %w(args bar a,b,c true 1 1.2) }
  #   it { expect(cmd).to be_a bar }
  #   it { expect(cmd.a).to eq %w(a b c) }
  #   it { expect(cmd.b).to eq true }
  #   it { expect(cmd.c).to eq 1 }
  #   it { expect(cmd.d).to eq 1.2 }
  # end
  #
  # describe 'raises on missing arguments' do
  #   let(:args) { %w(args foo) }
  #   it { expect { cmd }.to raise_error(Cl::ArgumentError, 'Missing arguments (given: 0, required: 1)') }
  # end
  #
  # describe 'raises on too many arguments' do
  #   let(:args) { %w(args foo 1 2 3) }
  #   it { expect { cmd }.to raise_error(Cl::ArgumentError, 'Too many arguments (given: 3, allowed: 2)') }
  # end
  #
  # describe 'raises on wrong argument type (int)' do
  #   let(:args) { %w(args bar 1 2 a) }
  #   it { expect { cmd }.to raise_error(Cl::ArgumentError, 'Wrong argument type (given: "a", expected: int)') }
  # end
  #
  # describe 'raises on wrong argument type (float)' do
  #   let(:args) { %w(args bar 1 2 3 a) }
  #   it { expect { cmd }.to raise_error(Cl::ArgumentError, 'Wrong argument type (given: "a", expected: float)') }
  # end
end
