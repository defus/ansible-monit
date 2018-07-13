require 'spec_helper'

describe 'Monit' do
  describe service('monit') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(8080) do
    it { should be_listening.on('0.0.0.0').with('tcp') }
  end

  describe file('/etc/monitrc') do
    it { should be_file }
    it { should be_owned_by 'monit' }
    its(:content) { should match /443/ }
  end

  describe file('/opt/monit/.monit.pid') do
    it { should be_file }
    it { should be_owned_by 'monit' }
    its(:size) { should > 0 }
  end

  describe file('/var/log/monit/monit.log') do
    it { should be_file }
    it { should be_owned_by 'monit' }
    its(:size) { should > 0 }
  end


end
