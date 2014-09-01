require 'spec_helper'

describe Coppertone::MacroString::MacroStaticExpand do
  context '#exists_for?' do
    %w(%% %_ %-).each do |x|
      it "should resolve a macro for the key #{x}" do
        expect(Coppertone::MacroString::MacroStaticExpand.exists_for?(x))
          .to eq(true)
      end
    end

    it 'should return false for invalid keys' do
      expect(Coppertone::MacroString::MacroStaticExpand.exists_for?('%a'))
        .to eq(false)
    end
  end

  context 'macro_for' do
    %w(%% %_ %-).each do |x|
      it "should resolve a macro for the key #{x}" do
        expect(Coppertone::MacroString::MacroStaticExpand.macro_for(x))
          .not_to be_nil
      end
    end

    it 'should raise an error for invalid keys' do
      expect do
        Coppertone::MacroString::MacroStaticExpand.macro_for('%a')
      end.to raise_error(Coppertone::MacroStringParsingError)
    end
  end

  it 'should not allow creation of new macros' do
    expect do
      Coppertone::MacroString::MacroStaticExpand.new('a', 'b')
    end.to raise_error(NoMethodError)
  end

  context 'percent macro' do
    let(:macro) { Coppertone::MacroString::MacroStaticExpand::PERCENT_MACRO }

    it 'should return the expected values' do
      expect(macro.expand(nil)).to eq('%')
      expect(macro.to_s).to eq('%%')
    end
  end

  context 'space macro' do
    let(:macro) { Coppertone::MacroString::MacroStaticExpand::SPACE_MACRO }

    it 'should return the expected values' do
      expect(macro.expand(nil)).to eq(' ')
      expect(macro.to_s).to eq('%_')
    end
  end

  context 'url encoded space macro' do
    let(:macro) do
      Coppertone::MacroString::MacroStaticExpand::URL_ENCODED_SPACE_MACRO
    end

    it 'should return the expected values' do
      expect(macro.expand(nil)).to eq('%20')
      expect(macro.to_s).to eq('%-')
    end
  end
end
