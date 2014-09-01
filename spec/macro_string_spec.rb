require 'spec_helper'

describe Coppertone::MacroString do
  context 'equality' do
    it 'should treat different MacroStrings with the same value as equal' do
      arg = 'abc.%{dr-}.%%.test.com'
      macro_string = Coppertone::MacroString.new(arg)
      expect(macro_string == Coppertone::MacroString.new(arg))
        .to eql(true)
    end

    it 'should otherwise treat different MacroStrings as unequal' do
      arg = 'abc.%{dr-}.%%.test.com'
      macro_string = Coppertone::MacroString.new(arg)
      other_arg = 'eabc.%{dr-}.%%.test.com'
      expect(macro_string == Coppertone::MacroString.new(other_arg))
        .to eql(false)
    end
  end
end
