require 'spec_helper'

describe Coppertone::Directive do
  context '#matching_term' do
    it "returns nil if the term contains a '='" do
      expect(Coppertone::Directive.matching_term('all')).not_to be_nil
      expect(Coppertone::Directive.matching_term('all=')).to be_nil
      expect(Coppertone::Directive.matching_term('all=783')).to be_nil
    end

    it 'returns nil if the term is not a known directive' do
      expect(Coppertone::Directive.matching_term('unknown')).to be_nil
      expect(Coppertone::Directive.matching_term('~unknown')).to be_nil
    end

    it 'returns nil if the term is not a known qualifier' do
      expect(Coppertone::Directive.matching_term('+all')).not_to be_nil
      expect(Coppertone::Directive.matching_term('!all')).to be_nil
    end

    it 'passes attributes' do
      directive = Coppertone::Directive.matching_term('-ip4:192.1.1.1')
      expect(directive).not_to be_nil
      expect(directive.qualifier).to eq(Coppertone::Qualifier::FAIL)
      mechanism = directive.mechanism
      expect(mechanism).not_to be_nil
      expect(mechanism).to eq(Coppertone::Mechanism::IP4.new(':192.1.1.1'))
    end
  end

  context 'all?' do
    it 'should be true when the directive is an all' do
      expect(Coppertone::Directive.matching_term('+all')).to be_all
      expect(Coppertone::Directive.matching_term('-all')).to be_all
      expect(Coppertone::Directive.matching_term('~all')).to be_all
      expect(Coppertone::Directive.matching_term('?all')).to be_all
    end

    it 'should be false otherwise' do
      expect(Coppertone::Directive.matching_term('ip4:1.2.3.4')).not_to be_all
    end
  end

  context '.evaluate' do
    Coppertone::Qualifier.qualifiers.each do |q|
      it "returns a result with the expected code when it matches #{q.text}" do
        directive = Coppertone::Directive.matching_term("#{q.text}all")
        result = directive.evaluate(nil, nil)
        expect(result).not_to be_nil
        expect(result.code).to eq(q.result_code)
      end
    end
  end

  context '#target_domain' do
    it 'yields the target domain when the mechanism is not context dependent' do
      d = Coppertone::Term.build_from_token('include:_spf.example.org')
      expect(d.target_domain).to eq('_spf.example.org')
    end

    it 'raises an error when the mechanism is context dependent' do
      d = Coppertone::Term.build_from_token('include:_spf.%{h}.example.org')
      expect do
        d.target_domain
      end.to raise_error Coppertone::NeedsContextError
    end

    it 'raises an error when the mechanism does not support a target domain' do
      d = Coppertone::Term.build_from_token('ip4:1.2.3.4')
      expect do
        d.target_domain
      end.to raise_error Coppertone::NeedsContextError
    end
  end

  context '#to_s' do
    it 'should hide a default qualifier' do
      d = Coppertone::Term.build_from_token('~include:_spf.%{h}.example.org')
      expect(d.to_s).to eq('~include:_spf.%{h}.example.org')
    end

    it 'should hide a default qualifier' do
      d = Coppertone::Term.build_from_token('+include:_spf.%{h}.example.org')
      expect(d.to_s).to eq('include:_spf.%{h}.example.org')
    end
  end
end
