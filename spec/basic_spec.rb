describe Cl, 'basic' do
  before do
    module Cmds
      module Basic
        class A
          include Cl::Cmd
          on('-a') { opts[:a] = true }
          register 'basic:a'
          def initialize(*); end
        end

        class B
          include Cl::Cmd
          on('-b') { opts[:b] = true }
          register 'basic:b'
          def initialize(*); end
        end
      end
    end
  end

  after { Cl.registry.clear }

  let(:args) { %w(basic b c d -b) }
  let(:cl)  { Cl::Runner.new(args) }

  it { expect(cl.cmd).to be_a Cmds::Basic::B }
  it { expect(cl.args).to eq %w(c d) }
  it { expect(cl.opts).to eq b: true }
end
