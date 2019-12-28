describe Cl::Parser::Format do
  subject { described_class.new(Cl::Opt.new(strs, opts)).strs }

  describe '-o ONE, --one-one ONE, alias: :two' do
    let(:strs) { ['-o ONE', '--one-one ONE'] }
    let(:opts) { { alias: :two } }

    it do
      should eq [
        '-o ONE',
        '--one-one ONE',
        '--one_one ONE',
        '--two TWO',
      ]
    end
  end

  describe '-o, --one, alias: :two' do
    let(:strs) { %w(-o --one) }
    let(:opts) { { alias: :two } }

    it do
      should eq [
        '-o',
        '--[no-]one',
        '--[no-]two',
      ]
    end
  end

  describe '--[no-]one, alias: :two (without flag values)' do
    let(:strs) { %w(--[no-]one) }
    let(:opts) { { alias: :two } }

    it do
      should eq [
        '--[no-]one',
        '--[no-]two',
      ]
    end
  end

  describe '-o, --one, alias: :two (with flag values)' do
    let(:strs) { %w(-o --one) }
    let(:opts) { { alias: :two } }

    before { Cl.flag_values = true }

    it do
      should eq [
        '-o',
        '--[no-]one',
        '--[no-]one [true|false|yes|no]',
        '--[no-]two',
        '--[no-]two [true|false|yes|no]'
      ]
    end
  end

  describe '--[no-]one, alias: :two (without flag values)' do
    let(:strs) { %w(--[no-]one) }
    let(:opts) { { alias: :two } }

    it do
      should eq [
        '--[no-]one',
        '--[no-]two',
      ]
    end
  end

  describe '--one, negate: %w(skip without) (without flag values)' do
    let(:strs) { %w(--one) }
    let(:opts) { { negate: %w(skip without) } }

    it do
      should eq [
        '--[no-]one',
      ]
    end
  end

  describe '--one, negate: %w(skip without) (with flag values)' do
    let(:strs) { %w(--one) }
    let(:opts) { { negate: %w(skip without) } }

    before { Cl.flag_values = true }

    it do
      should eq [
        '--[no-]one',
        '--[no-]one [true|false|yes|no]',
        # these would not be recognized by OptionParser, so we have to
        # normalize the incoming args instead
        # '--[skip-]one',
        # '--[skip-]one [true|false|yes|no]',
        # '--[without-]one',
        # '--[without-]one [true|false|yes|no]'
      ]
    end
  end
end
