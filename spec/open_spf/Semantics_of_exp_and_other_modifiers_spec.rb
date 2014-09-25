# -- encoding : utf-8 --

require 'spec_helper'

describe 'Semantics of exp and other modifiers' do
  let(:zonefile) do
    { 'mail.example.com' => [{ 'A' => '1.2.3.4' }], 'e1.example.com' => [{ 'TXT' => 'v=spf1 exp=exp1.example.com redirect=e2.example.com' }], 'e2.example.com' => [{ 'TXT' => 'v=spf1 -all' }], 'e3.example.com' => [{ 'TXT' => 'v=spf1 exp=exp1.example.com redirect=e4.example.com' }], 'e4.example.com' => [{ 'TXT' => 'v=spf1 -all exp=exp2.example.com' }], 'exp1.example.com' => [{ 'TXT' => 'No-see-um' }], 'exp2.example.com' => [{ 'TXT' => 'See me.' }], 'exp3.example.com' => [{ 'TXT' => 'Correct!' }], 'exp4.example.com' => [{ 'TXT' => '%{l} in implementation' }], 'e5.example.com' => [{ 'TXT' => 'v=spf1 1up=foo' }], 'e6.example.com' => [{ 'TXT' => 'v=spf1 =all' }], 'e7.example.com' => [{ 'TXT' => 'v=spf1 include:e3.example.com -all exp=exp3.example.com' }], 'e8.example.com' => [{ 'TXT' => 'v=spf1 -all exp=exp4.example.com' }], 'e9.example.com' => [{ 'TXT' => 'v=spf1 -all foo=%abc' }], 'e10.example.com' => [{ 'TXT' => 'v=spf1 redirect=erehwon.example.com' }], 'e11.example.com' => [{ 'TXT' => 'v=spf1 -all exp=e11msg.example.com' }], 'e11msg.example.com' => [{ 'TXT' => 'Answer a fool according to his folly.' }, { 'TXT' => 'Do not answer a fool according to his folly.' }], 'e12.example.com' => [{ 'TXT' => 'v=spf1 exp= -all' }], 'e13.example.com' => [{ 'TXT' => 'v=spf1 exp=e13msg.example.com -all' }], 'e13msg.example.com' => [{ 'TXT' => 'The %{x}-files.' }], 'e14.example.com' => [{ 'TXT' => 'v=spf1 exp=e13msg.example.com -all exp=e11msg.example.com' }], 'e15.example.com' => [{ 'TXT' => 'v=spf1 redirect=e12.example.com -all redirect=e12.example.com' }], 'e16.example.com' => [{ 'TXT' => 'v=spf1 exp=-all' }], 'e17.example.com' => [{ 'TXT' => 'v=spf1 redirect=-all ?all' }], 'e18.example.com' => [{ 'TXT' => 'v=spf1 ?all redirect=' }], 'e19.example.com' => [{ 'TXT' => 'v=spf1 default=pass' }], 'e20.example.com' => [{ 'TXT' => 'v=spf1 default=+' }], 'e21.example.com' => [{ 'TXT' => 'v=spf1 exp=e21msg.example.com -all' }], 'e21msg.example.com' => ['TIMEOUT'], 'e22.example.com' => [{ 'TXT' => 'v=spf1 exp=mail.example.com -all' }], 'nonascii.example.com' => [{ 'TXT' => 'v=spf1 exp=badexp.example.com -all' }], 'badexp.example.com' => [{ 'TXT' => 'ï»¿Explanation' }], 'tworecs.example.com' => [{ 'TXT' => 'v=spf1 exp=twoexp.example.com -all' }], 'twoexp.example.com' => [{ 'TXT' => 'one' }, { 'TXT' => 'two' }], 'e23.example.com' => [{ 'TXT' => 'v=spf1 a:erehwon.example.com a:foobar.com exp=nxdomain.com -all' }], 'e24.example.com' => [{ 'TXT' => 'v=spf1 redirect=testimplicit.example.com' }, { 'A' => '192.0.2.1' }], 'testimplicit.example.com' => [{ 'TXT' => 'v=spf1 a -all' }, { 'A' => '192.0.2.2' }] }
  end

  let(:dns_client) { Coppertone::DNS::MockClient.new(zonefile) }
  let(:options) { { dns_client: dns_client } }

  it 'If no SPF record is found, or if the target-name is malformed, the result is a "PermError" rather than "None".' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e10.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'when executing "redirect", exp= from the original domain MUST NOT be used.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e1.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('DEFAULT')
  end

  it 'redirect      = "redirect" "=" domain-spec ' do
    # A literal application of the grammar causes modifier syntax errors (except for macro syntax) to become unknown-modifier.
    #
    #   modifier = explanation | redirect | unknown-modifier
    #
    # However, it is generally agreed, with precedent in other RFCs, that unknown-modifier should not be "greedy", and should not match known modifier names.  There should have been explicit prose to this effect, and some has been proposed as an erratum.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e17.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'when executing "include", exp= from the target domain MUST NOT be used.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e7.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('Correct!')
  end

  it 'when executing "redirect", exp= from the original domain MUST NOT be used.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e3.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('See me.')
  end

  it 'unknown-modifier = name "=" macro-string name             = ALPHA *( ALPHA / DIGIT / "-" / "_" / "." ) ' do
    # Unknown modifier name must begin with alpha.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e5.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'name             = ALPHA *( ALPHA / DIGIT / "-" / "_" / "." ) ' do
    # Unknown modifier name must not be empty.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e6.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'An implementation that uses a legal expansion as a sentinel.  We cannot check them all, but we can check this one.' do
    # Spaces are allowed in local-part.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'Macro Error@e8.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('Macro Error in implementation')
  end

  it 'Ignore exp if multiple TXT records. ' do
    # If domain-spec is empty, or there are any DNS processing errors (any RCODE other than 0), or if no records are returned, or if more than one record is returned, or if there are syntax errors in the explanation string, then proceed as if no exp modifier was given.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e11.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('DEFAULT')
  end

  it 'Ignore exp if no TXT records. ' do
    # If domain-spec is empty, or there are any DNS processing errors (any RCODE other than 0), or if no records are returned, or if more than one record is returned, or if there are syntax errors in the explanation string, then proceed as if no exp modifier was given.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e22.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('DEFAULT')
  end

  it 'Ignore exp if DNS error. ' do
    # If domain-spec is empty, or there are any DNS processing errors (any RCODE other than 0), or if no records are returned, or if more than one record is returned, or if there are syntax errors in the explanation string, then proceed as if no exp modifier was given.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e21.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('DEFAULT')
  end

  it 'PermError if exp= domain-spec is empty. ' do
    # Section 6.2/4 says, "If domain-spec is empty, or there are any DNS processing errors (any RCODE other than 0), or if no records are returned, or if more than one record is returned, or if there are syntax errors in the explanation string, then proceed as if no exp modifier was given."  However, "if domain-spec is empty" conflicts with the grammar given for the exp modifier.  This was reported as an erratum, and the solution chosen was to report explicit "exp=" as PermError, but ignore problems due to macro expansion, DNS, or invalid explanation string.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e12.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'Ignore exp if the explanation string has a syntax error. ' do
    # If domain-spec is empty, or there are any DNS processing errors (any RCODE other than 0), or if no records are returned, or if more than one record is returned, or if there are syntax errors in the explanation string, then proceed as if no exp modifier was given.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e13.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('DEFAULT')
  end

  it 'explanation      = "exp" "=" domain-spec ' do
    # A literal application of the grammar causes modifier syntax errors (except for macro syntax) to become unknown-modifier.
    #
    #   modifier = explanation | redirect | unknown-modifier
    #
    # However, it is generally agreed, with precedent in other RFCs, that unknown-modifier should not be "greedy", and should not match known modifier names.  There should have been explicit prose to this effect, and some has been proposed as an erratum.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e16.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'exp= appears twice. ' do
    # These two modifiers (exp,redirect) MUST NOT appear in a record more than once each. If they do, then check_host() exits with a result of "PermError".
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e14.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'redirect = "redirect" "=" domain-spec ' do
    # Unlike for exp, there is no instruction to override the permerror for an empty domain-spec (which is invalid syntax).
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e18.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'redirect= appears twice. ' do
    # These two modifiers (exp,redirect) MUST NOT appear in a record more than once each. If they do, then check_host() exits with a result of "PermError".
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e15.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'unknown-modifier = name "=" macro-string ' do
    # Unknown modifiers must have valid macro syntax.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e9.example.com', 'mail.example.com', options)
    expect([:permerror]).to include(result.code)
  end

  it 'Unknown modifiers do not modify the RFC SPF result. ' do
    # Some implementations may have a leftover default= modifier from earlier drafts.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e19.example.com', 'mail.example.com', options)
    expect([:neutral]).to include(result.code)
  end

  it 'Unknown modifiers do not modify the RFC SPF result. ' do
    # Some implementations may have a leftover default= modifier from earlier drafts.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e20.example.com', 'mail.example.com', options)
    expect([:neutral]).to include(result.code)
  end

  it 'SPF explanation text is restricted to 7-bit ascii.' do
    # Checking a possibly different code path for non-ascii chars.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foobar@nonascii.example.com', 'hosed', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('DEFAULT')
  end

  it 'Must ignore exp= if DNS returns more than one TXT record.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foobar@tworecs.example.com', 'hosed', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('DEFAULT')
  end

  it 'exp=nxdomain.tld ' do
    # Non-existent exp= domains MUST NOT count against the void lookup limit. Implementations should lookup any exp record at most once after computing the result.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foo@e23.example.com', 'mail.example.com', options)
    expect([:fail]).to include(result.code)
  end

  it 'redirect changes implicit domain ' do
    result = Coppertone::SpfService.authenticate_email('192.0.2.2', 'bar@e24.example.com', 'e24.example.com', options)
    expect([:pass]).to include(result.code)
  end

end
