# install oracle dba client
class install_oraclient {

  # prerequisite for sqlplus command.
  package{'libaio1':
    ensure => 'latest'
  }
  package{'libaio-dev':
    ensure => 'latest'
  }

  # download sqlplus zip
  # unzip it
  # references:
  # https://ask.puppet.com/question/16774/how-do-i-unzip-a-file/
  common::remote_file{'/tmp/sqlplus.zip':
    remote_location => 'https://github.com/savishy/vagrant-boxes/releases/download/v0.3.0/sqlplus.zip',
    mode            => '0777',
  }

  exec { 'unzip sqlplus':
    command     => '/usr/bin/unzip /tmp/sqlplus.zip -d /opt/',
    cwd         => '/tmp/',
    user        => 'root',
    creates     => '/opt/sqlplus/sqlplus',
  } ~>
  exec { 'change ownership of sqlplus directory':
    command => '/bin/chown -R vagrant:vagrant /opt/sqlplus'
  } ~>
  exec { 'change permissions of sqlplus binary':
    command => '/bin/chmod 777 /opt/sqlplus/sqlplus'
  }
  # TODO: add var LD_LIBRARY_PATH containing path to sqlplus directory extracted above.
  # add var SQLPATH=sqlplus directory.
  # add above directory to PATH.

}
