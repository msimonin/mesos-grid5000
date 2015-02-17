class mesos::role::slave {

  include mesos::role
  # configure master

  #
  # Zookeeper
  #
  $zhosts = hiera("mesos::masters")

  package{ 'zookeeperd':
    ensure => absent
  }

  service{ 'mesos-slave':
    ensure  => running,
    require => [Package['mesos'], File['/etc/mesos/zk']]
  }

  service{ 'mesos-master':
    ensure  => stopped,
  }


}
