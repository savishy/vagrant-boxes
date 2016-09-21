include system
include ansible

# setup docker as a daemon
# add vagrant to docker users for sudoless access
class {'docker':
  tcp_bind        => ['tcp://127.0.0.1:2375'],
  socket_bind     => 'unix:///var/run/docker.sock',
  docker_users    => ['vagrant']
}

# download typically used docker images
docker::image {'ubuntu':
  image_tag => '16.04'
}

docker::image {'jenkins':
  image_tag => '2.7.1'
}
