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

  context '#context_dependent?' do
    it 'should return true when the macro string contains a macro' do
      strs = ['abc.%{dr-}.%%.test.com', '%{l}.test.com', '%{d}', 'test.%{d}']
      strs.each do |s|
        macro_string = Coppertone::MacroString.new(s)
        expect(macro_string).to be_context_dependent
        expect(macro_string.to_s).to eq(s)
      end
    end

    it 'should return false when the macro string does not contain a macro' do
      strs = ['abc.%%.test.com', 'test.example.com', '%_', 'test']
      strs.each do |s|
        macro_string = Coppertone::MacroString.new(s)
        expect(macro_string).not_to be_context_dependent
        expect(macro_string.to_s).to eq(s)
      end
    end
  end
end
