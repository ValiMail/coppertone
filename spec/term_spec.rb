require 'spec_helper'

describe Coppertone::Term do
  context '#build' do
    it 'should return nil for a nil argument' do
      expect(Coppertone::Term.build_from_token(nil)).to be_nil
    end

    it 'should check Directive first' do
      token = SecureRandom.hex(10)
      term = double(:term)
      expect(Coppertone::Directive)
        .to receive(:matching_term).with(token).and_return(term)
      expect(Coppertone::Modifier).not_to receive(:matching_term)
      expect(Coppertone::Term.build_from_token(token)).to eq(term)
    end

    it 'should fallback to Modifier' do
      token = SecureRandom.hex(10)
      term = double(:term)
      expect(Coppertone::Directive)
        .to receive(:matching_term).with(token).and_return(nil)
      expect(Coppertone::Modifier)
        .to receive(:matching_term).with(token).and_return(term)
      expect(Coppertone::Term.build_from_token(token)).to eq(term)
    end

    it 'should propagate errors' do
      token = SecureRandom.hex(10)
      expect(Coppertone::Directive)
        .to receive(:matching_term).with(token)
                                   .and_raise(Coppertone::Error)
      expect do
        Coppertone::Term.build_from_token(token)
      end.to raise_error(Coppertone::Error)
    end
  end
end
