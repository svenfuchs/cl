describe Cl::Config do
  before do
    base = Class.new(Cl::Cmd) do
      opt '--all'
    end

    Class.new(base) do
      register :a
      opt '--[no-]foo-foo'
      opt '--foo-bar BAR'
    end

    Class.new(base) do
      register :b
      opt '--[no-]bar-bar'
      opt '--bar-baz BAZ'
    end
  end

  let(:ctx) { Cl::Ctx.new('cl') }
  subject   { ctx.config }

  describe 'env' do
    env CL_A_ALL: true,
        CL_A_FOO_FOO: true,
        CL_A_FOO_BAR: 'bar',
        CL_B_BAR_BAR: false,
        CL_B_BAR_BAZ: 'baz'

    it do
      should eq(
        a: {
          all: true,
          foo_foo: true,
          foo_bar: 'bar'
        },
        b: {
          bar_bar: false,
          bar_baz: 'baz'
        }
      )
    end

    it { expect(cmd(%w(a)).foo_foo?).to be true }
    it { expect(cmd(%w(a --no-foo-foo)).foo_foo?).to be false }
    it { expect(cmd(%w(a)).foo_bar).to eq 'bar' }

    it { expect(cmd(%w(b)).bar_bar).to be false }
    it { expect(cmd(%w(b --no-bar-bar)).bar_bar?).to be false }
    it { expect(cmd(%w(b)).bar_baz).to eq 'baz' }
  end

  describe 'files' do
    let(:opts) { { a: { foo_foo: true, foo_bar: 'bar' }, b: { bar_bar: false } } }

    describe '~/.cl.yml' do
      before { write '~/.cl.yml', yaml(opts) }
      it { should eq opts }

      it { expect(cmd(%w(a)).foo_foo?).to be true }
      it { expect(cmd(%w(a --no-foo-foo)).foo_foo?).to be false }
    end

    describe './.cl.yml' do
      before { write './.cl.yml', yaml(opts) }
      it { should eq opts }

      it { expect(cmd(%w(a)).foo_foo?).to be true }
      it { expect(cmd(%w(a --no-foo-foo)).foo_foo?).to be false }
    end

    describe 'local takes precedence' do
      file '~/.cl.yml', yaml(a: { foo_foo: false }, b: { bar_bar: false })
      file './.cl.yml', yaml(a: { foo_foo: true, foo_bar: 'bar' })

      it { should eq opts }

      it { expect(cmd(%w(a)).foo_foo?).to be true }
      it { expect(cmd(%w(a --no-foo-foo)).foo_foo?).to be false }
    end

    describe 'with an empty file' do
      before { write './.cl.yml', '' }
      it { should be_empty }
    end
  end

  describe 'both env and files' do
    env CL_A_FOO_FOO: 'foo foo',
        CL_B_BAR_BAR: 'bar bar'

    file '~/.cl.yml', yaml(a: { foo_foo: 'FOO FOO' }, b: { bar_baz: 'bar baz' })

    it do
      should eq(
        a: { foo_foo: 'foo foo' },
        b: { bar_bar: 'bar bar', bar_baz: 'bar baz' }
      )
    end
  end
end
