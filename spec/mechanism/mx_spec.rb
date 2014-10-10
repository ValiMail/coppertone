require 'spec_helper'

describe Coppertone::Mechanism::MX do
  context '#new' do
    it 'should not fail if called with a nil argument' do
      mech = Coppertone::Mechanism::MX.new(nil)
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq(128)
      expect(mech.to_s).to eq('mx')
      expect(mech).not_to be_includes_ptr
      expect(mech).to be_context_dependent
    end

    it 'should not fail if called with a blank argument' do
      mech = Coppertone::Mechanism::MX.new('')
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq(128)
      expect(mech.to_s).to eq('mx')
      expect(mech).not_to be_includes_ptr
      expect(mech).to be_context_dependent
    end

    it 'should fail if called with an invalid macrostring' do
      expect do
        Coppertone::Mechanism::MX.new('abc%:def')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should process the domain spec if it includes a IP v4 CIDR' do
      mech = Coppertone::Mechanism::MX.new('/24')
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech.ip_v4_cidr_length).to eq(24)
      expect(mech.ip_v6_cidr_length).to eq(128)
      expect(mech.to_s).to eq('mx/24')
      expect(mech).not_to be_includes_ptr
      expect(mech).to be_context_dependent
    end

    it 'should process the domain spec if it includes a IP v6 CIDR' do
      mech = Coppertone::Mechanism::MX.new('//96')
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq(96)
      expect(mech.to_s).to eq('mx//96')
      expect(mech).not_to be_includes_ptr
      expect(mech).to be_context_dependent
    end

    it 'should process the domain spec if it includes an IP v4 CIDR and an IP v6 CIDR' do
      mech = Coppertone::Mechanism::MX.new('/28//96')
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech.ip_v4_cidr_length).to eq(28)
      expect(mech.ip_v6_cidr_length).to eq(96)
      expect(mech.to_s).to eq('mx/28//96')
      expect(mech).not_to be_includes_ptr
      expect(mech).to be_context_dependent
    end

    it 'should not fail if called with a fixed domain spec without explicit CIDRs' do
      mech = Coppertone::Mechanism::MX.new(':mx.example.com')
      expect(mech).not_to be_nil
      expect(mech.domain_spec)
        .to eq(Coppertone::DomainSpec.new('mx.example.com'))
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq(128)
      expect(mech.to_s).to eq('mx:mx.example.com')
      expect(mech).not_to be_includes_ptr
      expect(mech).not_to be_context_dependent
    end

    it 'should not fail if called with a fixed domain spec with explicit CIDRs' do
      mech = Coppertone::Mechanism::MX.new(':mx.example.com/28//96')
      expect(mech).not_to be_nil
      expect(mech.domain_spec)
        .to eq(Coppertone::DomainSpec.new('mx.example.com'))
      expect(mech.ip_v4_cidr_length).to eq(28)
      expect(mech.ip_v6_cidr_length).to eq(96)
      expect(mech.to_s).to eq('mx:mx.example.com/28//96')
    end

    it 'should not fail if called with a context-dependent domain spec without explicit CIDRs' do
      mech = Coppertone::Mechanism::MX.new(':%{d}.example.com')
      expect(mech).not_to be_nil
      expect(mech.domain_spec)
        .to eq(Coppertone::DomainSpec.new('%{d}.example.com'))
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq(128)
      expect(mech.to_s).to eq('mx:%{d}.example.com')
      expect(mech).not_to be_includes_ptr
      expect(mech).to be_context_dependent
    end

    it 'should not fail if called with a fixed domain spec with explicit CIDRs' do
      mech = Coppertone::Mechanism::MX.new(':%{d}.example.com/28//96')
      expect(mech).not_to be_nil
      expect(mech.domain_spec)
        .to eq(Coppertone::DomainSpec.new('%{d}.example.com'))
      expect(mech.ip_v4_cidr_length).to eq(28)
      expect(mech.ip_v6_cidr_length).to eq(96)
      expect(mech.to_s).to eq('mx:%{d}.example.com/28//96')
      expect(mech).not_to be_includes_ptr
      expect(mech).to be_context_dependent
    end

    it 'should not fail if called with a context-dependent domain spec without explicit CIDRs with PTR' do
      mech = Coppertone::Mechanism::MX.new(':%{p}.example.com')
      expect(mech).not_to be_nil
      expect(mech.domain_spec)
        .to eq(Coppertone::DomainSpec.new('%{p}.example.com'))
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq(128)
      expect(mech.to_s).to eq('mx:%{p}.example.com')
      expect(mech).to be_includes_ptr
      expect(mech).to be_context_dependent
    end

    it 'should not fail if called with a fixed domain spec with explicit CIDRs with PTR' do
      mech = Coppertone::Mechanism::MX.new(':%{p}.example.com/28//96')
      expect(mech).not_to be_nil
      expect(mech.domain_spec)
        .to eq(Coppertone::DomainSpec.new('%{p}.example.com'))
      expect(mech.ip_v4_cidr_length).to eq(28)
      expect(mech.ip_v6_cidr_length).to eq(96)
      expect(mech.to_s).to eq('mx:%{p}.example.com/28//96')
      expect(mech).to be_includes_ptr
      expect(mech).to be_context_dependent
    end
  end

  context '#create' do
    it 'should fail if called with a nil argument' do
      mech = Coppertone::Mechanism::MX.create(nil)
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq(128)
    end

    it 'should fail if called with a blank argument' do
      mech = Coppertone::Mechanism::MX.create('')
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq(128)
    end

    it 'should fail if called with an argument invalid macrostring' do
      expect do
        Coppertone::Mechanism::MX.create('abc%:def')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end
  end

  context 'dns_lookup_term?' do
    it 'should be true' do
      expect(Coppertone::Mechanism::MX).to be_dns_lookup_term
      expect(Coppertone::Mechanism::MX.new(':example.com')).to be_dns_lookup_term
    end
  end
end
