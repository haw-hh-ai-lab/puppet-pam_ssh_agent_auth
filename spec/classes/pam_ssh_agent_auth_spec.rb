require 'spec_helper'

describe 'pam_ssh_agent_auth' do
  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }

  context 'with default settings' do
    it do
      should contain_package('pam-ssh-agent-auth')

      should contain_file('/home_local').with_ensure('directory')

      should contain_file('/home_local/ubuntu').with_ensure('directory')

      should contain_group('ubuntu')
      should contain_user('ubuntu')
      
      should contain_file('/etc/sudoers')
      
      should contain_file('/home_local/ubuntu/.ssh').with_ensure('directory')
      should contain_file('/home_local/ubuntu/.ssh/authorized_keys').with(
      		'owner' => 'ubuntu',
      		'group' => 'ubuntu',
      		'mode'  => '0444',       		
      )
      
      
      should contain_file('/etc/pam.d/login')
      should contain_file('/etc/securetty')
      
      # TODO: SSH config
     end
  end

end

