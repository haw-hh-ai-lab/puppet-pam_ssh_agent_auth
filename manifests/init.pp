# configure the authentication
#  - to allow sudo for members of group sw_staff and user ubuntu only
#  - to use ssh-agent forwarding for authenticating to sudo
#  - root login only vi console, without requiring a password
#

class pam_ssh_agent_auth {
  package { 'pam-ssh-agent-auth':
    ensure  => latest,
    require =>  Apt::Source ['cypherfox-ailaddon'],
  }

  file { '/home_local':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0444',
  }

  file { '/home_local/ubuntu':
    ensure  => directory,
    owner   => 'ubuntu',
    group   => 'ubuntu',
    require => File['/home_local'],
  }

  group { 'ubuntu':
    ensure => present,
    gid    => '1001',
  }

  user { 'ubuntu':
    ensure     => present,
    comment    => 'The fallback user',
    gid        => '1001',
    uid        => '1001',
    groups     => ['sudo', 'adm'],
    home       => '/home_local/ubuntu',
    managehome => true,
    password   => 'x',
    shell      => '/bin/bash',
    require    => File['/home_local'],
  }

  file { '/etc/sudoers':
    source => 'puppet:///modules/pam_ssh_agent_auth/sudoers',
    owner  => root,
    group  => root,
    mode   => '0440'
  }


  file { '/etc/pam.d/sudo':
    source => 'puppet:///modules/pam_ssh_agent_auth/sudo.pam',
    owner  => root,
    group  => root,
    mode   => '0644',
  }

  file { '/etc/pam.d/login':
    source => 'puppet:///modules/pam_ssh_agent_auth/login.pam',
    owner  => root,
    group  => root,
    mode   => '0644',
  }

  file { '/etc/securetty':
    source => 'puppet:///modules/pam_ssh_agent_auth/securetty',
    owner  => root,
    group  => root,
    mode   => '0644',
  }

  class {'ssh::server':
    options => {
        'PubkeyAuthentication'             => 'yes',
        'PasswordAuthentication'           => 'no' ,
        'ChallengeResponseAuthentication'  => 'no' ,
        'PermitRootLogin'                  => 'no' ,
        'UsePAM'                           => 'yes',
        'HostKey'                          => [ '/etc/ssh/ssh_host_rsa_4k_key', '/etc/ssh/ssh_host_ed25519_key'],
        'KexAlgorithms'                    => 'curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256',
        'Ciphers'                          => 'chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr',
        'MACs'                             => 'hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-ripemd160-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,hmac-ripemd160,hmac-ripemd160@openssh.com',
        'X11Forwarding'                    => 'yes' ,
        'AllowGroups'                      => [ 'inf-staff', 'ubuntu'],
        'PrintMotd'                        => 'no',
        },
  }
}

