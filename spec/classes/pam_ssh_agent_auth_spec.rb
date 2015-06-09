require 'spec_helper'

describe 'pam_ssh_agent_auth' do
  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
  let(:facts) {{ 
    # the module concat needs this. Normaly set by concat through pluginsync
    :concat_basedir         => '/tmp/concatdir',
    :osfamily => 'Debian', 
    :operatingsystem => 'Ubuntu',
    :operatingsystemrelease => '15.04',
    :lsbdistrelease => '15.04',
    :lsbdistid => 'Ubuntu', }}

  context 'with default settings' do
    it do
      should contain_package('pam-ssh-agent-auth')

      should contain_file('/home_local').with_ensure('directory')

      should contain_file('/home_local/ubuntu').with_ensure('directory')

      should contain_group('ubuntu')
      should contain_user('ubuntu')
      
      should contain_file('/etc/sudoers')
      
      should contain_file('/etc/pam.d/login')
      should contain_file('/etc/securetty')
      
      # TODO: SSH config
     end
  end

end

