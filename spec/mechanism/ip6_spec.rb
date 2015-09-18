require 'spec_helper'

describe Coppertone::Mechanism::IP6 do
  context '#new' do
    it 'should fail if called with a nil argument' do
      expect do
        Coppertone::Mechanism::IP6.new(nil)
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should fail if called with a blank argument' do
      expect do
        Coppertone::Mechanism::IP6.new('')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should fail if called with an invalid IP' do
      expect do
        Coppertone::Mechanism::IP6.new(':not_an_ip')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should not fail if called with an IP v4' do
      mech = Coppertone::Mechanism::IP6.new(':1.2.3.4')
      expect(mech.netblock).to eq(IPAddr.new('1.2.3.4'))
      expect(mech).not_to be_dns_lookup_term
    end

    it 'should work if called with an IP6' do
      mech = Coppertone::Mechanism::IP6.new(':fe80::202:b3ff:fe1e:8329')
      expect(mech.netblock)
        .to eq(IPAddr.new('fe80::202:b3ff:fe1e:8329'))
      expect(mech).not_to be_dns_lookup_term
    end

    it 'should work if called with an IP6 with a pfxlen' do
      mech = Coppertone::Mechanism::IP6.new(':fe80::202:b3ff:fe1e:8329/64')
      expect(mech.netblock)
        .to eq(IPAddr.new('fe80::202:b3ff:fe1e:8329/64'))
      expect(mech).not_to be_dns_lookup_term
    end

    it 'should fail if called with an invalid pfxlen' do
      expect do
        Coppertone::Mechanism::IP6.new(':fe80::202:b3ff:fe1e:8329/384')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end
  end

  context '#create' do
    it 'should fail if called with a nil argument' do
      expect do
        Coppertone::Mechanism::IP6.create(nil)
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should fail if called with a blank argument' do
      expect do
        Coppertone::Mechanism::IP6.create('')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should fail if called with an invalid IP' do
      expect do
        Coppertone::Mechanism::IP6.create(':not_an_ip')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should not fail if called with an IP v4' do
      mech = Coppertone::Mechanism::IP6.create(':1.2.3.4')
      expect(mech.netblock).to eq(IPAddr.new('1.2.3.4'))
      expect(mech).not_to be_includes_ptr
      expect(mech).not_to be_context_dependent
    end

    it 'should work if called with an IP6' do
      mech = Coppertone::Mechanism::IP6.create(':fe80::202:b3ff:fe1e:8329')
      expect(mech.netblock)
        .to eq(IPAddr.new('fe80::202:b3ff:fe1e:8329'))
      expect(mech).not_to be_includes_ptr
      expect(mech).not_to be_context_dependent
    end

    it 'should work if called with an IP6 with a pfxlen' do
      mech = Coppertone::Mechanism::IP6.create(':fe80::202:b3ff:fe1e:8329/64')
      expect(mech.netblock)
        .to eq(IPAddr.new('fe80::202:b3ff:fe1e:8329/64'))
      expect(mech).not_to be_includes_ptr
      expect(mech).not_to be_context_dependent
    end
  end

  context '.match' do
    let(:client_ip) { IPAddr.new('fe80::202:b3ff:fe1e:8329') }

    let(:macro_context) do
      mc = double(:macro_context)
      allow(mc).to receive(:ip_v6).and_return(client_ip)
      mc
    end

    it 'should return true if the client IP is in the network' do
      mech = Coppertone::Mechanism::IP6.create(':fe80:0:0:0:202:b3ff:fe1e:8300/120')
      expect(mech.match?(macro_context, double)).to eq(true)
    end

    it 'should return false if the client IP is not in the network' do
      mech = Coppertone::Mechanism::IP6.create(':fe80:0:0:0:202:b3ff:fe1e:8300/126')
      expect(mech.match?(macro_context, double)).to eq(false)
    end
  end

  context 'dns_lookup_term?' do
    it 'should be false' do
      expect(Coppertone::Mechanism::IP6).not_to be_dns_lookup_term
      expect(Coppertone::Mechanism::IP6.create(':fe80::202:b3ff:fe1e:8329')).not_to be_dns_lookup_term
    end
  end
end
