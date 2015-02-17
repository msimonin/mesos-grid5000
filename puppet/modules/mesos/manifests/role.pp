class mesos::role{
  
  $zhosts = hiera("mesos::masters")
  
  # install mesos key
  exec{'mesos-key':
    command => "apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv DF7D54CBE56151BF",
    path    => ['/bin', '/usr/bin']
  }
  
  $url = $::lsbdistid ? {
    'Debian' => "deb http://repos.mesosphere.io/debian $::lsbdistcodename main"
  }

  file{'/etc/apt/sources.list.d/mesosphere.list':
    content => "$url"
  }

  exec{'update':
    command => "apt-get -y update",
    path    => ['/bin', '/usr/bin']
  }

  package{'mesos':
    ensure => installed
  }

  Exec['mesos-key'] -> 
  File['/etc/apt/sources.list.d/mesosphere.list'] -> 
  Exec['update'] -> 
  Package['mesos']

  #
  # mesos configuration
  # common to master and slaves
  #
  file{ '/etc/mesos/zk':
    content => template("mesos/zk.erb"),
    require => Package['mesos'],
    notify  => [Service['mesos-master'], Service['mesos-slave']]
  }

  # hard coded -> fix?  
  file{ '/etc/mesos-master/quorum':
    content => template("mesos/quorum.erb"),
    require => Package['mesos'],
    notify  => Service['mesos-master']
  }


}
