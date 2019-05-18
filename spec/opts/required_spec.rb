describe Cl, 'opts' do
  let!(:const) { Class.new(Cl::Cmd, &opts).register(:cmd) }

  describe 'required' do
    let(:opts) { ->(*) { opt('--str STR', required: true) } }

    it { expect(cmd(%w(cmd --str str)).opts[:str]).to eq 'str' }
    it { expect { cmd(%w(cmd)) }.to raise_error Cl::OptionError }
  end

  describe 'requires another option' do
    let(:opts) do
      ->(*) do
        opt '--one STR', requires: :two
        opt '--two STR'
      end
    end

    it { expect(cmd(%w(cmd --one one --two two)).opts[:one]).to eq 'one' }
    it { expect { cmd(%w(cmd --one one)) }.to raise_error 'Missing option: two (required by one)' }
  end

  describe 'requires two other options' do
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

  describe 'requireds' do
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
    it { expect { cmd(%w(cmd)) }.to raise_error 'Missing options: one, or two and three' }
    it { expect { cmd(%w(cmd --two)) }.to raise_error 'Missing options: one, or two and three' }
    it { expect { cmd(%w(cmd --three)) }.to raise_error 'Missing options: one, or two and three' }
  end
end
