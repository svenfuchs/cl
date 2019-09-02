describe Cl, 'basic' do
  let!(:one) do
    Class.new(Cl::Cmd) do
      register :one
      opt('--one') { opts[:one] = true }
    end
  end

  let!(:two) do
    Class.new(Cl::Cmd) do
      register :two
      opt('--one') { opts[:one] = true }
      opt('--two') { opts[:two] = true }
    end
  end

  before { Cl::Help.register :help }

  describe 'args and opts' do
    let(:args) { %w(one foo bar --one) }
    it { expect(cmd).to be_a one }
    it { expect(cmd.args).to eq %w(foo bar) }
    it { expect(cmd.opts).to eq one: true }
  end

  describe 'strs' do
    it { expect(two.opts.map(&:strs).flatten).to eq %w(--one --two --help) }
  end

  describe 'invalid option' do
    let(:args) { %w(one --une) }
    it { expect { subject.run(args) }.to raise_error 'Unknown option: --une' }
    it { expect { subject.run(args) }.to suggest 'one' } if RUBY_VERSION >= '2.4'
  end

  describe 'unknown cmd' do
    let(:args) { %w(on a b) }
    it { expect { cmd }.to raise_error 'Unknown command: on a b' }
    it { expect { cmd }.to suggest 'one' } if RUBY_VERSION >= '2.4'
  end
end
