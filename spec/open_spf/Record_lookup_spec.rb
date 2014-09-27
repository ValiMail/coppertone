require 'spec_helper'

describe 'Record lookup' do
  let(:zonefile) do
    { 'both.example.net' => [{ 'TXT' => 'v=spf1 -all' }, { 'SPF' => 'v=spf1 -all' }], 'txtonly.example.net' => [{ 'TXT' => 'v=spf1 -all' }], 'spfonly.example.net' => [{ 'SPF' => 'v=spf1 -all' }, { 'TXT' => 'NONE' }], 'spftimeout.example.net' => [{ 'TXT' => 'v=spf1 -all' }, 'TIMEOUT'], 'txttimeout.example.net' => [{ 'SPF' => 'v=spf1 -all' }, { 'TXT' => 'NONE' }, 'TIMEOUT'], 'nospftxttimeout.example.net' => [{ 'SPF' => 'v=spf3 !a:yahoo.com -all' }, { 'TXT' => 'NONE' }, 'TIMEOUT'], 'alltimeout.example.net' => ['TIMEOUT'] }
  end

  let(:dns_client) { DNSAdapter::MockClient.new(zonefile) }
  let(:options) { { dns_client: dns_client } }

  it 'both' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@both.example.net', 'mail.example.net', options)
    expect([:fail]).to include(result.code)
  end

  it 'Result is none if checking SPF records only (which you should not be doing).' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@txtonly.example.net', 'mail.example.net', options)
    expect([:fail]).to include(result.code)
  end

  it 'Result is none if checking TXT records only.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@spfonly.example.net', 'mail.example.net', options)
    expect([:none]).to include(result.code)
  end

  it 'TXT record present, but SPF lookup times out. Result is temperror if checking SPF records only.  Fortunately, we dont do type SPF anymore.' do
    # This actually happens for a popular braindead DNS server.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@spftimeout.example.net', 'mail.example.net', options)
    expect([:fail]).to include(result.code)
  end

  it 'SPF record present, but TXT lookup times out. If only TXT records are checked, result is temperror.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@txttimeout.example.net', 'mail.example.net', options)
    expect([:temperror]).to include(result.code)
  end

  it 'No SPF record present, and TXT lookup times out. If only TXT records are checked, result is temperror.' do
    # Because TXT records is where v=spf1 records will likely be, returning temperror will try again later.  A timeout due to a braindead server is unlikely in the case of TXT, as opposed to the newer SPF RR.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@nospftxttimeout.example.net', 'mail.example.net', options)
    expect([:temperror]).to include(result.code)
  end

  it 'Both TXT and SPF queries time out' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@alltimeout.example.net', 'mail.example.net', options)
    expect([:temperror]).to include(result.code)
  end

end
