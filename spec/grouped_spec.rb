describe Cli, 'grouped' do
  before do
    module Cmds
      module Grouped
        module Opts
          def self.included(const)
            const.on('-a') { opts[:a] = true }
            const.on('-b') { opts[:b] = true }
            const.on('-c') { opts[:c] = true }
          end
        end

        class A
          include Cli::Cmd
          include Opts
          register 'grouped:a'
          def initialize(*); end
        end

        class B
          include Cli::Cmd
          include Opts
          register 'grouped:b'
          def initialize(*); end
        end
      end
    end
  end

  after { Cli.registry.clear }

  let(:args) { %w(grouped b c d -a -b -c) }
  let(:cli)  { Cli::Runner.new(args) }

  it { expect(cli.cmd).to be_a Cmds::Grouped::B }
  it { expect(cli.args).to eq %w(c d) }
  it { expect(cli.opts).to eq a: true, b: true, c: true }
end
