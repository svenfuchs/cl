require 'cl'

class Bool < Cl::Cmd
  arg :bool, type: :bool

  def run
    [self.registry_key, bool: bool]
  end
end

class Types < Cl::Cmd
  arg :a, type: :bool
  arg :b, type: :int
  arg :c, type: :float
  arg :d

  def run
    [self.registry_key, a: a, b: b, c: c, d: d]
  end
end

def output(cmd, args)
  args = args.map { |key, value| "#{key}=#{value.inspect}" }.join(' ')
  puts "Called #{cmd} with #{args}"
end

output *Cl.run(*%w(bool on))
# Output:
# Called bool with bool=true

output *Cl.run(*%w(bool on))
# Output:
# Called bool with bool=true

output *Cl.run(*%w(bool on))
# Output:
# Called bool with bool=true

output *Cl.run(*%w(bool on))
# Output:
# Called bool with bool=true

output *Cl.run(*%w(types true 1 1.2 foo))
# Output:
# Called types with a=true b=1 c=1.2 d="foo"

output *Cl.run(*%w(types true 1 1.2))
# Output:
# Too many arguments (given: 5, allowed: 4)
#
# Usage: cast.rb types [a (bool)] [b (int)] [c (float)] [d]

output *Cl.run(*%w(types true one 1.2))
# Output:
# Wrong argument type (given: "one", expected: int)
#
# Usage: cast.rb types [a (bool)] [b (int)] [c (float)] [d]

output *Cl.run(*%w(types true 1 one))
# Output:
# Wrong argument type (given: "one", expected: float)
#
# Usage: cast.rb types [a (bool)] [b (int)] [c (float)] [d]
