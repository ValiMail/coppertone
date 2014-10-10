require 'spec_helper'

describe Coppertone::Mechanism::All do
  subject { Coppertone::Mechanism::All.instance }
  it 'should always return true regardless of argument' do
    expect(subject.match?(double, double)).to eq(true)
    expect(subject.to_s).to eq('all')
    expect(subject).not_to be_includes_ptr
    expect(subject).not_to be_context_dependent
  end

  it 'should not allow creation of new instances' do
    expect do
      Coppertone::Mechanism::All.new('')
    end.to raise_error(NoMethodError)
  end

  context '#create' do
    it 'should fail if any arguments are passed that are not blank' do
      expect do
        Coppertone::Mechanism::All.create('abcd')
      end.to raise_error(Coppertone::RecordParsingError)
    end
  end

  context 'dns_lookup_term?' do
    it 'should be false' do
      expect(Coppertone::Mechanism::All).not_to be_dns_lookup_term
      expect(Coppertone::Mechanism::All.instance).not_to be_dns_lookup_term
    end
  end
end
