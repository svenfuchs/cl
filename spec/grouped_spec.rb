describe Cl, 'grouped' do
  before do
    module Cmds
      module Grouped
        class A < Cl::Cmd
          register 'grouped:a'
          opt('-a') { opts[:a] = true }
          opt('-b') { opts[:b] = true }
          opt('-c') { opts[:c] = true }
          def initialize(*); end
        end

        class B < Cl::Cmd
          register 'grouped:b'
          opt('-x') { opts[:x] = true }
          opt('-y') { opts[:y] = true }
          opt('-z') { opts[:z] = true }
          def initialize(*); end
        end
      end
    end
  end

  after { Cmds.send(:remove_const, :Grouped) }

  let(:args) { %w(grouped b c d -x -y -z) }
  let(:cl)  { Cl.runner(args) }

  it { expect(Cmds::Grouped::B.opts.map(&:first).flatten).to eq %w(-x -y -z) }
  it { expect(cl.cmd).to be_a Cmds::Grouped::B }
  it { expect(cl.args).to eq %w(c d) }
  it { expect(cl.opts).to eq x: true, y: true, z: true }
end
