require 'spec_helper'

describe Coppertone::Modifier::Unknown do
  it 'should always be context independent and never require macro evaluation' do
    unk = Coppertone::Modifier::Unknown.new('abcd', 'wxyz')
    expect(unk).not_to be_context_dependent
    expect(unk).not_to be_includes_ptr
    expect(unk.to_s).to eq('abcd=wxyz')
  end
end
