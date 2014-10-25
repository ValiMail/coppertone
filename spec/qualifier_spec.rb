require 'spec_helper'

describe Coppertone::Qualifier do
  context '#find_by_text' do
    {
      '+' => Coppertone::Qualifier::PASS,
      '-' => Coppertone::Qualifier::FAIL,
      '~' => Coppertone::Qualifier::SOFTFAIL,
      '?' => Coppertone::Qualifier::NEUTRAL
    }.each do |k, v|
      it "should map from #{k} to the correct value" do
        expect(Coppertone::Qualifier.find_by_text(k)).to eq(v)
        expect(v.text).to eq(k)
        expect(v.to_s).to eq(k)
      end
    end
  end

  context '#default_qualifier' do
    it 'should yield the correct default qualifier' do
      expect(Coppertone::Qualifier.default_qualifier)
        .to eq(Coppertone::Qualifier::PASS)
    end
  end

  context '#default?' do
    it 'should produce the right values for default?' do
      expect(Coppertone::Qualifier::PASS).to be_default
      expect(Coppertone::Qualifier::FAIL).not_to be_default
      expect(Coppertone::Qualifier::SOFTFAIL).not_to be_default
      expect(Coppertone::Qualifier::NEUTRAL).not_to be_default
    end
  end

  context '#qualifiers' do
    it 'should have the correct contents' do
      qualifiers = Coppertone::Qualifier.qualifiers
      expect(qualifiers.size).to eq(4)
      expect(qualifiers.include?(Coppertone::Qualifier::PASS)).to be(true)
      expect(qualifiers.include?(Coppertone::Qualifier::FAIL)).to be(true)
      expect(qualifiers.include?(Coppertone::Qualifier::SOFTFAIL)).to be(true)
      expect(qualifiers.include?(Coppertone::Qualifier::NEUTRAL)).to be(true)
    end
  end

  context 'result' do
    {
      Coppertone::Qualifier::PASS => Coppertone::Result::PASS,
      Coppertone::Qualifier::FAIL => Coppertone::Result::FAIL,
      Coppertone::Qualifier::SOFTFAIL => Coppertone::Result::SOFTFAIL,
      Coppertone::Qualifier::NEUTRAL => Coppertone::Result::NEUTRAL
    }.each do |k, v|
      it "should have the correct result code for #{k.text}" do
        expect(k.result_code).to eq(v)
      end
    end
  end

  it 'should not allow creation of new qualifiers' do
    expect do
      Coppertone::Qualifier.new('a', Coppertone::Result::PASS)
    end.to raise_error(NoMethodError)
  end
end
