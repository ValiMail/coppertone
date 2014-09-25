require 'spec_helper'

describe 'IP4 mechanism syntax' do
  let(:zonefile) do
    { 'mail.example.com' => [{ 'A' => '1.2.3.4' }], 'e1.example.com' => [{ 'TXT' => 'v=spf1 ip4:1.1.1.1/0 -all' }], 'e2.example.com' => [{ 'TXT' => 'v=spf1 ip4:1.2.3.4/32 -all' }], 'e3.example.com' => [{ 'TXT' => 'v=spf1 ip4:1.2.3.4/33 -all' }], 'e4.example.com' => [{ 'TXT' => 'v=spf1 ip4:1.2.3.4/032 -all' }], 'e5.example.com' => [{ 'TXT' => 'v=spf1 ip4' }], 'e6.example.com' => [{ 'TXT' => 'v=spf1 ip4:1.2.3.4//32' }], 'e7.example.com' => [{ 'TXT' => 'v=spf1 -ip4:1.2.3.4 ip6:::FFFF:1.2.3.4' }], 'e8.example.com' => [{ 'TXT' => 'v=spf1 ip4:1.2.3.4:8080' }], 'e9.example.com' => [{ 'TXT' => 'v=spf1 ip4:1.2.3' }] }
  end

  let(:dns_client) { Coppertone::DNS::MockClient.new(zonefile) }
  let(:options) { { dns_client: dns_client } }

  it 'ip4-cidr-length  = "/" 1*DIGIT' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e1.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'ip4-cidr-length  = "/" 1*DIGIT' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e2.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'Invalid CIDR should get permerror.' do
    # The RFC4408 was silent on ip4 CIDR > 32 or ip6 CIDR > 128, but RFC7208  is explicit.  Invalid CIDR is prohibited.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e3.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'Invalid CIDR should get permerror.' do
    # Leading zeros are not explicitly prohibited by the RFC. However, since the RFC explicity prohibits leading zeros in ip4-network, our interpretation is that CIDR should be also.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e4.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'IP4              = "ip4"      ":" ip4-network   [ ip4-cidr-length ]' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e5.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'IP4              = "ip4"      ":" ip4-network   [ ip4-cidr-length ]' do
    # This has actually been published in SPF records.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e8.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'It is not permitted to omit parts of the IP address instead of using CIDR notations.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e9.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'dual-cidr-length not permitted on ip4' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e6.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'IP4 mapped IP6 connections MUST be treated as IP4' do
    result = Coppertone::SpfService.authenticate_email('::FFFF:1.2.3.4', 'foo@e7.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

end
