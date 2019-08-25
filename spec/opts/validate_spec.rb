describe Cl, 'opts' do
  subject { Class.new(Cl::Cmd, &opts) }

  describe 'no opts' do
    let(:opts) { ->(*) { opt } }
    it { expect { subject }.to raise_error 'No option strings given. Pass one short -s and/or one --long option string.' }
  end

  describe 'wrong opts (two short)' do
    let(:opts) { ->(*) { opt '-a', '-b' } }
    it { expect { subject }.to raise_error 'Wrong option strings given. Pass one short -s and/or one --long option string.' }
  end

  describe 'wrong opts (two long)' do
    let(:opts) { ->(*) { opt '--one', '--two' } }
    it { expect { subject }.to raise_error 'Wrong option strings given. Pass one short -s and/or one --long option string.' }
  end

  describe 'invalid opts' do
    let(:opts) { ->(*) { opt '--one?' } }
    it { expect { subject }.to raise_error 'Invalid option strings given: "--one?"' }
  end
end
