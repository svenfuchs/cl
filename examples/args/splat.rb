require 'cl'

class SplatLeft < Cl::Cmd
  register 'splat:left'

  arg :one, type: :array
  args :two, :three

  def run
    [self.registry_key, one: one, two: two, three: three]
  end
end

class SplatMiddle < Cl::Cmd
  register 'splat:middle'

  arg :one
  arg :two, type: :array
  arg :three

  def run
    [self.registry_key, one: one, two: two, three: three]
  end
end

class SplatRight < Cl::Cmd
  register 'splat:right'

  args :one, :two
  arg :three, type: :array

  def run
    [self.registry_key, one: one, two: two, three: three]
  end
end

def output(cmd, args)
  args = args.map { |key, value| "#{key}=#{value.inspect}" }.join(' ')
  puts "Called #{cmd} with #{args}"
end

output *Cl.run($1, *%w(splat left foo bar baz buz))
# Output:
# Called splat:left with one=["foo", "bar"] two="baz" three="buz"

output *Cl.run($1, *%w(splat middle foo bar baz buz))
# Output:
# Called splat:middle with one="foo" two=["bar", "baz"] three="buz"

output *Cl.run($1, *%w(splat right foo bar baz buz))
# Output:
# Called splat:middle with one="foo" two="bar" three=["baz", "buz"]
