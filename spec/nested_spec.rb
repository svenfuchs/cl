describe Cl, 'nested' do
  before do
    module Cmds
      module Nested
        class A < Cl::Cmd
          register 'nested:a'
          opt('-a') { opts[:a] = true }
          def initialize(*); end

          class B < A
            register 'nested:a:b'
            opt('-b') { opts[:b] = true }

            class C < B
              register 'nested:a:b:c'
              opt('-c') { opts[:c] = true }
            end
          end
        end
      end
    end
  end

  after { Cmds.send(:remove_const, :Nested) }

  let(:args) { %w(nested a b c d e -a -b -c) }
  let(:cl)  { Cl.runner(args) }

  it { expect(Cmds::Nested::A.opts.map(&:first).flatten).to eq %w(-a) }
  it { expect(Cmds::Nested::A::B.opts.map(&:first).flatten).to eq %w(-a -b) }
  it { expect(Cmds::Nested::A::B::C.opts.map(&:first).flatten).to eq %w(-a -b -c) }

  it { expect(cl.cmd).to be_a Cmds::Nested::A::B::C }
  it { expect(cl.args).to eq %w(d e) }
  it { expect(cl.opts).to eq a: true, b: true, c: true }
end
