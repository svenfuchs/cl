describe Cl, 'basic' do
  before do
    module Cmds
      module Basic
        class A < Cl::Cmd
          on('-a') { opts[:a] = true }
          register 'basic:a'
        end

        class B < Cl::Cmd
          on('-b') { opts[:b] = true }
          register 'basic:b'
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
