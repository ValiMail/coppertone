require 'spec_helper'

describe 'EXISTS mechanism syntax' do
  let(:zonefile) do
    { 'mail.example.com' => [{ 'A' => '1.2.3.4' }], 'mail6.example.com' => [{ 'AAAA' => 'CAFE:BABE::4' }], 'err.example.com' => ['TIMEOUT'], 'e1.example.com' => [{ 'TXT' => 'v=spf1 exists:' }], 'e2.example.com' => [{ 'TXT' => 'v=spf1 exists' }], 'e3.example.com' => [{ 'TXT' => 'v=spf1 exists:mail.example.com/24' }], 'e4.example.com' => [{ 'TXT' => 'v=spf1 exists:mail.example.com' }], 'e5.example.com' => [{ 'TXT' => 'v=spf1 exists:mail6.example.com -all' }], 'e6.example.com' => [{ 'TXT' => 'v=spf1 exists:err.example.com -all' }] }
  end

  let(:dns_client) { Coppertone::DNS::MockClient.new(zonefile) }
  let(:options) { { dns_client: dns_client } }

  it 'domain-spec cannot be empty.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e1.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'exists           = "exists"   ":" domain-spec' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e2.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'exists           = "exists"   ":" domain-spec' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e3.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'mechanism matches if any DNS A RR exists' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e4.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'The lookup type is A even when the connection is ip6' do
    result = Coppertone::SpfService.authenticate_email('CAFE:BABE::3', 'foo@e4.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'The lookup type is A even when the connection is ip6' do
    result = Coppertone::SpfService.authenticate_email('CAFE:BABE::3', 'foo@e5.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'Result for DNS error clarified in RFC7208: MTAs or other processors  SHOULD impose a limit on the maximum amount of elapsed time to evaluate  check_host().  Such a limit SHOULD allow at least 20 seconds.  If such  a limit is exceeded, the result of authorization SHOULD be "temperror".' do
    result = Coppertone::SpfService.authenticate_email('CAFE:BABE::3', 'foo@e6.example.com', 'mail.example.com', options)
    expect([:temperror]).to include(result.code)
  end

end
