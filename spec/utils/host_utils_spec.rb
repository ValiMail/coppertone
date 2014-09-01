require 'spec_helper'

describe Coppertone::Utils::HostUtils do
  context '#hostname' do
    let(:raw_hostname) { SecureRandom.hex(10) }
    let(:no_error_hostname) { SecureRandom.hex(10) }
    let(:hostname_list) { [no_error_hostname, SecureRandom.hex(10)] }

    before do
      allow(Socket).to receive(:gethostname).and_return(raw_hostname)
      Coppertone::Utils::HostUtils.clear_hostname
    end

    it 'should retrieve the hostname based on gethostbyname' do
      allow(Socket).to receive(:gethostbyname)
        .with(raw_hostname).and_return(hostname_list)
      expect(Coppertone::Utils::HostUtils.hostname).to eq(no_error_hostname)
      expect(Socket).not_to receive(:gethostname)
      expect(Socket).not_to receive(:gethostbyname)
      expect(Coppertone::Utils::HostUtils.hostname).to eq(no_error_hostname)
    end

    it 'should retrieve the hostname based on gethostname' do
      expect(Socket).to receive(:gethostbyname)
        .with(raw_hostname).and_raise(SocketError)
      expect(Coppertone::Utils::HostUtils.hostname).to eq(raw_hostname)
      expect(Socket).not_to receive(:gethostname)
      expect(Socket).not_to receive(:gethostbyname)
      expect(Coppertone::Utils::HostUtils.hostname).to eq(raw_hostname)
    end
  end
end
