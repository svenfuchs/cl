require 'cl'

class Opts < Cl::Cmd
  opt '-p', '--path PATH' do |value|
    opts[:path] = value
  end

  opt '-v', '--verbose' do
    opts[:verbose] = true
  end

  def run
    [self.registry_key, args, opts]
  end
end

def output(cmd, args, opts)
  puts "Called #{cmd} with args=#{args} opts=#{opts}"
end

output *Cl.run(*%w(opts -p path -v))
# Output:
# Called cast with args=[] opts={:path=>"path", :verbose=>true}

output *Cl.run(*%w(opts --path path --verbose))
# Output:
# Called cast with args=[] opts={:path=>"path", :verbose=>true}

output *Cl.run(*%w(opts one -p path two -v three))
# Output:
# Called cast with args=["one", "two", "three"] opts={:path=>"path", :verbose=>true}

