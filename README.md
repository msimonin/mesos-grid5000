Mesos-grid5000
==============

Deploy a mesos cluster on Grid'5000.

Inspired by http://mesosphere.com/docs/getting-started/datacenter/install/

Keywords : Grid'5000, puppet, capistrano, hiera, xp5k

# Deployment setup

Excerpt from ```config/deploy/xp5k.rb``` :

```ruby
$myxp.define_job({
  :resources  => ["nodes=13, walltime=#{walltime}"],
  :site       => "#{site}",
  :retry      => true,
  :goal       => "100%",
  :types      => ["deploy"],
  :name       => "init" ,
  :roles      =>  [
    XP5K::Role.new({ :name => 'master', :size => 3 }),
    XP5K::Role.new({ :name => 'slave', :size => 10 }),  
  ],

  :command    => "sleep 86400"
  })
```

* master nodes and zookeeper nodes are colocated
* quorum is set to 2 (hard coded for now)
* feel free to increase the number of slaves.


# Play with mesos

* clone the repo
* launch ```bundle install``` (you better use ```rvm```)
* ```cap -T``` will show :

```bash
automatic    # Automatic deployment
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
