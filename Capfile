require 'bundler/setup'
require 'rubygems'
require 'capistrano'
require 'colored'
require 'xp5k'

load "config/deploy.rb"
load "roles.rb"

set :user, "root"

proxy = {
  'https_proxy' => 'http://proxy:3128',
  'http_proxy' => 'http://proxy:3128',
}

desc 'Automatic deployment'
task :automatic do
 puts "Welcome to automatic deployment".bold.blue
end

after :automatic, :submit, :deploy, :mesos

namespace :mesos do
  
  desc 'Deploy mesos'
  task :default do
    puppet::default
  end


  namespace :puppet do
  
    desc 'Configure nodes using puppet'
    task :default do
      puppet
      generateSitepp
      generateHiera
      transfer
      apply_master
      apply_slave
    end



    task :puppet, :roles => [:mesos] do
      set :default_environment, proxy
      run 'curl https://raw.githubusercontent.com/pmorillon/puppet-puppet/master/extras/bootstrap/puppet_install.sh | PUPPET_VERSION=3.7.1 sh'
    end

    task :generateSitepp do
      masters = find_servers :roles => [:mesos_master]
      manifest = "" 
      masters.each do |master| 
        manifest += %{
          node '#{master.host}' {
            class {::mesos::role::master: }
          }
        }
      end

      slaves = find_servers :roles => [:mesos_slave]
      slaves.each do |slave| 
        manifest += %{
          node '#{slave.host}' {
            class {::mesos::role::slave: }
          }
        }
      end

      File.write('puppet/manifests/site.pp', manifest)
    end

    task :generateHiera do
      @masters = find_servers :roles => [:mesos_master]
      @slaves = (find_servers :roles => [:mesos_slave])
      @namenode = (find_servers :roles => [:namenode]).first.host
      @datanodes = (find_servers :roles => [:datanode])

      # generate common.yaml
      template = File.read("templates/common.yaml.erb")
      renderer = ERB.new(template, nil, '-<>')
      generate = renderer.result(binding)
      myFile = File.open("puppet/common.yaml", "w")
      myFile.write(generate)
      myFile.close
      # generate node specific 
      @myid = 1
      @masters.each do |master|
        # zookeeper id
        template = File.read("templates/node.yaml.erb")
        renderer = ERB.new(template, nil, '-<>')
        generate = renderer.result(binding)
        myFile = File.open("puppet/node/#{master.host}.yaml", "w")
        myFile.write(generate)
        myFile.close
        @myid = @myid + 1
      end

    end
    
    task :transfer, :roles => [:mesos] do
        upload "puppet", "/etc/", :recursive => :true, :via => :scp  
    end

    task :apply_master, :roles => [:mesos_master] do
      set :default_environment, proxy
      run "puppet apply /etc/puppet/manifests/site.pp"
    end

    task :apply_slave, :roles => [:mesos_slave] do
      set :default_environment, proxy
      run "puppet apply /etc/puppet/manifests/site.pp"
    end

  end


end

namespace :hdfs do
  
  desc 'format the HDFS'
  task :create, :roles => [:namenode] do
    run "/opt/hadoop/bin/hadoop namenode -format"   
  end

  namespace :start do
    
    desc 'Start the HDFS cluster' 
    task :default do
      namenode
      datanode
    end

    task :namenode, :roles => [:namenode] do
      run "/opt/hadoop/bin/hadoop-daemon.sh start namenode"
    end

    task :datanode, :roles => [:datanode] do
      run "/opt/hadoop/bin/hadoop-daemon.sh start datanode"
    end

  end # namespace start
end # namespace hdfs


