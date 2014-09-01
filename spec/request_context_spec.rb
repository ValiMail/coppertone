require 'spec_helper'

describe Coppertone::RequestContext do
  it 'should have reasonable values by default' do
    ctx = Coppertone::RequestContext.new
    expect(ctx.dns_client).to_not be_nil
    expect(ctx.dns_client.class).to eq(Coppertone::DNS::ResolvClient)
    expect(ctx.message_locale).to eq('en')
    expect(ctx.dns_lookups_per_mx_mechanism_limit).to eq(10)
    expect(ctx.dns_lookups_per_ptr_mechanism_limit).to eq(10)
    expect do
      11.times { ctx.register_dns_lookup_term }
    end.to raise_error(Coppertone::LimitExceededError)
    expect do
      3.times { ctx.register_void_dns_result }
    end.to raise_error(Coppertone::LimitExceededError)
  end

  it 'should allow override of these values using options' do
    dns_client = double
    options = {
      dns_client: dns_client,
      message_locale: 'es',
      terms_requiring_dns_lookup_limit: 20,
      void_dns_result_limit: 4,
      dns_lookups_per_mx_mechanism_limit: 18,
      dns_lookups_per_ptr_mechanism_limit: 17
    }
    ctx = Coppertone::RequestContext.new(options)
    expect(ctx.dns_client).to eq(dns_client)
    expect(ctx.message_locale).to eq('es')
    20.times { ctx.register_dns_lookup_term }
    expect do
      ctx.register_dns_lookup_term
    end.to raise_error(Coppertone::LimitExceededError)
    4.times { ctx.register_void_dns_result }
    expect do
      ctx.register_void_dns_result
    end.to raise_error(Coppertone::LimitExceededError)
    expect(ctx.dns_lookups_per_mx_mechanism_limit).to eq(18)
    expect(ctx.dns_lookups_per_ptr_mechanism_limit).to eq(17)
  end
end
