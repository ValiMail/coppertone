require 'spec_helper'

describe Coppertone::MacroString::MacroLiteral do
  let(:arg) { SecureRandom.hex(10) }
  let(:macro) { Coppertone::MacroString::MacroLiteral.new(arg) }

  it 'should expand to the argument' do
    expect(macro.expand(double)).to eq(arg)
  end

  it 'should reduce to the argument in the macro form' do
    expect(macro.to_s).to eq(arg)
  end

  context 'equality' do
    it 'should treat different MacroLiterals with the same value as equal' do
      expect(macro == Coppertone::MacroString::MacroLiteral.new(arg))
        .to eql(true)
    end

    it 'otherwise should treat different MacroLiterals as unequal' do
      other_arg = SecureRandom.hex(10)
      expect(macro == Coppertone::MacroString::MacroLiteral.new(other_arg))
        .to eql(false)
    end
  end
end
