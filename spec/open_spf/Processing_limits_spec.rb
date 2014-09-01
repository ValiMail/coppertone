require 'spec_helper'

describe 'Processing limits' do
  let(:zonefile) do
    { 'mail.example.com' => [{ 'A' => '1.2.3.4' }], 'e1.example.com' => [{ 'TXT' => 'v=spf1 ip4:1.1.1.1 redirect=e1.example.com' }, { 'A' => '1.2.3.6' }], 'e2.example.com' => [{ 'TXT' => 'v=spf1 include:e3.example.com' }, { 'A' => '1.2.3.7' }], 'e3.example.com' => [{ 'TXT' => 'v=spf1 include:e2.example.com' }, { 'A' => '1.2.3.8' }], 'e4.example.com' => [{ 'TXT' => 'v=spf1 mx' }, { 'MX' => [0, 'mail.example.com'] }, { 'MX' => [1, 'mail.example.com'] }, { 'MX' => [2, 'mail.example.com'] }, { 'MX' => [3, 'mail.example.com'] }, { 'MX' => [4, 'mail.example.com'] }, { 'MX' => [5, 'mail.example.com'] }, { 'MX' => [6, 'mail.example.com'] }, { 'MX' => [7, 'mail.example.com'] }, { 'MX' => [8, 'mail.example.com'] }, { 'MX' => [9, 'mail.example.com'] }, { 'MX' => [10, 'e4.example.com'] }, { 'A' => '1.2.3.5' }], 'e5.example.com' => [{ 'TXT' => 'v=spf1 ptr' }, { 'A' => '1.2.3.5' }], '5.3.2.1.in-addr.arpa' => [{ 'PTR' => 'e1.example.com.' }, { 'PTR' => 'e2.example.com.' }, { 'PTR' => 'e3.example.com.' }, { 'PTR' => 'e4.example.com.' }, { 'PTR' => 'example.com.' }, { 'PTR' => 'e6.example.com.' }, { 'PTR' => 'e7.example.com.' }, { 'PTR' => 'e8.example.com.' }, { 'PTR' => 'e9.example.com.' }, { 'PTR' => 'e10.example.com.' }, { 'PTR' => 'e5.example.com.' }], 'e6.example.com' => [{ 'TXT' => 'v=spf1 a mx a mx a mx a mx a ptr ip4:1.2.3.4 -all' }, { 'A' => '1.2.3.8' }, { 'MX' => [10, 'e6.example.com'] }], 'e7.example.com' => [{ 'TXT' => 'v=spf1 a mx a mx a mx a mx a ptr a ip4:1.2.3.4 -all' }, { 'A' => '1.2.3.20' }], 'e8.example.com' => [{ 'TXT' => 'v=spf1 a include:inc.example.com ip4:1.2.3.4 mx -all' }, { 'A' => '1.2.3.4' }], 'inc.example.com' => [{ 'TXT' => 'v=spf1 a a a a a a a a' }, { 'A' => '1.2.3.10' }], 'e9.example.com' => [{ 'TXT' => 'v=spf1 a include:inc.example.com a ip4:1.2.3.4 -all' }, { 'A' => '1.2.3.21' }], 'e10.example.com' => [{ 'TXT' => 'v=spf1 a -all' }, { 'A' => '1.2.3.1' }, { 'A' => '1.2.3.2' }, { 'A' => '1.2.3.3' }, { 'A' => '1.2.3.4' }, { 'A' => '1.2.3.5' }, { 'A' => '1.2.3.6' }, { 'A' => '1.2.3.7' }, { 'A' => '1.2.3.8' }, { 'A' => '1.2.3.9' }, { 'A' => '1.2.3.10' }, { 'A' => '1.2.3.11' }, { 'A' => '1.2.3.12' }], 'e11.example.com' => [{ 'TXT' => 'v=spf1 a:err.example.com a:err1.example.com a:err2.example.com ?all' }], 'e12.example.com' => [{ 'TXT' => 'v=spf1 a:err.example.com a:err1.example.com ?all' }] }
  end

  let(:dns_client) { Coppertone::DNS::MockClient.new(zonefile) }
  let(:options) { { dns_client: dns_client } }

  it 'SPF implementations MUST limit the number of mechanisms and modifiers that do DNS lookups to at most 10 per SPF check.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e1.example.com', 'mail.example.com', options)
    expect(%i(permerror)).to include(result.code)
  end

  it 'SPF implementations MUST limit the number of mechanisms and modifiers that do DNS lookups to at most 10 per SPF check.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e2.example.com', 'mail.example.com', options)
    expect(%i(permerror)).to include(result.code)
  end

  it 'there MUST be a limit of no more than 10 MX looked up and checked.' do
    # The required result for this test was the subject of much controversy with RFC4408.  For RFC7208 the ambiguity was resolved in favor of producing a permerror result.
    result = Coppertone::SpfService.authenticate_email('1.2.3.5', 'foo@e4.example.com', 'mail.example.com', options)
    expect(%i(permerror)).to include(result.code)
  end

  it 'there MUST be a limit of no more than 10 PTR looked up and checked.' do
    # The result of this test cannot be permerror not only because the RFC does not specify it, but because the sender has no control over the PTR records of spammers. The preferred result reflects evaluating the 10 allowed PTR records in the order returned by the test data. If testing with live DNS, the PTR order may be random, and a pass result would still be compliant.  The SPF result is effectively randomized.
    result = Coppertone::SpfService.authenticate_email('1.2.3.5', 'foo@e5.example.com', 'mail.example.com', options)
    expect(%i(neutral pass)).to include(result.code)
  end

  it 'unlike MX, PTR, there is no RR limit for A' do
    # There seems to be a tendency for developers to want to limit A RRs in addition to MX and PTR.  These are IPs, not usable for 3rd party DoS attacks, and hence need no low limit.
    result = Coppertone::SpfService.authenticate_email('1.2.3.12', 'foo@e10.example.com', 'mail.example.com', options)
    expect(%i(pass)).to include(result.code)
  end

  it 'SPF implementations MUST limit the number of mechanisms and modifiers that do DNS lookups to at most 10 per SPF check.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e6.example.com', 'mail.example.com', options)
    expect(%i(pass)).to include(result.code)
  end

  it 'SPF implementations MUST limit the number of mechanisms and modifiers that do DNS lookups to at most 10 per SPF check.' do
    # We do not check whether an implementation counts mechanisms before or after evaluation.  The RFC is not clear on this.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e7.example.com', 'mail.example.com', options)
    expect(%i(permerror)).to include(result.code)
  end

  it 'SPF implementations MUST limit the number of mechanisms and modifiers that do DNS lookups to at most 10 per SPF check.' do
    # The part of the RFC that talks about MAY parse the entire record first (4.6) is specific to syntax errors.  In RFC7208, processing limits are part of syntax checking (4.6).
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e8.example.com', 'mail.example.com', options)
    expect(%i(pass)).to include(result.code)
  end

  it 'SPF implementations MUST limit the number of mechanisms and modifiers that do DNS lookups to at most 10 per SPF check.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e9.example.com', 'mail.example.com', options)
    expect(%i(permerror)).to include(result.code)
  end

  it 'SPF implementations SHOULD limit "void lookups" to two.  An  implementation MAY choose to make such a limit configurable. In this case, a default of two is RECOMMENDED.' do
    # This is a new check in RFC7208, but it\'s been implemented in Mail::SPF for years with no issues.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e12.example.com', 'mail.example.com', options)
    expect(%i(neutral)).to include(result.code)
  end

  it 'SPF implementations SHOULD limit "void lookups" to two.  An implementation MAY choose to make such a limit configurable. In this case, a default of two is RECOMMENDED.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e11.example.com', 'mail.example.com', options)
    expect(%i(permerror)).to include(result.code)
  end

end
