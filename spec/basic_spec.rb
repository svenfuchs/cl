describe Cli, 'basic' do
  before do
    module Cmds
      module Basic
        class A
          include Cli::Cmd
          on('-a') { opts[:a] = true }
          register 'basic:a'
          def initialize(*); end
        end

        class B
          include Cli::Cmd
          on('-b') { opts[:b] = true }
          register 'basic:b'
          def initialize(*); end
        end
      end
    end
  end

  after { Cli.registry.clear }

  let(:args) { %w(basic b c d -b) }
  let(:cli)  { Cli::Runner.new(args) }

  it { expect(cli.cmd).to be_a Cmds::Basic::B }
  it { expect(cli.args).to eq %w(c d) }
  it { expect(cli.opts).to eq b: true }
end
