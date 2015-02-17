require 'bundler/setup'
require 'rubygems'
require 'xp5k'
require 'erb'

XP5K::Config.load

set :site, ENV['site'] || "toulouse"
set :walltime, ENV['walltime'] || "02:00:00"

$myxp = XP5K::XP.new(:logger => logger)

$myxp.define_job({
  :resources  => ["nodes=4, walltime=#{walltime}"],
  :site       => "#{site}",
  :retry      => true,
  :goal       => "100%",
  :types      => ["deploy"],
  :name       => "init" , 
  :roles      =>  [
    XP5K::Role.new({ :name => 'master', :size => 3 }),
    XP5K::Role.new({ :name => 'slave', :size => 1 }),
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
