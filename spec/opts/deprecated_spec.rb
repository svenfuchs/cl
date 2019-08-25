describe Cl, 'opts' do
  let!(:const) { Class.new(Cl::Cmd, &opts).register(:cmd) }

  describe 'deprecated' do
    let(:opts) do
      ->(*) do
        opt '--one STR', deprecated: 'msg one'
        opt '--two STR', deprecated: 'msg two'
      end
    end

    it { expect(cmd(%w(cmd --one one)).opts[:one]).to eq 'one' }
    it { expect(cmd(%w(cmd --one one)).deprecations).to eq one: 'msg one' }

    it { expect(cmd(%w(cmd --two two)).opts[:two]).to eq 'two' }
    it { expect(cmd(%w(cmd --two two)).deprecations).to eq two: 'msg two' }
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

  describe 'deprecated alias' do
    let(:opts) do
      ->(*) do
        opt '--one STR', alias: :two, deprecated: :two
      end
    end

    it { expect(cmd(%w(cmd --one one)).opts[:one]).to eq 'one' }
    it { expect(cmd(%w(cmd --one one)).deprecations).to be_empty }
    it { expect(cmd(%w(cmd --two two)).opts[:one]).to eq 'two' }
    it { expect(cmd(%w(cmd --two two)).deprecations).to eq two: :one }
  end
end
