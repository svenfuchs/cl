require 'cl'

module Heroku
  module Apps
    class Create < Cl::Cmd
      register 'apps:create'

      arg :name, required: true

      opt '-o', '--org ORG' do |value|
        opts[:org] = value
      end

      def run; [registry_key, args, opts] end
    end

    class List < Cl::Cmd
      register 'apps:info'

      opt '-a', '--app APP' do |value|
        opts[:app] = value
      end

      def run; [registry_key, args, opts] end
    end
  end
end

def output(cmd, args, opts)
  puts "Called #{cmd} with args=#{args} opts=#{opts}"
end

output *Cl.run(*%w(apps:create name -o org))
# Called apps:create with args=["name"] opts={:org=>"org"}

output *Cl.run(*%w(apps create name -o org))
# Called apps:create with args=["name"] opts={:org=>"org"}

output *Cl.run(*%w(apps:info -a app))
# Called apps:create with args=["app"] opts={}

