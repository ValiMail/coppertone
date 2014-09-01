require 'spec_helper'

describe Coppertone::Mechanism::A do
  context '#new' do
    it 'should not fail if called with a nil argument' do
      mech = Coppertone::Mechanism::A.new(nil)
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq(128)
    end

    it 'should not fail if called with a blank argument' do
      mech = Coppertone::Mechanism::A.new('')
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq(128)
    end

    it 'should fail if called with an invalid macrostring' do
      expect do
        Coppertone::Mechanism::A.new(':abc%:def')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should parse a domain spec' do
      mech = Coppertone::Mechanism::A.new(':_spf.%{d}.example.com')
      expect(mech).not_to be_nil
      expect(mech.domain_spec)
        .to eq(Coppertone::DomainSpec.new('_spf.%{d}.example.com'))
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq(128)
    end

    it 'should parse a valid IP v4 CIDR length with a domain spec' do
      mech = Coppertone::Mechanism::A.new(':_spf.%{d}.example.com/28')
      expect(mech).not_to be_nil
      expect(mech.domain_spec)
        .to eq(Coppertone::DomainSpec.new('_spf.%{d}.example.com'))
      expect(mech.ip_v4_cidr_length).to eq('28')
      expect(mech.ip_v6_cidr_length).to eq(128)
    end

    it 'should fail if called with an invalid macrostring and IPv4 CIDR' do
      expect do
        Coppertone::Mechanism::A.new(':abc%:def/28')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should parse a valid IP v4 CIDR length' do
      mech = Coppertone::Mechanism::A.new('/28')
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech.ip_v4_cidr_length).to eq('28')
      expect(mech.ip_v6_cidr_length).to eq(128)
    end

    it 'should not parse an invalid IP v4 CIDR length' do
      expect do
        Coppertone::Mechanism::A.new('/36')
      end.to raise_error(Coppertone::InvalidMechanismError)

      expect do
        Coppertone::Mechanism::A.new('/a')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should parse a valid IP v6 CIDR length with a domain spec' do
      mech = Coppertone::Mechanism::A.new(':_spf.%{d}.example.com//64')
      expect(mech).not_to be_nil
      expect(mech.domain_spec)
        .to eq(Coppertone::DomainSpec.new('_spf.%{d}.example.com'))
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq('64')
    end

    it 'should fail if called with an invalid macrostring and IPv6 CIDR' do
      expect do
        Coppertone::Mechanism::A.new(':abc%:def//64')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should parse a valid IP v6 CIDR length' do
      mech = Coppertone::Mechanism::A.new('//64')
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq('64')
    end

    it 'should not parse an invalid IP v6 CIDR length' do
      expect do
        Coppertone::Mechanism::A.new('//133')
      end.to raise_error(Coppertone::InvalidMechanismError)

      expect do
        Coppertone::Mechanism::A.new('//a')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should parse a valid dual CIDR length with a domain spec' do
      mech = Coppertone::Mechanism::A.new(':_spf.%{d}.example.com/28//64')
      expect(mech).not_to be_nil
      expect(mech.domain_spec)
        .to eq(Coppertone::DomainSpec.new('_spf.%{d}.example.com'))
      expect(mech.ip_v4_cidr_length).to eq('28')
      expect(mech.ip_v6_cidr_length).to eq('64')
    end

    it 'should not parse a invalid dual CIDR length with a domain spec' do
      expect do
        Coppertone::Mechanism::A.new('_spf.%{d}.example.com/28//133')
      end.to raise_error(Coppertone::InvalidMechanismError)
      expect do
        Coppertone::Mechanism::A.new('_spf.%{d}.example.com/44//64')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should fail if called with an invalid macrostring and dual CIDR' do
      expect do
        Coppertone::Mechanism::A.new('abc%:def/28//64')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end
  end

  context '#create' do
    it 'should fail if called with a nil argument' do
      mech = Coppertone::Mechanism::A.create(nil)
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq(128)
    end

    it 'should fail if called with a blank argument' do
      mech = Coppertone::Mechanism::A.create('')
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq(128)
    end

    it 'should fail if called with an argument invalid macrostring' do
      expect do
        Coppertone::Mechanism::A.create('abc%:def')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end
  end

  context '#match?' do
    context 'simple' do
      let(:mech_domain) { 'gmail.com' }
      let(:mech_arg) { ":#{mech_domain}" }
      let(:gmail_dns_client) do
        dc = double(:dns_client)
        allow(dc).to receive(:fetch_a_records)
          .with(mech_domain).and_return([
            {
              type: 'A',
              address: '74.125.239.117'
            },
            {
              type: 'A',
              address: '74.125.239.118'
            }
          ])
        dc
      end

      let(:domain) { 'yahoo.com' }
      let(:matching_context) do
        Coppertone::MacroContext.new(domain, '74.125.239.118', 'bob@gmail.com')
      end

      let(:not_matching_context) do
        Coppertone::MacroContext.new(domain, '74.125.249.118', 'bob@gmail.com')
      end

      before do
        allow(Coppertone::DNS::ResolvClient)
          .to receive(:new).and_return(gmail_dns_client)
      end

      it 'should match when the IP matches the record' do
        mech = Coppertone::Mechanism::A.create(mech_arg)
        expect(mech.match?(matching_context, Coppertone::RequestContext.new))
          .to eq(true)
      end

      it 'should not match when the IP does not match the record' do
        mech = Coppertone::Mechanism::A.create(mech_arg)
        expect(mech.match?(not_matching_context, Coppertone::RequestContext.new))
          .to eq(false)
      end
    end
  end
end
