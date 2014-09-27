require 'spec_helper'

describe 'Record evaluation' do
  let(:zonefile) do
    { 'mail.example.com' => [{ 'A' => '1.2.3.4' }], 't1.example.com' => [{ 'TXT' => 'v=spf1 ip4:1.2.3.4 -all moo' }], 't2.example.com' => [{ 'TXT' => 'v=spf1 moo.cow-far_out=man:dog/cat ip4:1.2.3.4 -all' }], 't3.example.com' => [{ 'TXT' => 'v=spf1 moo.cow/far_out=man:dog/cat ip4:1.2.3.4 -all' }], 't4.example.com' => [{ 'TXT' => 'v=spf1 moo.cow:far_out=man:dog/cat ip4:1.2.3.4 -all' }], 't5.example.com' => [{ 'TXT' => 'v=spf1 redirect=t5.example.com ~all' }], 't6.example.com' => [{ 'TXT' => 'v=spf1 ip4:1.2.3.4 redirect=t2.example.com' }], 't7.example.com' => [{ 'TXT' => 'v=spf1 ip4:1.2.3.4' }], 't8.example.com' => [{ 'TXT' => 'v=spf1 ip4:1.2.3.4 redirect:t2.example.com' }], 't9.example.com' => [{ 'TXT' => 'v=spf1 a:foo-bar -all' }], 't10.example.com' => [{ 'TXT' => 'v=spf1 a:mail.example...com -all' }], 't11.example.com' => [{ 'TXT' => 'v=spf1 a:a123456789012345678901234567890123456789012345678901234567890123.example.com -all' }], 't12.example.com' => [{ 'TXT' => 'v=spf1 a:%{H}.bar -all' }] }
  end

  let(:dns_client) { DNSAdapter::MockClient.new(zonefile) }
  let(:options) { { dns_client: dns_client } }

  it 'Any syntax errors anywhere in the record MUST be detected.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@t1.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'name = ALPHA *( ALPHA / DIGIT / "-" / "_" / "." )' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@t2.example.com', 'mail.example.com', options)
    expect([:pass]).to include(result.code)
  end

  it '= character immediately after the name and before any ":" or "/"' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@t3.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it '= character immediately after the name and before any ":" or "/"' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@t4.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'The "redirect" modifier has an effect after all the mechanisms.' do
    # The redirect in this example would violate processing limits, except that it is never used because of the all mechanism.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@t5.example.com', 'mail.example.com', options)
    expect([:softfail]).to include(result.code)
  end

  it 'The "redirect" modifier has an effect after all the mechanisms.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.5', 'foo@t6.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'Default result is neutral.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.5', 'foo@t7.example.com', 'mail.example.com', options)
    expect([:neutral]).to include(result.code)
  end

  it 'Invalid mechanism.  Redirect is a modifier.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@t8.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'Domain-spec must end in macro-expand or valid toplabel.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@t9.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'target-name that is a valid domain-spec per RFC 4408 and RFC 7208 but an invalid domain name per RFC 1035 (empty label) should be treated as non-existent.' do
    # An empty domain label, i.e. two successive dots, in a mechanism target-name is valid domain-spec syntax (perhaps formed from a macro expansion), even though a DNS query cannot be composed from it.  The spec being unclear about it, this could either be considered a syntax error, or, by analogy to 4.3/1 and 5/10/3, the mechanism could be treated as a no-match.  RFC 7208 failed to agree on which result to use, and declares the situation undefined.  The preferred test result is therefore a matter of opinion.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@t10.example.com', 'mail.example.com', options)
    expect([:fail, :permerror]).to include(result.code)
  end

  it 'target-name that is a valid domain-spec per RFC 4408 and RFC 7208 but an invalid domain name per RFC 1035 (long label) must be treated as non-existent.' do
    # A domain label longer than 63 characters in a mechanism target-name is valid domain-spec syntax (perhaps formed from a macro expansion), even though a DNS query cannot be composed from it.  The spec being unclear about it, this could either be considered a syntax error, or, by analogy to 4.3/1 and 5/10/3, the mechanism could be treated as a no-match.  RFC 7208 failed to agree on which result to use, and declares the situation undefined.  The preferred test result is therefore a matter of opinion.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@t11.example.com', 'mail.example.com', options)
    expect([:fail, :permerror]).to include(result.code)
  end

  it 'target-name that is a valid domain-spec per RFC 4408 and RFC 7208 but an invalid domain name per RFC 1035 (long label) must be treated as non-existent.' do
    # A domain label longer than 63 characters that results from macro expansion in a mechanism target-name is valid domain-spec syntax (and is not even subject to syntax checking after macro expansion), even though a DNS query cannot be composed from it.  The spec being unclear about it, this could either be considered a syntax error, or, by analogy to 4.3/1 and 5/10/3, the mechanism could be treated as a no-match.  RFC 7208 failed to agree on which result to use, and declares the situation undefined.  The preferred test result is therefore a matter of opinion.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@t12.example.com', '%%%%%%%%%%%%%%%%%%%%%%', options)
    expect([:fail, :permerror]).to include(result.code)
  end

end
