require 'spec_helper'

describe 'PTR mechanism syntax' do
  let(:zonefile) do
    { 'mail.example.com' => [{ 'A' => '1.2.3.4' }], 'e1.example.com' => [{ 'TXT' => 'v=spf1 ptr/0 -all' }], 'e2.example.com' => [{ 'TXT' => 'v=spf1 ptr:example.com -all' }], '4.3.2.1.in-addr.arpa' => [{ 'PTR' => 'e3.example.com' }, { 'PTR' => 'e4.example.com' }, { 'PTR' => 'mail.example.com' }], '1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.E.B.A.B.E.F.A.C.ip6.arpa' => [{ 'PTR' => 'e3.example.com' }], 'e3.example.com' => [{ 'TXT' => 'v=spf1 ptr -all' }, { 'A' => '1.2.3.4' }, { 'AAAA' => 'CAFE:BABE::1' }], 'e4.example.com' => [{ 'TXT' => 'v=spf1 ptr -all' }], 'e5.example.com' => [{ 'TXT' => 'v=spf1 ptr:' }] }
  end

  let(:dns_client) { DNSAdapter::MockClient.new(zonefile) }
  let(:options) { { dns_client: dns_client } }

  it 'PTR              = "ptr"    [ ":" domain-spec ]' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e1.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'Check all validated domain names to see if they end in the <target-name> domain.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e2.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'Check all validated domain names to see if they end in the <target-name> domain.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e3.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'Check all validated domain names to see if they end in the <target-name> domain.' do
    # This PTR record does not validate
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e4.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'Check all validated domain names to see if they end in the <target-name> domain.' do
    result = Coppertone::SpfService.authenticate_email('CAFE:BABE::1', 'foo@e3.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'domain-spec cannot be empty.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e5.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end
end
