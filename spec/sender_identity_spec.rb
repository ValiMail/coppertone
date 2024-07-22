require 'spec_helper'

describe Coppertone::SenderIdentity do
  it 'should parse an email address into localpart and domain' do
    si = Coppertone::SenderIdentity.new('user@gmail.com')
    expect(si.sender).to eq('user@gmail.com')
    expect(si.localpart).to eq('user')
    expect(si.domain).to eq('gmail.com')
  end

  it 'should default localpart to postmaster' do
    si = Coppertone::SenderIdentity.new('yahoo.com')
    expect(si.sender).to eq('yahoo.com')
    expect(si.localpart).to eq('postmaster')
    expect(si.domain).to eq('yahoo.com')
  end

  it 'should parse an email address into localpart and domain' do
    si = Coppertone::SenderIdentity.new('user@gmail.com')
    expect(si.sender).to eq('user@gmail.com')
    expect(si.localpart).to eq('user')
    expect(si.domain).to eq('gmail.com')
  end

  it 'should not raise an error if the sender is nil' do
    si = Coppertone::SenderIdentity.new(nil)
    expect(si.sender).to be_nil
    expect(si.localpart).to eq('postmaster')
    expect(si.domain).to be_nil
  end

  it 'should not raise an error if the sender is blank' do
    si = Coppertone::SenderIdentity.new('')
    expect(si.sender).to eq('')
    expect(si.localpart).to eq('postmaster')
    expect(si.domain).to eq('')
  end

  it 'should not raise an error if the sender has a too-long domain' do
    localpart = 'lymeeater'
    domain = 'A123456789012345678901234567890123456789' \
             '012345678901234567890123.example.com'
    sender = "#{localpart}@#{domain}"
    si = Coppertone::SenderIdentity.new(sender)
    expect(si.sender).to eq(sender)
    expect(si.localpart).to eq(localpart)
    expect(si.domain).to eq(domain)
  end

  it 'should not raise an error if the sender has a domain missing labels' do
    localpart = 'lymeeater'
    domain = 'A...example.com'
    sender = "#{localpart}@#{domain}"
    si = Coppertone::SenderIdentity.new(sender)
    expect(si.sender).to eq(sender)
    expect(si.localpart).to eq(localpart)
    expect(si.domain).to eq(domain)
  end

  it 'should not raise an error if the sender has a domain literal' do
    localpart = 'foo'
    domain = '[1.2.3.5]'
    sender = "#{localpart}@#{domain}"
    si = Coppertone::SenderIdentity.new(sender)
    expect(si.sender).to eq(sender)
    expect(si.localpart).to eq(localpart)
    expect(si.domain).to eq(domain)
  end
end
