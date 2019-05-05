describe Cl, 'auto register' do
  after { Object.send(:remove_const, :Test) }

  let(:keys) { Cl.registry.keys }
  let(:cl)   { Cl.runner(ctx, args) }

  describe 'basic' do
    before do
      module Test
        class A < Cl::Cmd; end
        class B < Cl::Cmd; end
        class C < Cl::Cmd; end
        class D < Cl::Cmd; end
      end
    end

    let(:args) { %w(c) }

    it { expect(keys).to eq %i(a b c d) }
    it { expect(cl.cmd).to be_a Test::C }
  end

  describe 'nested' do
    before do
      module Test
        class A < Cl::Cmd; end
        class B < A; end
        class C < B; end
        class D < C; end
      end
    end

    let(:args) { %w(a b c d) }

    it { expect(keys).to eq %i(a a:b a:b:c a:b:c:d) }
    it { expect(cl.cmd).to be_a Test::D }
  end
end
