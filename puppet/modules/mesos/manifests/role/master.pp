class mesos::role::master {

  include mesos::role
  # configure master

  #
  # Zookeeper
  #

  $myid = hiera("mesos::zookeeper::myid")
  #zookeeper are colocated with master in this depoyment
  $zhosts = hiera("mesos::masters")

  package{ 'zookeeper':
    ensure => installed
  }

  file{ '/etc/zookeeper/conf/myid':
    content => $myid,
    require => Package['zookeeper'],
    notify  => Service['zookeeper']
  }

  file{ '/etc/zookeeper/conf/zoo.cfg':
    content => template("mesos/zoo.cfg.erb"),
    require => Package['zookeeper'],
    notify  => Service['zookeeper']
  }

  service{ 'zookeeper': 
    ensure  => running,
    require => Package['zookeeper']
  }

  service{ 'mesos-slave':
    ensure  => stopped,
  }

  service{ 'mesos-master':
    ensure  => running,
    require => [Package['mesos'], File['/etc/mesos/zk']]
  }


}