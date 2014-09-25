require 'spec_helper'

describe 'ALL mechanism syntax' do
  let(:zonefile) do
    { 'mail.example.com' => [{ 'A' => '1.2.3.4' }], 'e1.example.com' => [{ 'TXT' => 'v=spf1 -all.' }], 'e2.example.com' => [{ 'TXT' => 'v=spf1 -all:foobar' }], 'e3.example.com' => [{ 'TXT' => 'v=spf1 -all/8' }], 'e4.example.com' => [{ 'TXT' => 'v=spf1 ?all' }], 'e5.example.com' => [{ 'TXT' => 'v=spf1 all -all' }] }
  end

  let(:dns_client) { Coppertone::DNS::MockClient.new(zonefile) }
  let(:options) { { dns_client: dns_client } }

  it 'all              = "all" ' do
    # At least one implementation got this wrong
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e1.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'all              = "all" ' do
    # At least one implementation got this wrong
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e2.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'all              = "all" ' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e3.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'all              = "all" ' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e4.example.com', 'mail.example.com', options)
    expect([:neutral]).to include(result.code)
  end

  it 'all              = "all" ' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e5.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

end
