require 'bundler/setup'
require 'rubygems'
require 'xp5k'
require 'erb'

XP5K::Config.load

MASTER = 3
SLAVE = 3
set :site, ENV['site'] || "toulouse"
set :walltime, ENV['walltime'] || "02:00:00"


$myxp = XP5K::XP.new(:logger => logger)

$myxp.define_job({
  :resources  => ["nodes=#{MASTER + SLAVE}, walltime=#{walltime}"],
  :site       => "#{site}",
  :retry      => true,
  :goal       => "100%",
  :types      => ["deploy"],
  :name       => "init" , 
  :roles      =>  [
    XP5K::Role.new({ :name => 'master', :size => MASTER }),
    XP5K::Role.new({ :name => 'slave', :size => SLAVE }),
  ],

  :command    => "sleep 86400"
})

$myxp.define_deployment({
  :site           => "#{site}",
  :environment    => "wheezy-x64-nfs",
  :roles          => %w(master slave),
  :key            => File.read("#{ssh_public}"), 
})

load "config/deploy/xp5k_common_tasks.rb"
