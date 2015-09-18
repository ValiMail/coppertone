require 'spec_helper'

describe 'Selecting records' do
  let(:zonefile) do
    { 'example3.com' => [{ 'TXT' => 'v=spf10' }, { 'TXT' => 'v=spf1 mx' }, { 'MX' => [0, 'mail.example1.com'] }], 'example1.com' => [{ 'TXT' => 'v=spf1' }], 'example2.com' => [{ 'TXT' => ['v=spf1', 'mx'] }], 'mail.example1.com' => [{ 'A' => '1.2.3.4' }], 'example4.com' => [{ 'SPF' => 'v=spf1 +all' }, { 'TXT' => 'v=spf1 -all' }], 'example5.com' => [{ 'SPF' => 'v=spf1 +all' }, { 'TXT' => 'v=spf1 -all' }, { 'TXT' => 'v=spf1 +all' }], 'example6.com' => [{ 'TXT' => 'v=spf1 -all' }, { 'TXT' => 'V=sPf1 +all' }], 'example7.com' => [{ 'TXT' => 'v=spf1 -all' }, { 'TXT' => 'v=spf1 -all' }], 'example8.com' => [{ 'SPF' => 'V=spf1 -all' }, { 'SPF' => 'v=spf1 -all' }, { 'TXT' => 'v=spf1 +all' }], 'example9.com' => [{ 'TXT' => 'v=SpF1 ~all' }] }
  end

  let(:dns_client) { DNSAdapter::MockClient.new(zonefile) }
  let(:options) { { dns_client: dns_client } }

  it 'Version must be terminated by space or end of record.  TXT pieces are joined without intervening spaces.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@example2.com', 'mail.example1.com', options)
    expect([:none]).to include(result.code)
  end

  it 'Empty SPF record.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@example1.com', 'mail1.example1.com', options)
    expect([:neutral]).to include(result.code)
  end

  it 'nospace2' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@example3.com', 'mail.example1.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'SPF records no longer used.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@example4.com', 'mail.example1.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'Implementations should give permerror/unknown because of the conflicting TXT records.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@example5.com', 'mail.example1.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'Multiple records is a permerror, v=spf1 is case insensitive' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@example6.com', 'mail.example1.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'Multiple records is a permerror, even when they are identical. However, this situation cannot be reliably reproduced with live DNS since cache and resolvers are allowed to combine identical records.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@example7.com', 'mail.example1.com', options)
    expect([:permerror, :fail]).to include(result.code)
  end

  it 'Ignoring SPF-type records will give pass because there is a (single) TXT record.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@example8.com', 'mail.example1.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'nospf' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@mail.example1.com', 'mail.example1.com', options)
    expect([:none]).to include(result.code)
  end

  it 'v=spf1 is case insensitive' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@example9.com', 'mail.example1.com', options)
    expect([:softfail]).to include(result.code)
  end
end
