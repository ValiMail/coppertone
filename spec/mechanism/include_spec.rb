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

    it 'creates a mechanism if called with a valid macrostring' do
      mech = Coppertone::Mechanism::Include.new(':_spf.example.com')
      expect(mech.to_s).to eq('include:_spf.example.com')
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
