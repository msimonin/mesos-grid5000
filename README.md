Mesos-grid5000
==============

Deploy a mesos cluster on Grid'5000.

Inspired by http://mesosphere.com/docs/getting-started/datacenter/install/

Keywords : Grid'5000, puppet, capistrano, hiera, xp5k

# Deployment setup

Excerpt from ```config/deploy/xp5k.rb``` :

```ruby
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
  })```

* master nodes and zookeeper nodes are colocated
* quorum is set to MASTER/2 + 1
* feel free to increase the number of slaves.


# Play with mesos

* clone the repo
* launch ```bundle install``` (you better use ```rvm```)
* ```cap -T``` will show :

```bash
cap automatic    # Automatic deployment
cap clean        # Remove all running jobs
cap deploy       # Deploy with Kadeploy
cap describe     # Describe the cluster
cap invoke       # Invoke a single command on the remote servers.
cap mesos        # Deploy mesos
cap mesos:puppet # Configure nodes using puppet
cap shell        # Begin an interactive Capistrano session.
cap submit       # Submit jobs
````


Launch ```cap automatic```to deploy mesos masters and slaves on Grid'5000 nodes.

# Verify the installation

Please refer to http://mesosphere.com/docs/getting-started/datacenter/install/#verifying-installation

# License

See ```Licence``` file.
