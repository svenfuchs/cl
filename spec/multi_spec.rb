describe Cl, 'multi' do
  before do
    module Cmds
      module Multi
        class Foo < Cl::Cmd
          register 'multi:foo'
          arg :a, type: :int
          arg :b, type: :int
        end

        class Bar < Cl::Cmd
          register 'multi:bar'
          arg :c, type: :int
        end
      end
    end
  end

  after { Cmds.send(:remove_const, :Multi) }

  let(:cl)   { Cl::Runner::Multi.new(args) }
  let(:args) { %w(multi:foo 1 2 multi:bar 3) }

  it { expect(cl.cmds[0].args).to eq [1, 2] }
  it { expect(cl.cmds[0].a).to eq 1 }
  it { expect(cl.cmds[0].b).to eq 2 }

  it { expect(cl.cmds[1].args).to eq [3] }
  it { expect(cl.cmds[1].c).to eq 3 }
end
