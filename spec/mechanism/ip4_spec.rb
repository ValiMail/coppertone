require 'spec_helper'

describe Coppertone::Mechanism::IP4 do
  context '#new' do
    it 'should fail if called with a nil argument' do
      expect do
        Coppertone::Mechanism::IP4.new(nil)
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should fail if called with a blank argument' do
      expect do
        Coppertone::Mechanism::IP4.new('')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should fail if called with an invalid IP' do
      expect do
        Coppertone::Mechanism::IP4.new(':not_an_ip')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should not fail if called with an IP v6' do
      mech = Coppertone::Mechanism::IP4.new(':fe80::202:b3ff:fe1e:8329')
      expect(mech.ip_network).to eq(IPAddr.new('fe80::202:b3ff:fe1e:8329'))
      expect(mech.to_s).to eq('ip4:fe80::202:b3ff:fe1e:8329')
      expect(mech).not_to be_includes_ptr
      expect(mech).not_to be_context_dependent
    end

    it 'should work if called with an IP4' do
      mech = Coppertone::Mechanism::IP4.new(':1.2.3.4')
      expect(mech.ip_network).to eq(IPAddr.new('1.2.3.4'))
      expect(mech.to_s).to eq('ip4:1.2.3.4')
      expect(mech).not_to be_includes_ptr
      expect(mech).not_to be_context_dependent
    end

    it 'should work if called with an IP4 with a pfxlen' do
      mech = Coppertone::Mechanism::IP4.new(':1.2.3.4/4')
      expect(mech.ip_network).to eq(IPAddr.new('1.2.3.4/4'))
      expect(mech.to_s).to eq('ip4:1.2.3.4/4')
      expect(mech).not_to be_includes_ptr
      expect(mech).not_to be_context_dependent
    end
  end

  context '#create' do
    it 'should fail if called with a nil argument' do
      expect do
        Coppertone::Mechanism::IP4.create(nil)
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should fail if called with a blank argument' do
      expect do
        Coppertone::Mechanism::IP4.create('')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should fail if called with an invalid IP' do
      expect do
        Coppertone::Mechanism::IP4.create(':not_an_ip')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should not fail if called with an IP v6' do
      mech = Coppertone::Mechanism::IP4.create(':fe80::202:b3ff:fe1e:8329')
      expect(mech.ip_network).to eq(IPAddr.new('fe80::202:b3ff:fe1e:8329'))
    end

    it 'should work if called with an IP4' do
      mech = Coppertone::Mechanism::IP4.create(':1.2.3.4')
      expect(mech.ip_network).to eq(IPAddr.new('1.2.3.4'))
    end

    it 'should work if called with an IP4 with a pfxlen' do
      mech = Coppertone::Mechanism::IP4.create(':1.2.3.4/4')
      expect(mech.ip_network).to eq(IPAddr.new('1.2.3.4/4'))
    end

    it 'should fail if called with an invalid pfxlen' do
      expect do
        Coppertone::Mechanism::IP4.new(':1.2.3.4/127')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end
  end

  context '.match' do
    let(:client_ip) { IPAddr.new('4.5.6.7') }

    let(:macro_context) do
      mc = double(:macro_context)
      allow(mc).to receive(:ip_v4).and_return(client_ip)
      mc
    end

    let(:ip_v6_macro_context) do
      mc = double(:macro_context)
      allow(mc).to receive(:ip_v4).and_return(nil)
      mc
    end

    it 'should return true if the client IP is in the network' do
      mech = Coppertone::Mechanism::IP4.create(':4.5.6.0/29')
      expect(mech.match?(macro_context, double)).to eq(true)
    end

    it 'should return false if the client IP is not in the network' do
      mech = Coppertone::Mechanism::IP4.create(':4.5.6.0/30')
      expect(mech.match?(macro_context, double)).to eq(false)
    end

    it 'should return false if the client IP is v6 only' do
      mech = Coppertone::Mechanism::IP4.create(':4.5.6.0/29')
      expect(mech.match?(ip_v6_macro_context, double)).to eq(false)
    end
  end

  context 'dns_lookup_term?' do
    it 'should be false' do
      expect(Coppertone::Mechanism::IP4).not_to be_dns_lookup_term
      expect(Coppertone::Mechanism::IP4.create(':4.5.6.7')).not_to be_dns_lookup_term
    end
  end
end
