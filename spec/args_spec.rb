describe Cl, 'args' do
  before do
    module Cmds
      module Args
        class Foo < Cl::Cmd
          register 'args:foo'
          arg :a, required: true
          arg :b
        end

        class Bar < Cl::Cmd
          register 'args:bar'
          arg :a, type: :array
          arg :b, type: :bool
          arg :c, type: :int
          arg :d, type: :float
        end

        class Baz < Cl::Cmd
          register 'args:baz'
          arg :a, type: :array
          arg :b
          arg :c
        end

        class Buz < Cl::Cmd
          register 'args:buz'
          arg :a
          arg :b, type: :array
          arg :c
        end

        class Bum < Cl::Cmd
          register 'args:bum'
          arg :a
          arg :b
          arg :c, type: :array
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

  describe 'casts' do
    let(:args) { %w(args bar a,b,c true 1 1.2) }
    it { expect(cmd.a).to eq %w(a b c) }
    it { expect(cmd.b).to eq true }
    it { expect(cmd.c).to eq 1 }
    it { expect(cmd.d).to eq 1.2 }
  end

  describe 'splats (left)' do
    let(:args) { %w(args baz a b c d e) }
    it { expect(cmd.a).to eq %w(a b c) }
    it { expect(cmd.b).to eq 'd' }
    it { expect(cmd.c).to eq 'e' }
  end

  describe 'splats (middle)' do
    let(:args) { %w(args buz a b c d e) }
    it { expect(cmd.a).to eq 'a' }
    it { expect(cmd.b).to eq %w(b c d) }
    it { expect(cmd.c).to eq 'e' }
  end

  describe 'splats (right)' do
    let(:args) { %w(args bum a b c d e) }
    it { expect(cmd.a).to eq 'a' }
    it { expect(cmd.b).to eq 'b' }
    it { expect(cmd.c).to eq %w(c d e) }
  end

  describe 'raises on arguments missing' do
    let(:args) { %w(args foo) }
    it { expect { cmd }.to raise_error(Cl::ArgumentError, 'Missing arguments (given: 0, required: 1)') }
  end

  describe 'raises on too many arguments' do
    let(:args) { %w(args foo 1 2 3) }
    it { expect { cmd }.to raise_error(Cl::ArgumentError, 'Too many arguments (given: 3, allowed: 2)') }
  end

  describe 'raises on wrong argument type (int)' do
    let(:args) { %w(args bar 1 2 a) }
    it { expect { cmd }.to raise_error(Cl::ArgumentError, 'Wrong argument type (given: "a", expected: int)') }
  end

  describe 'raises on wrong argument type (float)' do
    let(:args) { %w(args bar 1 2 3 a) }
    it { expect { cmd }.to raise_error(Cl::ArgumentError, 'Wrong argument type (given: "a", expected: float)') }
  end
end
