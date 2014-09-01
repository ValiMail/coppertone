require 'spec_helper'

describe Coppertone::Mechanism::MX do
  context '#new' do
    it 'should not fail if called with a nil argument' do
      mech = Coppertone::Mechanism::MX.new(nil)
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq(128)
    end

    it 'should not fail if called with a blank argument' do
      mech = Coppertone::Mechanism::MX.new('')
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq(128)
    end

    it 'should fail if called with an invalid macrostring' do
      expect do
        Coppertone::Mechanism::MX.new('abc%:def')
      end.to raise_error(Coppertone::InvalidMechanismError)
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
end
