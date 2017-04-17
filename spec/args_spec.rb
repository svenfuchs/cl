describe Cl, 'args' do
  before do
    module Cmds
      module Args
        class Foo < Cl::Cmd
          register 'args:foo'
          args :a, :b, required: true, type: :string
        end

        class Bar < Cl::Cmd
          register 'args:bar'
          arg :a, type: :array
          arg :b, type: :bool
          arg :c, type: :int
        end
      end
    end
  end

  after { Cmds.send(:remove_const, :Args) }

  let(:cl)   { Cl.runner(args) }
  let(:cmd)  { cl.cmd }

  describe 'defines argument accessors' do
    let(:args) { %w(args foo 1 2) }
    it { expect(cl.args).to eq %w(1 2) }
    it { expect(cmd.a).to eq '1' }
    it { expect(cmd.b).to eq '2' }
  end

  describe 'raises if arguments are missing' do
    let(:args) { %w(args foo 1) }
    it { expect { cmd }.to raise_error(Cl::ArgumentError) }
  end

  describe 'casts' do
    let(:args) { %w(args bar a,b,c true 1) }
    it { expect(cmd.a).to eq %w(a b c) }
    it { expect(cmd.b).to eq true }
    it { expect(cmd.c).to eq 1 }
  end
end
