require 'spec_helper'

describe 'Macro expansion rules' do
  let(:zonefile) do
    { 'example.com.d.spf.example.com' => [{ 'TXT' => 'v=spf1 redirect=a.spf.example.com' }], 'a.spf.example.com' => [{ 'TXT' => 'v=spf1 include:o.spf.example.com. ~all' }], 'o.spf.example.com' => [{ 'TXT' => 'v=spf1 ip4:192.168.218.40' }], 'msgbas2x.cos.example.com' => [{ 'A' => '192.168.218.40' }], 'example.com' => [{ 'A' => '192.168.90.76' }, { 'TXT' => 'v=spf1 redirect=%{d}.d.spf.example.com.' }], 'exp.example.com' => [{ 'TXT' => 'v=spf1 exp=msg.example.com. -all' }], 'msg.example.com' => [{ 'TXT' => 'This is a test.' }], 'e1.example.com' => [{ 'TXT' => 'v=spf1 -exists:%(ir).sbl.example.com ?all' }], 'e1e.example.com' => [{ 'TXT' => 'v=spf1 exists:foo%(ir).sbl.example.com ?all' }], 'e1t.example.com' => [{ 'TXT' => 'v=spf1 exists:foo%.sbl.example.com ?all' }], 'e1a.example.com' => [{ 'TXT' => 'v=spf1 a:macro%%percent%_%_space%-url-space.example.com -all' }], 'macro%percent  space%20url-space.example.com' => [{ 'A' => '1.2.3.4' }], 'e2.example.com' => [{ 'TXT' => 'v=spf1 -all exp=%{r}.example.com' }], 'e3.example.com' => [{ 'TXT' => 'v=spf1 -all exp=%{ir}.example.com' }], '40.218.168.192.example.com' => [{ 'TXT' => 'Connections from %{c} not authorized.' }], 'somewhat.long.exp.example.com' => [{ 'TXT' => 'v=spf1 -all exp=foobar.%{o}.%{o}.%{o}.%{o}.%{o}.%{o}.%{o}.%{o}.example.com' }], 'somewhat.long.exp.example.com.somewhat.long.exp.example.com.somewhat.long.exp.example.com.somewhat.long.exp.example.com.somewhat.long.exp.example.com.somewhat.long.exp.example.com.somewhat.long.exp.example.com.somewhat.long.exp.example.com.example.com' => [{ 'TXT' => 'Congratulations!  That was tricky.' }], 'e4.example.com' => [{ 'TXT' => 'v=spf1 -all exp=e4msg.example.com' }], 'e4msg.example.com' => [{ 'TXT' => '%{c} is queried as %{ir}.%{v}.arpa' }], 'e5.example.com' => [{ 'TXT' => 'v=spf1 a:%{a}.example.com -all' }], 'e6.example.com' => [{ 'TXT' => 'v=spf1 -all exp=e6msg.example.com' }], 'e6msg.example.com' => [{ 'TXT' => 'connect from %{p}' }], 'mx.example.com' => [{ 'A' => '192.168.218.41' }, { 'A' => '192.168.218.42' }, { 'AAAA' => 'CAFE:BABE::2' }, { 'AAAA' => 'CAFE:BABE::3' }], '40.218.168.192.in-addr.arpa' => [{ 'PTR' => 'mx.example.com' }], '41.218.168.192.in-addr.arpa' => [{ 'PTR' => 'mx.example.com' }], '42.218.168.192.in-addr.arpa' => [{ 'PTR' => 'mx.example.com' }, { 'PTR' => 'mx.e7.example.com' }], '1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.E.B.A.B.E.F.A.C.ip6.arpa' => [{ 'PTR' => 'mx.example.com' }], '3.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.E.B.A.B.E.F.A.C.ip6.arpa' => [{ 'PTR' => 'mx.example.com' }], 'mx.e7.example.com' => [{ 'A' => '192.168.218.42' }], 'mx.e7.example.com.should.example.com' => [{ 'A' => '127.0.0.2' }], 'mx.example.com.ok.example.com' => [{ 'A' => '127.0.0.2' }], 'e7.example.com' => [{ 'TXT' => 'v=spf1 exists:%{p}.should.example.com ~exists:%{p}.ok.example.com' }], 'e8.example.com' => [{ 'TXT' => 'v=spf1 -all exp=msg8.%{D2}' }], 'msg8.example.com' => [{ 'TXT' => 'http://example.com/why.html?l=%{L}' }], 'e9.example.com' => [{ 'TXT' => 'v=spf1 a:%{H} -all' }], 'e10.example.com' => [{ 'TXT' => 'v=spf1 -include:_spfh.%{d2} ip4:1.2.3.0/24 -all' }], '_spfh.example.com' => [{ 'TXT' => 'v=spf1 -a:%{h} +all' }], 'e11.example.com' => [{ 'TXT' => 'v=spf1 exists:%{i}.%{l2r-}.user.%{d2}' }], '1.2.3.4.gladstone.philip.user.example.com' => [{ 'A' => '127.0.0.2' }], 'e12.example.com' => [{ 'TXT' => 'v=spf1 exists:%{l2r+-}.user.%{d2}' }], 'bar.foo.user.example.com' => [{ 'A' => '127.0.0.2' }] }
  end

  let(:dns_client) { DNSAdapter::MockClient.new(zonefile) }
  let(:options) { { dns_client: dns_client } }

  it 'trailing dot is ignored for domains' do
    result = Coppertone::SpfService.authenticate_email('192.168.218.40', 'test@example.com', 'msgbas2x.cos.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'trailing dot is not removed from explanation' do
    # A simple way for an implementation to ignore trailing dots on domains is to remove it when present.  But be careful not to remove it for explanation text.
    result = Coppertone::SpfService.authenticate_email('192.168.218.40', 'test@exp.example.com', 'msgbas2x.cos.example.com', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('This is a test.')
  end

  it 'The following macro letters are allowed only in "exp" text: c, r, t' do
    result = Coppertone::SpfService.authenticate_email('192.168.218.40', 'test@e2.example.com', 'msgbas2x.cos.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'A % character not followed by a {, %, -, or _ character is a syntax error.' do
    result = Coppertone::SpfService.authenticate_email('192.168.218.40', 'test@e1.example.com', 'msgbas2x.cos.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'A % character not followed by a {, %, -, or _ character is a syntax error.' do
    result = Coppertone::SpfService.authenticate_email('192.168.218.40', 'test@e1e.example.com', 'msgbas2x.cos.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'A % character not followed by a {, %, -, or _ character is a syntax error.' do
    result = Coppertone::SpfService.authenticate_email('192.168.218.40', 'test@e1t.example.com', 'msgbas2x.cos.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'macro-encoded percents (%%), spaces (%_), and URL-percent-encoded spaces (%-)' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'test@e1a.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'For IPv4 addresses, both the "i" and "c" macros expand to the standard dotted-quad format.' do
    result = Coppertone::SpfService.authenticate_email('192.168.218.40', 'test@e3.example.com', 'msgbas2x.cos.example.com', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('Connections from 192.168.218.40 not authorized.')
  end

  it 'When the result of macro expansion is used in a domain name query, if the expanded domain name exceeds 253 characters, the left side is truncated to fit, by removing successive domain labels until the total length does not exceed 253 characters.' do
    result = Coppertone::SpfService.authenticate_email('192.168.218.40', 'test@somewhat.long.exp.example.com', 'msgbas2x.cos.example.com', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('Congratulations!  That was tricky.')
  end

  it 'v = the string "in-addr" if <ip> is ipv4, or "ip6" if <ip> is ipv6' do
    result = Coppertone::SpfService.authenticate_email('192.168.218.40', 'test@e4.example.com', 'msgbas2x.cos.example.com', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('192.168.218.40 is queried as 40.218.168.192.in-addr.arpa')
  end

  it 'v = the string "in-addr" if <ip> is ipv4, or "ip6" if <ip> is ipv6' do
    result = Coppertone::SpfService.authenticate_email('CAFE:BABE::1', 'test@e4.example.com', 'msgbas2x.cos.example.com', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('cafe:babe::1 is queried as 1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.E.B.A.B.E.F.A.C.ip6.arpa')
  end

  it 'Allowed macros chars are slodipvh plus crt in explanation.' do
    result = Coppertone::SpfService.authenticate_email('CAFE:BABE::192.168.218.40', 'test@e5.example.com', 'msgbas2x.cos.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'p = the validated domain name of <ip>' do
    # The PTR in this example does not validate.
    result = Coppertone::SpfService.authenticate_email('192.168.218.40', 'test@e6.example.com', 'msgbas2x.cos.example.com', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('connect from unknown')
  end

  it 'p = the validated domain name of <ip>' do
    # If a subdomain of the <domain> is present, it SHOULD be used.
    result = Coppertone::SpfService.authenticate_email('192.168.218.41', 'test@e6.example.com', 'msgbas2x.cos.example.com', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('connect from mx.example.com')
  end

  it 'p = the validated domain name of <ip>' do
    # The PTR in this example does not validate.
    result = Coppertone::SpfService.authenticate_email('CAFE:BABE::1', 'test@e6.example.com', 'msgbas2x.cos.example.com', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('connect from unknown')
  end

  it 'p = the validated domain name of <ip>' do
    # If a subdomain of the <domain> is present, it SHOULD be used.
    result = Coppertone::SpfService.authenticate_email('CAFE:BABE::3', 'test@e6.example.com', 'msgbas2x.cos.example.com', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('connect from mx.example.com')
  end

  it 'p = the validated domain name of <ip>' do
    # If a subdomain of the <domain> is present, it SHOULD be used.
    result = Coppertone::SpfService.authenticate_email('192.168.218.42', 'test@e7.example.com', 'msgbas2x.cos.example.com', options)
    expect([:pass, :softfail]).to include(result.code)
  end

  it 'Uppercased macros expand exactly as their lowercased equivalents, and are then URL escaped.  All chars not in the unreserved set MUST be escaped.' do
    # unreserved  = ALPHA / DIGIT / "-" / "." / "_" / "~"
    result = Coppertone::SpfService.authenticate_email('192.168.218.42', '~jack&jill=up-a_b3.c@e8.example.com', 'msgbas2x.cos.example.com', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('http://example.com/why.html?l=~jack%26jill%3Dup-a_b3.c')
  end

  it 'h = HELO/EHLO domain' do
    result = Coppertone::SpfService.authenticate_email('192.168.218.40', 'test@e9.example.com', 'msgbas2x.cos.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'h = HELO/EHLO domain, but HELO is invalid' do
    # Domain-spec must end in either a macro, or a valid toplabel. It is not correct to check syntax after macro expansion.
    result = Coppertone::SpfService.authenticate_email('192.168.218.40', 'test@e9.example.com', 'JUMPIN\' JUPITER', options)
    expect([:fail]).to include(result.code)
  end

  it 'h = HELO/EHLO domain, but HELO is a domain literal' do
    # Domain-spec must end in either a macro, or a valid toplabel. It is not correct to check syntax after macro expansion.
    result = Coppertone::SpfService.authenticate_email('192.168.218.40', 'test@e9.example.com', '[192.168.218.40]', options)
    expect([:fail]).to include(result.code)
  end

  it 'Example of requiring valid helo in sender policy.  This is a complex policy testing several points at once.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'test@e10.example.com', 'OEMCOMPUTER', options)
    expect([:fail]).to include(result.code)
  end

  it 'Macro value transformation (splitting on arbitrary characters, reversal, number of right-hand parts to use)' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'philip-gladstone-test@e11.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it 'Multiple delimiters may be specified in a macro expression.   macro-expand = ( "%{" macro-letter transformers *delimiter "}" )                  / "%%" / "%_" / "%-"' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo-bar+zip+quux@e12.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end
end
