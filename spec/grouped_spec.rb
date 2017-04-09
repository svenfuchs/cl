describe Cl, 'grouped' do
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
          include Cl::Cmd
          include Opts
          register 'grouped:a'
          def initialize(*); end
        end

        class B
          include Cl::Cmd
          include Opts
          register 'grouped:b'
          def initialize(*); end
        end
      end
    end
  end

  after { Cl.registry.clear }

  let(:args) { %w(grouped b c d -a -b -c) }
  let(:cl)  { Cl::Runner.new(args) }

  it { expect(cl.cmd).to be_a Cmds::Grouped::B }
  it { expect(cl.args).to eq %w(c d) }
  it { expect(cl.opts).to eq a: true, b: true, c: true }
end
