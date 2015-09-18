# -- encoding : utf-8 --

require 'spec_helper'

describe 'Initial processing' do
  let(:zonefile) do
    { 'example.com' => ['TIMEOUT'], 'example.net' => [{ 'TXT' => 'v=spf1 -all exp=exp.example.net' }], 'a.example.net' => [{ 'TXT' => 'v=spf1 -all exp=exp.example.net' }], 'exp.example.net' => [{ 'TXT' => '%{l}' }], 'a12345678901234567890123456789012345678901234567890123456789012.example.com' => [{ 'TXT' => 'v=spf1 -all' }], 'hosed.example.com' => [{ 'TXT' => 'v=spf1 a:ï»¿garbage.example.net -all' }], 'hosed2.example.com' => [{ 'TXT' => "v=spf1 \u0080a:example.net -all" }], 'hosed3.example.com' => [{ 'TXT' => "v=spf1 a:example.net \u0096all" }], 'nothosed.example.com' => [{ 'TXT' => 'v=spf1 a:example.net -all' }, { 'TXT' => "\u0096" }], 'ctrl.example.com' => [{ 'TXT' => "v=spf1 a:ctrl.example.com\rptr -all" }, { 'A' => '192.0.2.3' }], 'fine.example.com' => [{ 'TXT' => 'v=spf1 a  -all' }] }
  end

  let(:dns_client) { DNSAdapter::MockClient.new(zonefile) }
  let(:options) { { dns_client: dns_client } }

  it 'DNS labels limited to 63 chars.' do
    # For initial processing, a long label results in None, not TempError
    result = Coppertone::SpfService.authenticate_email('1.2.3.5', 'lyme.eater@A123456789012345678901234567890123456789012345678901234567890123.example.com', 'mail.example.net', options)
    expect([:none]).to include(result.code)
  end

  it 'DNS labels limited to 63 chars.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.5', 'lyme.eater@A12345678901234567890123456789012345678901234567890123456789012.example.com', 'mail.example.net', options)
    expect([:fail]).to include(result.code)
  end

  it 'emptylabel' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.5', 'lyme.eater@A...example.com', 'mail.example.net', options)
    expect([:none]).to include(result.code)
  end

  it 'helo-not-fqdn' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.5', '', 'A2345678', options)
    expect([:none]).to include(result.code)
  end

  it 'helo-domain-literal' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.5', '', '[1.2.3.5]', options)
    expect([:none]).to include(result.code)
  end

  it 'nolocalpart' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', '@example.net', 'mail.example.net', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('postmaster')
  end

  it 'domain-literal' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.5', 'foo@[1.2.3.5]', 'OEMCOMPUTER', options)
    expect([:none]).to include(result.code)
  end

  it 'SPF policies are restricted to 7-bit ascii.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foobar@hosed.example.com', 'hosed', options)
    expect([:permerror]).to include(result.code)
  end

  it 'SPF policies are restricted to 7-bit ascii.' do
    # Checking a possibly different code path for non-ascii chars.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foobar@hosed2.example.com', 'hosed', options)
    expect([:permerror]).to include(result.code)
  end

  it 'SPF policies are restricted to 7-bit ascii.' do
    # Checking yet another code path for non-ascii chars.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foobar@hosed3.example.com', 'hosed', options)
    expect([:permerror]).to include(result.code)
  end

  it 'Non-ascii content in non-SPF related records.' do
    # Non-SPF related TXT records are none of our business.
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'foobar@nothosed.example.com', 'hosed', options)
    expect([:fail]).to include(result.code)
    expect(result.explanation).to eq('DEFAULT')
  end

  it 'Mechanisms are separated by spaces only, not any control char.' do
    result = Coppertone::SpfService.authenticate_email('192.0.2.3', 'foobar@ctrl.example.com', 'hosed', options)
    expect([:permerror]).to include(result.code)
  end

  it 'ABNF for term separation is one or more spaces, not just one.' do
    result = Coppertone::SpfService.authenticate_email('1.2.3.4', 'actually@fine.example.com', 'hosed', options)
    expect([:fail]).to include(result.code)
  end
end
