require 'spec_helper'

describe Coppertone::Mechanism::Ptr do
  context '#new' do
    it 'should not fail if called with a nil argument' do
      mech = Coppertone::Mechanism::Ptr.new(nil)
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech).not_to be_includes_ptr
      expect(mech).to be_context_dependent
    end

    it 'should not fail if called with a blank argument' do
      mech = Coppertone::Mechanism::Ptr.new('')
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech).not_to be_includes_ptr
      expect(mech).to be_context_dependent
    end

    it 'should fail if called with an invalid macrostring' do
      expect do
        Coppertone::Mechanism::Ptr.new('abc%:def')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end
  end

  context '#create' do
    it 'should fail if called with a nil argument' do
      mech = Coppertone::Mechanism::Ptr.create(nil)
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
    end

    it 'should fail if called with a blank argument' do
      mech = Coppertone::Mechanism::Ptr.create('')
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
    end

    it 'should fail if called with an argument invalid macrostring' do
      expect do
        Coppertone::Mechanism::Ptr.create('abc%:def')
      end.to raise_error(Coppertone::InvalidMechanismError)
    end
  end

  context 'dns_lookup_term?' do
    it 'should be true' do
      expect(Coppertone::Mechanism::Ptr).to be_dns_lookup_term
      expect(Coppertone::Mechanism::Ptr.new(':example.com')).to be_dns_lookup_term
    end
  end
end
