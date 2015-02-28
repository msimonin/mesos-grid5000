class mesos::role{
  
  $zhosts = hiera("mesos::masters")
  $hadoop_url = hiera("hadoop::url")
  $namenode = hiera("hadoop::dfs::namenode")
  $replication = hiera("hadoop::dfs::replication")
  
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

  ## HDFS

  exec{ 'hadoop_tarball':
    command => "wget $hadoop_url -O /opt/hadoop.tar.gz",
    path    => ['/usr/bin'],
    creates  => '/opt/hadoop.tar.gz'
  }

  exec { 'hadoop_extract':
    command => "tar -xzf hadoop.tar.gz",
    path    => ["/bin"],
    cwd     => '/opt',
    require => Exec['hadoop_tarball']
  }

  exec { 'hadoop_rename':
    command => 'mv hadoop-* hadoop',
    path    => ['/bin', '/usr/bin'],
    cwd     => '/opt',
    onlyif  => 'test ! -d hadoop',
    require => Exec['hadoop_extract']
  }

  file { '/opt/hadoop/conf/core-site.xml':
    content => template("mesos/core-site.xml.erb"),
    require => Exec['hadoop_rename']
  }

  file { '/opt/hadoop/conf/hdfs-site.xml':
    content => template("mesos/hdfs-site.xml.erb"),
    require => Exec['hadoop_rename']
  }

  file { '/opt/hadoop/conf/hadoop-env.sh':
    content => template("mesos/hadoop-env.sh.erb"),
    require => Exec['hadoop_rename']
  }

}
