require 'spec_helper'

describe Coppertone::Record do
  context '#record?' do
    it 'should return a falsey value for nil' do
      expect(Coppertone::Record.record?(nil)).to be_falsey
    end

    it 'should return a falsey value for text without the prefix' do
      expect(Coppertone::Record.record?('not a record')).to be_falsey
      expect(Coppertone::Record.record?('v=spf ~all')).to be_falsey
    end

    it 'should return a truthy value for text with the prefix' do
      expect(Coppertone::Record.record?('v=spf1 ~all')).to be_truthy
    end
  end

  context 'creation' do
    it 'should raise an error for nil' do
      expect do
        Coppertone::Record.new(nil)
      end.to raise_error(Coppertone::RecordParsingError)
    end

    it 'should raise an error for text without the prefix' do
      expect do
        Coppertone::Record.new('not a record')
      end.to raise_error(Coppertone::RecordParsingError)
      expect do
        Coppertone::Record.new('v=spf ~all')
      end.to raise_error(Coppertone::RecordParsingError)
    end

    it 'parse simple mechanism records' do
      record = Coppertone::Record.new('v=spf1 ~all')
      expect(record).not_to be_nil
      expect(record.directives.size).to eq(1)
      directive = record.directives.first
      expect(directive.qualifier).to eq(Coppertone::Qualifier::SOFTFAIL)
      expect(directive.mechanism).to eq(Coppertone::Mechanism::All.instance)
      expect(record.modifiers).to be_empty
    end

    it 'be case insensitive when parsing the version string' do
      record = Coppertone::Record.new('V=sPf1 ~all')
      expect(record).not_to be_nil
      expect(record.directives.size).to eq(1)
      directive = record.directives.first
      expect(directive.qualifier).to eq(Coppertone::Qualifier::SOFTFAIL)
      expect(directive.mechanism).to eq(Coppertone::Mechanism::All.instance)
      expect(record.modifiers).to be_empty
    end

    it 'should parse more complex records' do
      record = Coppertone::Record.new('v=spf1 mx -all exp=explain._spf.%{d}')
      expect(record).not_to be_nil
      expect(record.directives.size).to eq(2)
      directive = record.directives.first
      expect(directive.qualifier).to eq(Coppertone::Qualifier::PASS)
      expect(directive.mechanism).to eq(Coppertone::Mechanism::MX.new(nil))

      directive = record.directives.last
      expect(directive.qualifier).to eq(Coppertone::Qualifier::FAIL)
      expect(directive.mechanism).to eq(Coppertone::Mechanism::All.instance)

      expect(record.modifiers.length).to eq(1)
      modifier = record.modifiers.first
      expect(modifier).to eq(Coppertone::Modifier::Exp.new('explain._spf.%{d}'))

      expect(record.redirect).to be_nil
      expect(record.exp)
        .to eq(Coppertone::Modifier::Exp.new('explain._spf.%{d}'))
    end

    it 'should fail on more records with duplicate modifiers' do
      bad_records = [
        'v=spf1 mx -all exp=explain._spf.%{d} exp=other._spf.%{d}',
        'v=spf1 mx redirect=gmail.com redirect=yahoo.com'
      ]
      bad_records.each do |rec|
        expect do
          Coppertone::Record.new(rec)
        end.to raise_error(Coppertone::RecordParsingError)
      end
    end

    it 'should fail when mechanisms are separated by ctrl characters' do
      expect do
        Coppertone::Record.new("v=spf1 a:ctrl.example.com\x0dptr -all")
      end.to raise_error(Coppertone::RecordParsingError)
    end

    it 'should fail when it contains spurious terms' do
      expect do
        Coppertone::Record.new('v=spf1 ip4:1.2.3.4 -all moo')
      end.to raise_error(Coppertone::RecordParsingError)
    end

    it 'should fail the domain-spec is not syntactically valid' do
      expect do
        Coppertone::Record.new('v=spf1 a:foo-bar')
      end.to raise_error(Coppertone::RecordParsingError)
    end
  end

  context '#unknown_modifiers' do
    it 'should return a non-empty array when there are unknown modifiers' do
      expect(Coppertone::Record.new('v=spf1 moose=www.example.com').unknown_modifiers.size).to eq(1)
      expect(Coppertone::Record.new('v=spf1 moose=www.example.com squirrel=xxx').unknown_modifiers.size).to eq(2)
      expect(Coppertone::Record.new('v=spf1 moose=www.example.com moose=xxx').unknown_modifiers.size).to eq(2)
    end

    it 'should return an empty array when there are no unknown modifiers' do
      expect(Coppertone::Record.new('v=spf1 ~all').unknown_modifiers).to be_empty
      expect(Coppertone::Record.new('v=spf1 ip4:1.2.3.4 a:test.example.com -all').unknown_modifiers).to be_empty
      expect(Coppertone::Record.new('v=spf1 mx -all exp=explain._spf.%{d}').unknown_modifiers).to be_empty
      expect(Coppertone::Record.new('v=spf1 mx -all redirect=explain._spf.%{d}').unknown_modifiers).to be_empty
    end
  end

  context '#dns_lookup_term_count' do
    it 'should calculate correctly' do
      expect(Coppertone::Record.new('v=spf1 -all exp=explain._spf.%{d}').dns_lookup_term_count).to eq(0)
      expect(Coppertone::Record.new('v=spf1 a:example.test.com -exists:some.domain.com ~all').dns_lookup_term_count).to eq(2)
      expect(Coppertone::Record.new('v=spf1 ip4:1.2.3.4 -exists:some.domain.com ~all').dns_lookup_term_count).to eq(1)
    end
  end
end
