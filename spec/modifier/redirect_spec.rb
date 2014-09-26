require 'spec_helper'

describe Coppertone::Modifier::Redirect do
  context 'to_s' do
    it 'should result in the expected string' do
      expect(Coppertone::Modifier::Redirect.new('test.example.com').to_s)
        .to eq('redirect=test.example.com')
    end
  end
end
