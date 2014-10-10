require 'spec_helper'

describe Coppertone::Modifier::Exp do
  context '#new' do
    it 'should work with a context independent domain spec' do
      modifier = Coppertone::Modifier::Exp.new('test.example.com')
      expect(modifier).not_to be_nil
      expect(modifier.domain_spec)
        .to eq(Coppertone::DomainSpec.new('test.example.com'))
      expect(modifier.to_s)
        .to eq('exp=test.example.com')
      expect(modifier).not_to be_includes_ptr
      expect(modifier).not_to be_context_dependent
    end

    it 'should work with a context independent domain spec' do
      modifier = Coppertone::Modifier::Exp.new('%{d}.example.com')
      expect(modifier).not_to be_nil
      expect(modifier.domain_spec)
        .to eq(Coppertone::DomainSpec.new('%{d}.example.com'))
      expect(modifier.to_s)
        .to eq('exp=%{d}.example.com')
      expect(modifier).not_to be_includes_ptr
      expect(modifier).to be_context_dependent
    end

    it 'should work with a context independent domain spec with a PTR' do
      modifier = Coppertone::Modifier::Exp.new('%{p}.example.com')
      expect(modifier).not_to be_nil
      expect(modifier.domain_spec)
        .to eq(Coppertone::DomainSpec.new('%{p}.example.com'))
      expect(modifier.to_s)
        .to eq('exp=%{p}.example.com')
      expect(modifier).to be_includes_ptr
      expect(modifier).to be_context_dependent
    end
  end

  context 'to_s' do
    it 'should result in the expected string' do
      expect(Coppertone::Modifier::Exp.new('test.example.com').to_s)
        .to eq('exp=test.example.com')
    end
  end
end
