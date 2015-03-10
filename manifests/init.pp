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

  # Puppet versions <3.5.0 did not support the ssl-key type ed-25519, so turn of storeconfigs for those machines
  # TODO: get the current puppet version from puppetlabs, not the linux distro provider.
  if $::puppetversion =~ /^(3\.5|3\.6|3\.7|4\.0).*/ {
    $storeconfigs_enabled = true
  } else {
    $storeconfigs_enabled = false
  }

  class {'ssh::server':
    storeconfigs_enabled => $storeconfigs_enabled,
    options               => {
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
    require => [ Exec['create-rsa-4k-key'], Exec['create-ed25519-key'] ],
  }

    exec { 'create-rsa-4k-key':
    command => '/usr/bin/ssh-keygen -f /etc/ssh/ssh_host_rsa_4k_key -t rsa -b 4096 -N "" ',
    creates => '/etc/ssh/ssh_host_rsa_4k_key',
    refresh => '/bin/true',
  }

  exec { 'create-ed25519-key':
    command => '/usr/bin/ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -t ed25519 -N "" ',
    creates => '/etc/ssh/ssh_host_ed25519_key',
    refresh => '/bin/true',
  }

  # ensure that ssh public keys are public readable
  file{['/etc/ssh/ssh_host_rsa_4k_key.pub', '/etc/ssh/ssh_host_ed25519_key.pub']:
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [ Exec['create-rsa-4k-key'], Exec['create-ed25519-key'] ],

  }

  # ensure that ssh private keys are only readable by root
  file{['/etc/ssh/ssh_host_rsa_4k_key', '/etc/ssh/ssh_host_ed25519_key']:
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => [ Exec['create-rsa-4k-key'], Exec['create-ed25519-key'] ],
  }


}

