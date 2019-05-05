require 'cl'

module Rakeish
  module Db
    class Create < Cl::Cmd
      register 'db:create'

      arg :name

      def run; [registry_key, args, opts] end
    end

    class Drop < Cl::Cmd
      register 'db:drop'

      arg :name

      opt '-f', '--force' do
        opts[:force] = true
      end

      def run; [registry_key, args, opts] end
    end

    class Migrate < Cl::Cmd
      register 'db:migrate'

      arg :name

      opt '-v', '--version VERSION' do |value|
        opts[:version] = value
      end

      def run; [registry_key, args, opts] end
    end
  end
end

def output(result)
  result.each do |cmd, args, opts|
    puts "Called #{cmd} with args=#{args} opts=#{opts}"
  end
end

Cl.runner = :multi
output Cl.run($1, *%w(db:drop production -f db:create db:migrate production -v 1))
# Output:
# Called db:drop with args=["production"] opts={:force=>true}
# Called db:create with args=[] opts={}
# Called db:migrate with args=["production"] opts={:version=>"1"}
