require 'spec_helper'

describe Coppertone::Utils::DomainUtils do
  subject { Coppertone::Utils::DomainUtils }
  context '#valid?' do
    it 'should validate standard domains' do
      expect(subject.valid?('gmail.com')).to eq(true)
      expect(subject.valid?('fermion.mit.edu')).to eq(true)
      expect(subject.valid?('abc.bit.ly')).to eq(true)
    end

    it 'should validate domains with numeric labels' do
      expect(subject.valid?('abc.126.com')).to eq(true)
      expect(subject.valid?('37.com')).to eq(true)
    end

    it 'should validate domains when they are dot-terminated' do
      expect(subject.valid?('gmail.com.')).to eq(true)
      expect(subject.valid?('fermion.mit.edu.')).to eq(true)
      expect(subject.valid?('abc.bit.ly.')).to eq(true)
    end

    it 'should reject domains with less than two labels' do
      expect(subject.valid?('')).to eq(false)
      expect(subject.valid?('one')).to eq(false)
    end

    it 'should reject domains with empty labels' do
      expect(subject.valid?('.spf.example.com')).to eq(false)
      expect(subject.valid?('spf..example.com')).to eq(false)
    end

    it 'should handle IDNA domains' do
      expect(subject.valid?('清华大学.cn')).to eq(true)
      expect(subject.valid?('ジェーピーニック.jp')).to eq(true)
    end

    it 'should reject labels containing whitespace' do
      expect(subject.valid?('mail mike.net')).to eq(false)
    end

    it 'should validate domains with underscores' do
      expect(subject.valid?('_dmarc.126.com')).to eq(true)
      expect(subject.valid?('abcd._domainkey.gmail.com')).to eq(true)
    end

    it 'should reject wildcard domains while allowing interstitial asterisks' do
      expect(subject.valid?('*.axb.longshot.com')).to eq(false)
      expect(subject.valid?('rst.*.example.com')).to eq(true)
    end

    it 'should reject IP addresses' do
      expect(subject.valid?('192.38.7.14')).to eq(false)
    end
  end

  context '#macro_expanded_domain' do
    it 'returns nil for nil' do
      expect(subject.macro_expanded_domain(nil)).to be_nil
    end

    it 'returns nil for a blank string' do
      expect(subject.macro_expanded_domain('')).to be_nil
    end

    it 'returns the domain for an ASCII domain' do
      expect(subject.macro_expanded_domain('fermion.mit.edu'))
        .to eq('fermion.mit.edu')
    end

    it 'returns the downcased domain for an ASCII domain' do
      expect(subject.macro_expanded_domain('FERMION.mIt.edu'))
        .to eq('fermion.mit.edu')
    end

    it 'returns the ASCII domain for an IDNA domain' do
      expect(subject.macro_expanded_domain('清华大学.cn'))
        .to eq('xn--xkry9kk1bz66a.cn')
    end

    it 'truncates overlong domains' do
      domain_candidate_labels = Array.new(50) { "a-#{SecureRandom.hex(2)}" }
      domain_candidate = domain_candidate_labels.join('.')
      truncated_labels = domain_candidate_labels.drop(14)
      truncated_domain = truncated_labels.join('.')

      expect(subject.macro_expanded_domain(domain_candidate))
        .to eq(truncated_domain)
    end
  end

  context '#parent_domain' do
    it 'should handle hostnames correctly' do
      expect(subject.parent_domain('abc.xyz.example.com'))
        .to eq('xyz.example.com')
    end

    it 'should handle TLDs correctly' do
      expect(subject.parent_domain('com')).to eq('.')
    end
  end

  context '#normalized_domain' do
    it 'should handle ASCII hostnames correctly' do
      expect(subject.normalized_domain('abc.xyz.example.com'))
        .to eq('abc.xyz.example.com')
      expect(subject.normalized_domain('ABc.xYz.exAMPle.COM'))
        .to eq('abc.xyz.example.com')
    end

    it 'should handle Unicode domains correctly' do
      expect(subject.normalized_domain('FERMIon.清华大学.cn'))
        .to eq('fermion.xn--xkry9kk1bz66a.cn')
    end
  end

  context '#valid_ldh_domain?' do
    it 'should validate standard domains' do
      expect(subject.valid_ldh_domain?('gmail.com')).to eq(true)
      expect(subject.valid_ldh_domain?('fermion.mit.edu')).to eq(true)
      expect(subject.valid_ldh_domain?('abc.bit.ly')).to eq(true)
    end

    it 'should validate domains with numeric labels' do
      expect(subject.valid_ldh_domain?('abc.126.com')).to eq(true)
      expect(subject.valid_ldh_domain?('37.com')).to eq(true)
    end

    it 'should validate domains when they are dot-terminated' do
      expect(subject.valid_ldh_domain?('gmail.com.')).to eq(true)
      expect(subject.valid_ldh_domain?('fermion.mit.edu.')).to eq(true)
      expect(subject.valid_ldh_domain?('abc.bit.ly.')).to eq(true)
    end

    it 'should reject domains with less than two labels' do
      expect(subject.valid_ldh_domain?('')).to eq(false)
      expect(subject.valid_ldh_domain?('one')).to eq(false)
    end

    it 'should handle IDNA domains' do
      expect(subject.valid_ldh_domain?('清华大学.cn')).to eq(true)
      expect(subject.valid_ldh_domain?('ジェーピーニック.jp')).to eq(true)
    end

    it 'should reject labels containing whitespace' do
      expect(subject.valid_ldh_domain?('mail mike.net')).to eq(false)
    end

    it 'should reject domains with underscores' do
      expect(subject.valid_ldh_domain?('_dmarc.126.com')).to eq(false)
      expect(subject.valid_ldh_domain?('abcd._domainkey.gmail.com')).to eq(false)
    end

    it 'should reject IP addresses' do
      expect(subject.valid_ldh_domain?('192.38.7.14')).to eq(false)
    end
  end
end
