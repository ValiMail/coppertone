require 'spec_helper'

describe 'Include mechanism semantics and syntax' do
  let(:zonefile) do
    { 'mail.example.com' => [{ 'A' => '1.2.3.4' }], 'ip5.example.com' => [{ 'TXT' => 'v=spf1 ip4:1.2.3.5 -all' }], 'ip6.example.com' => [{ 'TXT' => 'v=spf1 ip4:1.2.3.6 ~all' }], 'ip7.example.com' => [{ 'TXT' => 'v=spf1 ip4:1.2.3.7 ?all' }], 'ip8.example.com' => ['TIMEOUT'], 'erehwon.example.com' => [{ 'TXT' => 'v=spfl am not an SPF record' }], 'e1.example.com' => [{ 'TXT' => 'v=spf1 include:ip5.example.com ~all' }], 'e2.example.com' => [{ 'TXT' => 'v=spf1 include:ip6.example.com all' }], 'e3.example.com' => [{ 'TXT' => 'v=spf1 include:ip7.example.com -all' }], 'e4.example.com' => [{ 'TXT' => 'v=spf1 include:ip8.example.com -all' }], 'e5.example.com' => [{ 'TXT' => 'v=spf1 include:e6.example.com -all' }], 'e6.example.com' => [{ 'TXT' => 'v=spf1 include +all' }], 'e7.example.com' => [{ 'TXT' => 'v=spf1 include:erehwon.example.com -all' }], 'e8.example.com' => [{ 'TXT' => 'v=spf1 include: -all' }], 'e9.example.com' => [{ 'TXT' => 'v=spf1 include:ip5.example.com/24 -all' }] }
  end

  let(:dns_client) { DNSAdapter::MockClient.new(zonefile) }
  let(:options) { { dns_client: dns_client } }

  it 'recursive check_host() result of fail causes include to not match.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e1.example.com', 'mail.example.com', options)
    expect([:softfail]).to include(result.code)
  end

  it 'recursive check_host() result of softfail causes include to not match.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e2.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'recursive check_host() result of neutral causes include to not match.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e3.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'recursive check_host() result of temperror causes include to temperror' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e4.example.com', 'mail.example.com', options)
    expect([:temperror]).to include(result.code)
  end

  it 'recursive check_host() result of permerror causes include to permerror' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e5.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'include          = "include"  ":" domain-spec' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e6.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'include          = "include"  ":" domain-spec' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e9.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'recursive check_host() result of none causes include to permerror' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e7.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'domain-spec cannot be empty.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e8.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

end
