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
      expect(mechanism).to eq(Coppertone::Mechanism::IP4.new('192.1.1.1'))
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
end
