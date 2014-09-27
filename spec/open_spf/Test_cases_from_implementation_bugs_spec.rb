require 'spec_helper'

describe 'Test cases from implementation bugs' do
  let(:zonefile) do
    { 'example.org' => [{ 'TXT' => 'v=spf1 mx redirect=_spf.example.com' }, { 'MX' => [10, 'smtp.example.org'] }, { 'MX' => [10, 'smtp1.example.com'] }], 'smtp.example.org' => [{ 'A' => '198.51.100.2' }, { 'AAAA' => '2001:db8:ff0:100::3' }], 'smtp1.example.com' => [{ 'A' => '192.0.2.26' }, { 'AAAA' => '2001:db8:ff0:200::2' }], '2.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.1.0.0.F.F.0.8.B.D.0.1.0.0.2.ip6.arpa' => [{ 'PTR' => 'smtp6-v.fe.example.org' }], 'smtp6-v.fe.example.org' => [{ 'AAAA' => '2001:db8:ff0:100::2' }], '_spf.example.com' => [{ 'TXT' => 'v=spf1 ptr:fe.example.org ptr:sgp.example.com exp=_expspf.example.org -all' }], '_expspf.example.org' => [{ 'TXT' => 'Sender domain not allowed from this host. Please see http://www.openspf.org/Why?s=mfrom&id=%{S}&ip=%{C}&r=%{R}' }] }
  end

  let(:dns_client) { DNSAdapter::MockClient.new(zonefile) }
  let(:options) { { dns_client: dns_client } }

  it 'Bytes vs str bug from pyspf.' do
    # Pyspf failed with strict=2 only.  Other implementations may ignore the strict parameter.
    result = Coppertone::SpfService.authenticate_email('2001:db8:ff0:100::2', 'test@example.org', 'example.org', options)
    expect([:pass]).to include(result.code)
  end

end
