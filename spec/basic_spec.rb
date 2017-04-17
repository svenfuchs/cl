describe Cl, 'basic' do
  before do
    module Cmds
      module Basic
        class A < Cl::Cmd
          opt('-a') { opts[:a] = true }
          register :a
          def run; [args, opts] end
        end

        class B < Cl::Cmd
          opt('-b') { opts[:b] = true }
          register :b
          def run; [args, opts] end
        end
      end
    end
  end

  after { Cmds.send(:remove_const, :Basic) }

  let(:cl)   { Cl.runner(args) }
  let(:args) { %w(b c d -b) }

  it { expect(cl.cmd).to be_a Cmds::Basic::B }
  it { expect(cl.run[0]).to eq %w(c d) }
  it { expect(cl.run[1]).to eq b: true }
end
