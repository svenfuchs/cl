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
    it { expect(cmd(%w(cmd --one one)).deprecated_opts).to eq one: 'msg one' }

    it { expect(cmd(%w(cmd --two two)).opts[:two]).to eq 'two' }
    it { expect(cmd(%w(cmd --two two)).deprecated_opts).to eq two: 'msg two' }
  end

  describe 'deprecated alias' do
    let(:opts) do
      ->(*) do
        opt '--one STR', alias: :two, deprecated: :two
      end
    end

    it { expect(cmd(%w(cmd --one one)).opts[:one]).to eq 'one' }
    it { expect(cmd(%w(cmd --one one)).deprecated_opts).to eq({}) }
    it { expect(cmd(%w(cmd --two two)).opts[:one]).to eq 'two' }
    it { expect(cmd(%w(cmd --two two)).deprecated_opts).to eq two: :one }
  end
end
