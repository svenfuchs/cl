describe Cl, 'multi' do
  before do
    module Cmds
      module Multi
        class Foo < Cl::Cmd
          register 'multi:foo'
          arg :a, type: :int
          arg :b, type: :int
          opt('-c') { opts[:c] = true }
          def run; [args, opts] end
        end

        class Bar < Cl::Cmd
          register 'multi:bar'
          arg :d, type: :int
          opt('-e') { opts[:e] = true }
          def run; [args, opts] end
        end
      end
    end
  end

  after { Cmds.send(:remove_const, :Multi) }

  let(:cl)   { Cl::Runner::Multi.new(args) }
  let(:args) { %w(multi:foo 1 2 -c multi:bar 3 -e) }

  it { expect(cl.cmds[0].args).to eq [1, 2] }
  it { expect(cl.run[0][0]).to eq [1, 2] }
  it { expect(cl.run[0][1]).to eq c: true }

  it { expect(cl.cmds[1].args).to eq [3] }
  it { expect(cl.run[1][0]).to eq [3] }
  it { expect(cl.run[1][1]).to eq e: true }
end
