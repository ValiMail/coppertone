require 'spec_helper'

describe Coppertone::DomainSpec do
  it 'raises no exception for a normal string' do
    expect(Coppertone::DomainSpec.new('gmail.com')).not_to be_nil
  end

  it 'raises no exception for a macro with allowed terms' do
    expect(Coppertone::DomainSpec.new('%{s}%{l}%{o}%{d}%{i}%{v}'))
      .not_to be_nil
    expect(Coppertone::DomainSpec.new('%{S}%{L}%{O}%{D}%{I}%{V}'))
      .not_to be_nil
  end

  it 'raises no exception for a macro with reverse' do
    expect(Coppertone::DomainSpec.new('%{sr}%{lr}%{or}%{dr}%{ir}%{vr}'))
      .not_to be_nil
    expect(Coppertone::DomainSpec.new('%{Sr}%{Lr}%{Or}%{Dr}%{Ir}%{Vr}'))
      .not_to be_nil
  end

  it 'raises an error when the macro string is malformed' do
    expect do
      Coppertone::DomainSpec.new('%&')
    end.to raise_error(Coppertone::DomainSpecParsingError)
  end

  it 'raises an error when the macro string contains forbidden macros' do
    %w[c r t].each do |m|
      expect do
        Coppertone::DomainSpec.new("%{#{m}}")
      end.to raise_error(Coppertone::DomainSpecParsingError)
    end
  end
end
