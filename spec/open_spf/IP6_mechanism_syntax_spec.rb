require 'spec_helper'

describe 'IP6 mechanism syntax' do
  let(:zonefile) do
    { 'mail.example.com' => [{ 'A' => '1.2.3.4' }], 'e1.example.com' => [{ 'TXT' => 'v=spf1 -all ip6' }], 'e2.example.com' => [{ 'TXT' => 'v=spf1 ip6:::1.1.1.1/0' }], 'e3.example.com' => [{ 'TXT' => 'v=spf1 ip6:::1.1.1.1/129' }], 'e4.example.com' => [{ 'TXT' => 'v=spf1 ip6:::1.1.1.1//33' }], 'e5.example.com' => [{ 'TXT' => 'v=spf1 ip6:CAFE:BABE:8000::/33' }], 'e6.example.com' => [{ 'TXT' => 'v=spf1 ip6::CAFE::BABE' }] }
  end

  let(:dns_client) { Coppertone::DNS::MockClient.new(zonefile) }
  let(:options) { { dns_client: dns_client } }

  it 'IP6              = "ip6"      ":" ip6-network   [ ip6-cidr-length ]' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e1.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'IP4 connections do not match ip6.' do
    # There was controversy over IPv4 mapped connections.  RFC7208 clearly states IPv4 mapped addresses only match ip4: mechanisms.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e2.example.com', 'mail.example.com', options)
    expect([:neutral]).to include(result.code)
  end

  it 'Even if the SMTP connection is via IPv6, an IPv4-mapped IPv6 IP address (see RFC 3513, Section 2.5.5) MUST still be considered an IPv4 address.' do
    # There was controversy over ip4 mapped connections.  RFC7208 clearly requires such connections to be considered as ip4 only.
    result = Coppertone::SpfService.authenticate_email('::FFFF:1.2.3.4', 'foo@e2.example.com', 'mail.example.com', options)
    expect([:neutral]).to include(result.code)
  end

  it 'Match any IP6' do
    result = Coppertone::SpfService.authenticate_email('DEAF:BABE::CAB:FEE', 'foo@e2.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'Invalid CIDR' do
    # IP4 only implementations MUST fully syntax check all mechanisms, even if they otherwise ignore them.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e3.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'dual-cidr syntax not used for ip6' do
    # IP4 only implementations MUST fully syntax check all mechanisms, even if they otherwise ignore them.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e4.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'make sure ip4 cidr restriction are not used for ip6' do
    result = Coppertone::SpfService.authenticate_email('CAFE:BABE:8000::', 'foo@e5.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'make sure ip4 cidr restriction are not used for ip6' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e5.example.com', 'mail.example.com', options)
    expect([:neutral]).to include(result.code)
  end

  it '' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e6.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

end
