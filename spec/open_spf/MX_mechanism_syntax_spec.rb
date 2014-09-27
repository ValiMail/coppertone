require 'spec_helper'

describe 'MX mechanism syntax' do
  let(:zonefile) do
    { 'mail.example.com' => [{ 'A' => '1.2.3.4' }, { 'MX' => [0, ''] }, { 'TXT' => 'v=spf1 mx' }], 'e1.example.com' => [{ 'TXT' => 'v=spf1 mx/0 -all' }, { 'MX' => [0, 'e1.example.com'] }], 'e2.example.com' => [{ 'A' => '1.1.1.1' }, { 'AAAA' => '1234::2' }, { 'MX' => [0, 'e2.example.com'] }, { 'TXT' => 'v=spf1 mx/0 -all' }], 'e2a.example.com' => [{ 'AAAA' => '1234::1' }, { 'MX' => [0, 'e2a.example.com'] }, { 'TXT' => 'v=spf1 mx//0 -all' }], 'e2b.example.com' => [{ 'A' => '1.1.1.1' }, { 'MX' => [0, 'e2b.example.com'] }, { 'TXT' => 'v=spf1 mx//0 -all' }], 'e3.example.com' => [{ 'TXT' => "v=spf1 mx:foo.example.com\u0000" }], 'e4.example.com' => [{ 'TXT' => 'v=spf1 mx' }, { 'A' => '1.2.3.4' }], 'e5.example.com' => [{ 'TXT' => 'v=spf1 mx:abc.123' }], 'e6.example.com' => [{ 'TXT' => 'v=spf1 mx//33 -all' }], 'e6a.example.com' => [{ 'TXT' => 'v=spf1 mx/33 -all' }], 'e7.example.com' => [{ 'TXT' => 'v=spf1 mx//129 -all' }], 'e9.example.com' => [{ 'TXT' => 'v=spf1 mx:example.com:8080' }], 'e10.example.com' => [{ 'TXT' => 'v=spf1 mx:foo.example.com/24' }], 'foo.example.com' => [{ 'MX' => [0, 'foo1.example.com'] }], 'foo1.example.com' => [{ 'A' => '1.1.1.1' }, { 'A' => '1.2.3.5' }], 'e11.example.com' => [{ 'TXT' => 'v=spf1 mx:foo:bar/baz.example.com' }], 'foo:bar/baz.example.com' => [{ 'MX' => [0, 'foo:bar/baz.example.com'] }, { 'A' => '1.2.3.4' }], 'e12.example.com' => [{ 'TXT' => 'v=spf1 mx:example.-com' }], 'e13.example.com' => [{ 'TXT' => 'v=spf1 mx: -all' }] }
  end

  let(:dns_client) { DNSAdapter::MockClient.new(zonefile) }
  let(:options) { { dns_client: dns_client } }

  it 'MX                = "mx"      [ ":" domain-spec ] [ dual-cidr-length ] dual-cidr-length = [ ip4-cidr-length ] [ "/" ip6-cidr-length ] ' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e6.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'MX                = "mx"      [ ":" domain-spec ] [ dual-cidr-length ] dual-cidr-length = [ ip4-cidr-length ] [ "/" ip6-cidr-length ] ' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e6a.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'MX                = "mx"      [ ":" domain-spec ] [ dual-cidr-length ] dual-cidr-length = [ ip4-cidr-length ] [ "/" ip6-cidr-length ] ' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e7.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'MX matches any returned IP.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e10.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'MX matches any returned IP.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e10.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'domain-spec must pass basic syntax checks' do
    # A \':\' may appear in domain-spec, but not in top-label.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e9.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'If no ips are returned, MX mechanism does not match, even with /0.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e1.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'Matches if any A records for any MX records are present in DNS.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e2.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'cidr4 doesnt apply to IP6 connections.' do
    # The IP6 CIDR starts with a double slash.
    result = Coppertone::SpfService.authenticate_email('1234::1', 'foo@e2.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'Would match if any AAAA records for MX records are present in DNS, but not for an IP4 connection.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e2a.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'Would match if any AAAA records for MX records are present in DNS, but not for an IP4 connection.' do
    result = Coppertone::SpfService.authenticate_email('::FFFF:1.2.3.4', 'foo@e2a.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'Matches if any AAAA records for any MX records are present in DNS.' do
    result = Coppertone::SpfService.authenticate_email('1234::1', 'foo@e2a.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'No match if no AAAA records for any MX records are present in DNS.' do
    result = Coppertone::SpfService.authenticate_email('1234::1', 'foo@e2b.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'Null not allowed in top-label.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.5', 'foo@e3.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'Top-label may not be all numeric' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e5.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'Domain-spec may contain any visible char except %' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e11.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'Domain-spec may contain any visible char except %' do
    result = Coppertone::SpfService.authenticate_email('::FFFF:1.2.3.4', 'foo@e11.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'Toplabel may not begin with -' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e12.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'test null MX' do
    # Some implementations have had trouble with null MX
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', '', 'mail.example.com', options)
    expect([:neutral]).to include(result.code)
  end

  it 'If the target name has no MX records, check_host() MUST NOT pretend the target is its single MX, and MUST NOT default to an A lookup on the target-name directly.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e4.example.com', 'mail.example.com', options)
    expect([:neutral]).to include(result.code)
  end

  it 'domain-spec cannot be empty.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e13.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

end
