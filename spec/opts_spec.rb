describe Cl, 'opts' do
  let!(:const) { Class.new(Cl::Cmd, &opts).register(:cmd) }

  describe 'opts.required' do
    let(:opts) do
      ->(*) do
        required :one, [:two, :three]
        opt '--one'
        opt '--two'
        opt '--three'
      end
    end

    it { expect { cmd(%w(cmd --one)) }.to_not raise_error }
    it { expect { cmd(%w(cmd --two --three)) }.to_not raise_error }
    it { expect { cmd(%w(cmd)) }.to raise_error 'Missing options: one or two and three' }
    it { expect { cmd(%w(cmd --two)) }.to raise_error 'Missing options: one or two and three' }
    it { expect { cmd(%w(cmd --three)) }.to raise_error 'Missing options: one or two and three' }
  end

  describe 'string' do
    let(:opts) { ->(*) { opt('-s', '--str STR', 'A str') } }

    it { expect(cmd(%w(cmd --str str)).opts[:str]).to eq 'str' }
    it { expect(cmd(%w(cmd -s str)).opts[:str]).to eq 'str' }

    it { expect(cmd(%w(cmd -s str)).str).to eq 'str' }
    it { expect(cmd(%w(cmd -s str)).str?).to be true }
  end

  describe 'string, alias' do
    let(:opts) { ->(*) { opt('-s', '--str STR', alias: :other) } }

    it { expect(cmd(%w(cmd --str str)).opts[:str]).to eq 'str' }
    it { expect(cmd(%w(cmd --other str)).opts[:str]).to eq 'str' }
    it { expect(cmd(%w(cmd --other str)).opts[:other]).to eq 'str' }
  end

  describe 'string, deprecated' do
    let(:opts) do
      ->(*) do
        opt '--one STR', deprecated: true
        opt '--two STR', deprecated: true
      end
    end

    it { expect(cmd(%w(cmd --one one)).opts[:one]).to eq 'one' }
    it { expect(cmd(%w(cmd --one one)).deprecated_opts).to eq [:one] }
  end

  describe 'string, deprecated alias' do
    let(:opts) do
      ->(*) do
        opt '--one STR', alias: :two, deprecated: :two
      end
    end

    it { expect(cmd(%w(cmd --one one)).opts[:one]).to eq 'one' }
    it { expect(cmd(%w(cmd --one one)).deprecated_opts).to eq [] }
    it { expect(cmd(%w(cmd --two two)).opts[:one]).to eq 'two' }
    it { expect(cmd(%w(cmd --two two)).deprecated_opts).to eq [:two] }
  end

  describe 'string, default (string)' do
    let(:opts) { ->(*) { opt('-s', '--str STR') } }

    before { const.defaults(str: 'default') }

    it { expect(cmd(%w(cmd)).opts[:str]).to eq 'default' }
    it { expect(cmd(%w(cmd --str str)).opts[:str]).to eq 'str' }
  end

  describe 'string, default (symbol)' do
    let(:opts) { ->(*) { opt('-s', '--str STR'); opt('--other STR') } }

    before { const.defaults(str: :other) }

    it { expect(cmd(%w(cmd)).opts[:str]).to be nil }
    it { expect(cmd(%w(cmd --other other)).opts[:str]).to eq 'other' }
    it { expect(cmd(%w(cmd --str str)).opts[:str]).to eq 'str' }
  end

  describe 'string, enum' do
    let(:opts) { ->(*) { opt('--one STR', enum: ['one', 'two']) } }

    it { expect(cmd(%w(cmd --one one)).opts[:one]).to eq 'one' }
    it { expect { cmd(%w(cmd --one three)) }.to raise_error 'Unknown value: one=three (known values: one, two)' }
  end

  describe 'string, format' do
    let(:opts) { ->(*) { opt('--one STR', format: /one/) } }

    it { expect(cmd(%w(cmd --one one)).opts[:one]).to eq 'one' }
    it { expect { cmd(%w(cmd --one two)) }.to raise_error 'Invalid format: one (format: one)' }
  end

  describe 'string, required' do
    let(:opts) { ->(*) { opt('--str STR', required: true) } }

    it { expect(cmd(%w(cmd --str str)).opts[:str]).to eq 'str' }
    it { expect { cmd(%w(cmd)) }.to raise_error Cl::OptionError }
  end

  describe 'string, requires another option' do
    let(:opts) do
      ->(*) do
        opt '--one STR', requires: :two
        opt '--two STR'
      end
    end

    it { expect(cmd(%w(cmd --one one --two two)).opts[:one]).to eq 'one' }
    it { expect { cmd(%w(cmd --one one)) }.to raise_error 'Missing option: two (required by one)' }
  end

  describe 'string, requires two other options' do
    let(:opts) do
      ->(*) do
        opt '--one STR', requires: [:two, :three]
        opt '--two STR'
        opt '--three STR'
      end
    end

    it { expect(cmd(%w(cmd --one one --two two --three three)).opts[:one]).to eq 'one' }
    it { expect { cmd(%w(cmd --one one --two two)) }.to raise_error 'Missing option: three (required by one)' }
    it { expect { cmd(%w(cmd --one one)) }.to raise_error 'Missing options: two (required by one), three (required by one)' }
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

  describe 'integer, max' do
    let(:opts) { ->(*) { opt('--int INT', type: :int, max: 1) } }

    it { expect(cmd(%w(cmd --int 1)).opts[:int]).to eq 1 }
    it { expect { cmd(%w(cmd --int 2)) }.to raise_error 'Exceeds max value: int (max: 1)' }
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
