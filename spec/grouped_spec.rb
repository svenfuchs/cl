describe Cl, 'grouped' do
  before do
    module Cmds
      module Grouped
        class A < Cl::Cmd
          register 'grouped:a'
          opt('-z') { opts[:z] = true }
          def run; [args, opts] end
        end

        class B < Cl::Cmd
          register 'grouped:b'
          opt('-a') { opts[:a] = true }
          opt('-b') { opts[:b] = true }
          opt('-c') { opts[:c] = true }
          def run; [args, opts] end
        end
      end
    end
  end

  after { Cmds.send(:remove_const, :Grouped) }

  let(:args) { %w(grouped b c d -a -b -c) }
  let(:cl)  { Cl.runner(args) }

  it { expect(Cmds::Grouped::B.opts.map(&:first).flatten).to eq %w(-a -b -c) }
  it { expect(cl.cmd).to be_a Cmds::Grouped::B }
  it { expect(cl.run[0]).to eq %w(c d) }
  it { expect(cl.run[1]).to eq a: true, b: true, c: true }
end
