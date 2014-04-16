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
    source => 'puppet:///modules/pam-ssh-agent-auth/sudoers',
    owner  => root,
    group  => root,
    mode   => '0440'
  }

  file { '/home_local/ubuntu/.ssh':
    ensure  => directory,
    owner   => 'ubuntu',
    group   => 'ubuntu',
    mode    => 755,
    require => User['ubuntu'],
  }

  file { '/home_local/ubuntu/.ssh/authorized_keys':
    source  => 'puppet:///modules/pam-ssh-agent-auth/root_authorized_keys',
    owner   => ubuntu,
    group   => ubuntu,
    mode    => '0444',
    require => File['/home_local/ubuntu/.ssh'],
  }

  file { '/etc/pam.d/sudo':
    source => 'puppet:///modules/pam-ssh-agent-auth/sudo.pam',
    owner  => root,
    group  => root,
    mode   => '0644',
  }

  file { '/etc/pam.d/login':
    source => 'puppet:///modules/pam-ssh-agent-auth/login.pam',
    owner  => root,
    group  => root,
    mode   => '0644',
  }

  file { '/etc/securetty':
    source => 'puppet:///modules/pam-ssh-agent-auth/securetty',
    owner  => root,
    group  => root,
    mode   => '0644',
  }

  class { 'system::sshd':
    config         => {
      'PubkeyAuthentication'   => {
        value                    => 'yes',
      }
      ,
      'PasswordAuthentication' => {
        value                    => 'no',
      }
      ,
      'ChallengeResponseAuthentication' => {
        value                    => 'no',
      }
      ,
      'UsePAM'                 => {
        value                    => 'yes',
      }
      ,
      'X11Forwarding'          => {
        value                    => 'yes',
      }
      ,
      'PermitRootLogin'        => {
        value                    => 'no',
      }
      ,
      'AllowGroups'            => {
        value                    => ['inf-staff', 'ubuntu'],
      }
      ,
    }
    ,
    sync_host_keys => true,
  }

  class { 'system::sshd::subsystem':
    config => {
      'sftp' => {
        'command' => $::operatingsystem ? {
          Ubuntu  => '/usr/lib/openssh/sftp-server',
          SLES    => '/usr/lib64/ssh/sftp-server',
          default => '/usr/lib/openssh/sftp-server'
        } }
    }
  }
}

