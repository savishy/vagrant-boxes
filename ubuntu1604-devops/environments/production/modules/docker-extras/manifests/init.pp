class docker-extras {

  define remote_file($remote_location=undef, $mode='0644'){
    exec{"retrieve_${title}":
    command => "/usr/bin/wget -q ${remote_location} -O ${title}",
    creates => $title,
  }

  file{$title:
    mode    => $mode,
    require => Exec["retrieve_${title}"],
  }
}

# download docker compose
remote_file{'/usr/local/bin/docker-compose':
remote_location => 'https://github.com/docker/compose/releases/download/1.8.0/docker-compose-Linux-x86_64',
mode            => '0666',
}

}
