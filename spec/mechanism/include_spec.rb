require 'spec_helper'

describe Coppertone::Mechanism::Include do
  context '#new' do
    it 'should fail if called with a nil argument' do
      expect do
        Coppertone::Mechanism::Include.new(nil)
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should fail if called with a blank argument' do
      expect do
        Coppertone::Mechanism::Include.new('')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should fail if called with an invalid macrostring' do
      expect do
        Coppertone::Mechanism::Include.new(':abc%:def')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should parse a context independent domain spec' do
      mech = Coppertone::Mechanism::Include.new(':_spf.example.com')
      expect(mech).not_to be_nil
      expect(mech.domain_spec)
        .to eq(Coppertone::DomainSpec.new('_spf.example.com'))
      expect(mech.to_s).to eq('include:_spf.example.com')
      expect(mech).not_to be_includes_ptr
      expect(mech).not_to be_context_dependent
      expect(mech).to be_dns_lookup_term
      expect(mech.target_domain).to eq('_spf.example.com')
    end

    it 'should parse a context dependent domain spec' do
      mech = Coppertone::Mechanism::Include.new(':_spf.%{d}.example.com')
      expect(mech).not_to be_nil
      expect(mech.domain_spec)
        .to eq(Coppertone::DomainSpec.new('_spf.%{d}.example.com'))
      expect(mech.to_s).to eq('include:_spf.%{d}.example.com')
      expect(mech).not_to be_includes_ptr
      expect(mech).to be_context_dependent
      expect(mech).to be_dns_lookup_term
      expect do
        mech.target_domain
      end.to raise_error Coppertone::NeedsContextError
    end

    it 'should parse a domain spec with a ptr' do
      mech = Coppertone::Mechanism::Include.new(':_spf.%{p}.example.com')
      expect(mech).not_to be_nil
      expect(mech.domain_spec)
        .to eq(Coppertone::DomainSpec.new('_spf.%{p}.example.com'))
      expect(mech.to_s).to eq('include:_spf.%{p}.example.com')
      expect(mech).to be_includes_ptr
      expect(mech).to be_context_dependent
      expect(mech).to be_dns_lookup_term
      expect do
        mech.target_domain
      end.to raise_error Coppertone::NeedsContextError
    end
  end

  context '#create' do
    it 'should fail if called with a nil argument' do
      expect do
        Coppertone::Mechanism::Include.create(nil)
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should fail if called with a blank argument' do
      expect do
        Coppertone::Mechanism::Include.create('')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end

    it 'should fail if called with an argument invalid macrostring' do
      expect do
        Coppertone::Mechanism::Include.create('abc%:def')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end
  end

  context 'dns_lookup_term?' do
    it 'should be true' do
      expect(Coppertone::Mechanism::Include).to be_dns_lookup_term
      expect(Coppertone::Mechanism::Include.new(':example.com')).to be_dns_lookup_term
    end
  end
end
