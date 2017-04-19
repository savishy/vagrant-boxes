class accurev {

  # download docker compose
  common::remote_file{'/tmp/accurev.zip':
    remote_location => 'https://github.com/savishy/vagrant-boxes/releases/download/v1.0.0/AccuRev_5_4_0_LinuxClientOnly_x86_2_4.zip',
    mode            => '0777',
  } ~>
  exec  { 'unzip':
    command => '/usr/bin/unzip /tmp/accurev.zip -d /tmp/'
  }


}
