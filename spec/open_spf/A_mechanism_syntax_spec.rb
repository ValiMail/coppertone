require 'spec_helper'

describe 'A mechanism syntax' do
  let(:zonefile) do
    { 'mail.example.com' => [{ 'A' => '1.2.3.4' }], 'e1.example.com' => [{ 'TXT' => 'v=spf1 a/0 -all' }], 'e2.example.com' => [{ 'A' => '1.1.1.1' }, { 'AAAA' => '1234::2' }, { 'TXT' => 'v=spf1 a/0 -all' }], 'e2a.example.com' => [{ 'AAAA' => '1234::1' }, { 'TXT' => 'v=spf1 a//0 -all' }], 'e2b.example.com' => [{ 'A' => '1.1.1.1' }, { 'TXT' => 'v=spf1 a//0 -all' }], 'ipv6.example.com' => [{ 'AAAA' => '1234::1' }, { 'A' => '1.1.1.1' }, { 'TXT' => 'v=spf1 a -all' }], 'e3.example.com' => [{ 'TXT' => "v=spf1 a:foo.example.com\u0000" }], 'e4.example.com' => [{ 'TXT' => 'v=spf1 a:111.222.33.44' }], 'e5.example.com' => [{ 'TXT' => 'v=spf1 a:abc.123' }], 'e5a.example.com' => [{ 'TXT' => 'v=spf1 a:museum' }], 'e5b.example.com' => [{ 'TXT' => 'v=spf1 a:museum.' }], 'e6.example.com' => [{ 'TXT' => 'v=spf1 a//33 -all' }], 'e6a.example.com' => [{ 'TXT' => 'v=spf1 a/33 -all' }], 'e7.example.com' => [{ 'TXT' => 'v=spf1 a//129 -all' }], 'e8.example.com' => [{ 'A' => '1.2.3.5' }, { 'AAAA' => '2001:db8:1234::dead:beef' }, { 'TXT' => 'v=spf1 a/24//64 -all' }], 'e8e.example.com' => [{ 'A' => '1.2.3.5' }, { 'AAAA' => '2001:db8:1234::dead:beef' }, { 'TXT' => 'v=spf1 a/24/64 -all' }], 'e8a.example.com' => [{ 'A' => '1.2.3.5' }, { 'AAAA' => '2001:db8:1234::dead:beef' }, { 'TXT' => 'v=spf1 a/24 -all' }], 'e8b.example.com' => [{ 'A' => '1.2.3.5' }, { 'AAAA' => '2001:db8:1234::dead:beef' }, { 'TXT' => 'v=spf1 a//64 -all' }], 'e9.example.com' => [{ 'TXT' => 'v=spf1 a:example.com:8080' }], 'e10.example.com' => [{ 'TXT' => 'v=spf1 a:foo.example.com/24' }], 'foo.example.com' => [{ 'A' => '1.1.1.1' }, { 'A' => '1.2.3.5' }], 'e11.example.com' => [{ 'TXT' => 'v=spf1 a:foo:bar/baz.example.com' }], 'foo:bar/baz.example.com' => [{ 'A' => '1.2.3.4' }], 'e12.example.com' => [{ 'TXT' => 'v=spf1 a:example.-com' }], 'e13.example.com' => [{ 'TXT' => 'v=spf1 a:' }], 'e14.example.com' => [{ 'TXT' => 'v=spf1 a:foo.example.xn--zckzah -all' }], 'foo.example.xn--zckzah' => [{ 'A' => '1.2.3.4' }] }
  end

  let(:dns_client) { DNSAdapter::MockClient.new(zonefile) }
  let(:options) { { dns_client: dns_client } }

  it 'A                = "a"      [ ":" domain-spec ] [ dual-cidr-length ] dual-cidr-length = [ ip4-cidr-length ] [ "/" ip6-cidr-length ] ' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e6.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'A                = "a"      [ ":" domain-spec ] [ dual-cidr-length ] dual-cidr-length = [ ip4-cidr-length ] [ "/" ip6-cidr-length ] ' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e6a.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'A                = "a"      [ ":" domain-spec ] [ dual-cidr-length ] dual-cidr-length = [ ip4-cidr-length ] [ "/" ip6-cidr-length ] ' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e7.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'A                = "a"      [ ":" domain-spec ] [ dual-cidr-length ] dual-cidr-length = [ ip4-cidr-length ] [ "/" ip6-cidr-length ] ' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e8.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'A                = "a"      [ ":" domain-spec ] [ dual-cidr-length ] dual-cidr-length = [ ip4-cidr-length ] [ "/" ip6-cidr-length ] ' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e8e.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'A                = "a"      [ ":" domain-spec ] [ dual-cidr-length ] dual-cidr-length = [ ip4-cidr-length ] [ "/" ip6-cidr-length ] ' do
    result = Coppertone::SpfService.authenticate_email('2001:db8:1234::cafe:babe', 'foo@e8.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'A                = "a"      [ ":" domain-spec ] [ dual-cidr-length ] dual-cidr-length = [ ip4-cidr-length ] [ "/" ip6-cidr-length ] ' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e8b.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'A                = "a"      [ ":" domain-spec ] [ dual-cidr-length ] dual-cidr-length = [ ip4-cidr-length ] [ "/" ip6-cidr-length ] ' do
    result = Coppertone::SpfService.authenticate_email('2001:db8:1234::cafe:babe', 'foo@e8a.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'A matches any returned IP.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e10.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'A matches any returned IP.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e10.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'domain-spec must pass basic syntax checks; a : may appear in domain-spec, but not in top-label' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e9.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'If no ips are returned, A mechanism does not match, even with /0.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e1.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'Matches if any A records are present in DNS.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e2.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'Matches if any A records are present in DNS.' do
    result = Coppertone::SpfService.authenticate_email('1234::1', 'foo@e2.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'Would match if any AAAA records are present in DNS, but not for an IP4 connection.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e2a.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'Would match if any AAAA records are present in DNS, but not for an IP4 connection.' do
    result = Coppertone::SpfService.authenticate_email('::FFFF:1.2.3.4', 'foo@e2a.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'Matches if any AAAA records are present in DNS.' do
    result = Coppertone::SpfService.authenticate_email('1234::1', 'foo@e2a.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'Simple IP6 Address match with dual stack.' do
    result = Coppertone::SpfService.authenticate_email('1234::1', 'foo@ipv6.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'No match if no AAAA records are present in DNS.' do
    result = Coppertone::SpfService.authenticate_email('1234::1', 'foo@e2b.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'Null octets not allowed in toplabel' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.5', 'foo@e3.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'toplabel may not be all numeric' do
    # A common publishing mistake is using ip4 addresses with A mechanism. This should receive special diagnostic attention in the permerror.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e4.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'toplabel may not be all numeric' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e5.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'toplabel may contain dashes' do
    # Going from the "toplabel" grammar definition, an implementation using regular expressions in incrementally parsing SPF records might erroneously try to match a TLD such as ".xn--zckzah" (cf. IDN TLDs!) to \'( *alphanum ALPHA *alphanum )\' first before trying the alternative \'( 1*alphanum "-" *( alphanum / "-" ) alphanum )\', essentially causing a non-greedy, and thus, incomplete match.  Make sure a greedy match is performed!
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e14.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'toplabel may not begin with a dash' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e12.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'domain-spec may not consist of only a toplabel.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e5a.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'domain-spec may not consist of only a toplabel.' do
    # "A trailing dot doesn\'t help."
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e5b.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'domain-spec may contain any visible char except %' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e11.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'domain-spec may contain any visible char except %' do
    result = Coppertone::SpfService.authenticate_email('::FFFF:1.2.3.4', 'foo@e11.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'domain-spec cannot be empty.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e13.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

end
