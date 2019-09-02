describe Cl, 'opts' do
  let!(:const) { Class.new(Cl::Cmd, &opts).register(:cmd) }

  describe 'not deprecated' do
    let(:opts) do
      ->(*) do
        opt '--one STR'
        opt '--two'
      end
    end

    it { expect(cmd(%w(cmd --one one)).opts[:one]).to eq 'one' }
    it { expect(cmd(%w(cmd --one one)).deprecations).to be_empty }

    it { expect(cmd(%w(cmd --two two)).opts[:two]).to be true }
    it { expect(cmd(%w(cmd --two two)).deprecations).to be_empty }
  end

  describe 'deprecated (underscored)' do
    let(:opts) do
      ->(*) do
        opt '--one_one STR', deprecated: 'msg one'
        opt '--two_two STR', deprecated: 'msg two'
      end
    end

    it { expect(cmd(%w(cmd --one_one one)).opts[:one_one]).to eq 'one' }
    it { expect(cmd(%w(cmd --one_one one)).deprecations).to eq one_one: 'msg one' }
    it { expect(cmd(%w(cmd --one-one one)).opts[:one_one]).to eq 'one' }
    it { expect(cmd(%w(cmd --one-one one)).deprecations).to eq one_one: 'msg one' }

    it { expect(cmd(%w(cmd --two_two two)).opts[:two_two]).to eq 'two' }
    it { expect(cmd(%w(cmd --two_two two)).deprecations).to eq two_two: 'msg two' }
    it { expect(cmd(%w(cmd --two-two two)).opts[:two_two]).to eq 'two' }
    it { expect(cmd(%w(cmd --two-two two)).deprecations).to eq two_two: 'msg two' }
  end

  describe 'deprecated (dashed)' do
    let(:opts) do
      ->(*) do
        opt '--one-one STR', deprecated: 'msg one'
        opt '--two-two STR', deprecated: 'msg two'
      end
    end

    it { expect(cmd(%w(cmd --one_one one)).opts[:one_one]).to eq 'one' }
    it { expect(cmd(%w(cmd --one_one one)).deprecations).to eq one_one: 'msg one' }
    it { expect(cmd(%w(cmd --one-one one)).opts[:one_one]).to eq 'one' }
    it { expect(cmd(%w(cmd --one-one one)).deprecations).to eq one_one: 'msg one' }

    it { expect(cmd(%w(cmd --two_two two)).opts[:two_two]).to eq 'two' }
    it { expect(cmd(%w(cmd --two_two two)).deprecations).to eq two_two: 'msg two' }
    it { expect(cmd(%w(cmd --two-two two)).opts[:two_two]).to eq 'two' }
    it { expect(cmd(%w(cmd --two-two two)).deprecations).to eq two_two: 'msg two' }
  end

  describe 'deprecated with a default' do
    let(:opts) do
      ->(*) do
        opt '--one STR', deprecated: 'msg one', default: 'one'
      end
    end

    it { expect(cmd(%w(cmd)).opts[:one]).to eq 'one' }
    it { expect(cmd(%w(cmd)).deprecations).to be_empty }

    it { expect(cmd(%w(cmd --one one)).opts[:one]).to eq 'one' }
    it { expect(cmd(%w(cmd --one one)).deprecations).to eq one: 'msg one' }
  end

  describe 'deprecated alias (underscore)' do
    let(:opts) do
      ->(*) do
        opt '--one_one STR', alias: :two_two, deprecated: :two_two
      end
    end

    it { expect(cmd(%w(cmd --one_one one)).opts[:one_one]).to eq 'one' }
    it { expect(cmd(%w(cmd --one_one one)).deprecations).to be_empty }
    it { expect(cmd(%w(cmd --one-one one)).opts[:one_one]).to eq 'one' }
    it { expect(cmd(%w(cmd --one-one one)).deprecations).to be_empty }

    it { expect(cmd(%w(cmd --two_two one)).opts[:one_one]).to eq 'one' }
    it { expect(cmd(%w(cmd --two_two one)).deprecations).to eq two_two: :one_one }
    it { expect(cmd(%w(cmd --two-two one)).opts[:one_one]).to eq 'one' }
    it { expect(cmd(%w(cmd --two-two one)).deprecations).to eq two_two: :one_one }
  end

  describe 'deprecated alias (dashed)' do
    let(:opts) do
      ->(*) do
        opt '--one-one STR', alias: :'two-two', deprecated: :'two-two'
      end
    end

    it { expect(cmd(%w(cmd --one_one one)).opts[:one_one]).to eq 'one' }
    it { expect(cmd(%w(cmd --one_one one)).deprecations).to be_empty }
    it { expect(cmd(%w(cmd --one-one one)).opts[:one_one]).to eq 'one' }
    it { expect(cmd(%w(cmd --one-one one)).deprecations).to be_empty }

    it { expect(cmd(%w(cmd --two_two one)).opts[:one_one]).to eq 'one' }
    it { expect(cmd(%w(cmd --two_two one)).deprecations).to eq 'two-two': :one_one }
    it { expect(cmd(%w(cmd --two-two one)).opts[:one_one]).to eq 'one' }
    it { expect(cmd(%w(cmd --two-two one)).deprecations).to eq 'two-two': :one_one }
  end
end
