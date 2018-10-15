# this is a defined resource type.
# https://docs.puppet.com/puppet/latest/lang_defined_types.html
# it helps to retrieve remote file
define common::remote_file(
  $remote_location=undef,
  $mode='0644'
  ){
    exec{"retrieve_${title}":
    command => "/usr/bin/wget -q ${remote_location} -O ${title}",
    creates => $title,
    }

    file{$title:
      mode    => $mode,
      require => Exec["retrieve_${title}"],
    }
  }
