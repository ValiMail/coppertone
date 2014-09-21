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
    end

    it 'should not fail if called with a blank argument' do
      mech = Coppertone::Mechanism::MX.new('')
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq(128)
      expect(mech.to_s).to eq('mx')
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
    end

    it 'should process the domain spec if it includes a IP v6 CIDR' do
      mech = Coppertone::Mechanism::MX.new('//96')
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq(96)
      expect(mech.to_s).to eq('mx//96')
    end

    it 'should process the domain spec if it includes an IP v4 CIDR and an IP v6 CIDR' do
      mech = Coppertone::Mechanism::MX.new('/28//96')
      expect(mech).not_to be_nil
      expect(mech.domain_spec).to be_nil
      expect(mech.ip_v4_cidr_length).to eq(28)
      expect(mech.ip_v6_cidr_length).to eq(96)
      expect(mech.to_s).to eq('mx/28//96')
    end

    it 'should not fail if called with a blank argument' do
      mech = Coppertone::Mechanism::MX.new(':mx.example.com')
      expect(mech).not_to be_nil
      expect(mech.domain_spec)
        .to eq(Coppertone::DomainSpec.new('mx.example.com'))
      expect(mech.ip_v4_cidr_length).to eq(32)
      expect(mech.ip_v6_cidr_length).to eq(128)
      expect(mech.to_s).to eq('mx:mx.example.com')
    end

    it 'should not fail if called with a blank argument' do
      mech = Coppertone::Mechanism::MX.new(':mx.example.com/28//96')
      expect(mech).not_to be_nil
      expect(mech.domain_spec)
        .to eq(Coppertone::DomainSpec.new('mx.example.com'))
      expect(mech.ip_v4_cidr_length).to eq(28)
      expect(mech.ip_v6_cidr_length).to eq(96)
      expect(mech.to_s).to eq('mx:mx.example.com/28//96')
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
