require 'spec_helper'

describe Coppertone::Modifier::Exp do
  context 'to_s' do
    it 'should result in the expected string' do
      expect(Coppertone::Modifier::Exp.new('test.example.com').to_s)
        .to eq('exp=test.example.com')
    end
  end
end
