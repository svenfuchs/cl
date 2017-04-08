describe Cli, 'nested' do
  before do
    module Cmds
      module Nested
        class A
          include Cli::Cmd
          register 'nested:a'
          on('-a') { opts[:a] = true }
          def initialize(*); end

          class B < A
            register 'nested:a:b'
            on('-b') { opts[:b] = true }

            class C < B
              register 'nested:a:b:c'
              on('-c') { opts[:c] = true }
            end
          end
        end
      end
    end
  end

  after { Cli.cmds.clear }

  let(:args) { %w(nested a b c d e -a -b -c) }
  let(:cli)  { Cli::Runner.new(args) }

  it { expect(cli.cmd).to be_a Cmds::Nested::A::B::C }
  it { expect(cli.args).to eq %w(d e) }
  it { expect(cli.opts).to eq a: true, b: true, c: true }
end
