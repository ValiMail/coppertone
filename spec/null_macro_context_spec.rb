require 'spec_helper'

describe Coppertone::NullMacroContext do
  %w[s l o d i p v h c r t].each do |i|
    it "should raise an error for #{i}" do
      expect do
        Coppertone::NullMacroContext::NULL_CONTEXT.send(i)
      end.to raise_error ArgumentError
    end

    it "should raise an error for #{i.upcase}" do
      expect do
        Coppertone::NullMacroContext::NULL_CONTEXT.send(i.upcase)
      end.to raise_error ArgumentError
    end
  end

  it 'should return self for with_domain' do
    n = Coppertone::NullMacroContext::NULL_CONTEXT
    expect(n.with_domain('abcd')).to eq(n)
  end
end
