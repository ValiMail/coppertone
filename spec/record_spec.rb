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

  context 'parsing' do
    it 'should return nil for nil' do
      expect(Coppertone::Record.parse(nil)).to be_nil
    end

    it 'should return a nil for text without the prefix' do
      expect(Coppertone::Record.parse('not a record')).to be_nil
      expect(Coppertone::Record.parse('v=spf ~all')).to be_nil
    end

    it 'parse simple mechanism records' do
      record = Coppertone::Record.parse('v=spf1 ~all')
      expect(record).not_to be_nil
      expect(record.directives.size).to eq(1)
      directive = record.directives.first
      expect(directive.qualifier).to eq(Coppertone::Qualifier::SOFTFAIL)
      expect(directive.mechanism).to eq(Coppertone::Mechanism::All.instance)
      expect(record.modifiers).to be_empty
    end

    it 'be case insensitive when parsing the version string' do
      record = Coppertone::Record.parse('V=sPf1 ~all')
      expect(record).not_to be_nil
      expect(record.directives.size).to eq(1)
      directive = record.directives.first
      expect(directive.qualifier).to eq(Coppertone::Qualifier::SOFTFAIL)
      expect(directive.mechanism).to eq(Coppertone::Mechanism::All.instance)
      expect(record.modifiers).to be_empty
    end

    it 'should parse more complex records' do
      record = Coppertone::Record.parse('v=spf1 mx -all exp=explain._spf.%{d}')
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
          Coppertone::Record.parse(rec)
        end.to raise_error(Coppertone::RecordParsingError)
      end
    end

    it 'should fail when mechanisms are separated by ctrl characters' do
      expect do
        Coppertone::Record.parse("v=spf1 a:ctrl.example.com\x0dptr -all")
      end.to raise_error(Coppertone::RecordParsingError)
    end

    it 'should fail when it contains spurious terms' do
      expect do
        Coppertone::Record.parse('v=spf1 ip4:1.2.3.4 -all moo')
      end.to raise_error(Coppertone::RecordParsingError)
    end

    it 'should fail the domain-spec is not syntactically valid' do
      expect do
        Coppertone::Record.parse('v=spf1 a:foo-bar')
      end.to raise_error(Coppertone::RecordParsingError)
    end
  end
end