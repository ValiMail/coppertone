require 'spec_helper'

describe Coppertone::Modifier::Redirect do
  context '#new' do
    it 'should work with a context independent domain spec' do
      modifier = Coppertone::Modifier::Redirect.new('test.example.com')
      expect(modifier).not_to be_nil
      expect(modifier.domain_spec)
        .to eq(Coppertone::DomainSpec.new('test.example.com'))
      expect(modifier.to_s)
        .to eq('redirect=test.example.com')
      expect(modifier).not_to be_includes_ptr
      expect(modifier).not_to be_context_dependent
      expect(modifier.target_domain).to eq('test.example.com')
    end

    it 'should work with a context independent domain spec' do
      modifier = Coppertone::Modifier::Redirect.new('%{d}.example.com')
      expect(modifier).not_to be_nil
      expect(modifier.domain_spec)
        .to eq(Coppertone::DomainSpec.new('%{d}.example.com'))
      expect(modifier.to_s)
        .to eq('redirect=%{d}.example.com')
      expect(modifier).not_to be_includes_ptr
      expect(modifier).to be_context_dependent
      expect do
        modifier.target_domain
      end.to raise_error Coppertone::NeedsContextError
    end

    it 'should work with a context independent domain spec with a PTR' do
      modifier = Coppertone::Modifier::Redirect.new('%{p}.example.com')
      expect(modifier).not_to be_nil
      expect(modifier.domain_spec)
        .to eq(Coppertone::DomainSpec.new('%{p}.example.com'))
      expect(modifier.to_s)
        .to eq('redirect=%{p}.example.com')
      expect(modifier).to be_includes_ptr
      expect(modifier).to be_context_dependent
      expect do
        modifier.target_domain
      end.to raise_error Coppertone::NeedsContextError
    end
  end

  context 'to_s' do
    it 'should result in the expected string' do
      expect(Coppertone::Modifier::Redirect.new('test.example.com').to_s)
        .to eq('redirect=test.example.com')
    end
  end

  context '#included_record' do
    it 'should delegate to included_record' do
      modifier = Coppertone::Modifier::Redirect.new('test.example.com')
      record = double(:record)
      finder = double(:finder)
      expect(finder).to receive(:record).and_return(record)
      macro_ctx = double(:macro_ctx)
      request_ctx = double(:request_ctx)
      expect(Coppertone::RedirectRecordFinder).to receive(:new)
        .with(modifier, macro_ctx, request_ctx).and_return(finder)
      expect(modifier.included_record(macro_ctx, request_ctx))
        .to eq(record)
    end
  end
end
