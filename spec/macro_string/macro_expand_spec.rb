require 'spec_helper'

describe Coppertone::MacroString::MacroExpand do
  context 'equality' do
    it 'should treat different MacroExpands with the same value as equal' do
      arg = 'dr-'
      macro = Coppertone::MacroString::MacroExpand.new(arg)
      expect(macro == Coppertone::MacroString::MacroExpand.new(arg))
        .to eql(true)
    end

    it 'should otherwise treat different MacroExpands as unequal' do
      arg = 'dr-'
      macro = Coppertone::MacroString::MacroExpand.new(arg)
      other_arg = 'r3+'
      expect(macro == Coppertone::MacroString::MacroExpand.new(other_arg))
        .to eql(false)
    end
  end

  context 'expand' do
    let(:domain) { 'yahoo.com' }
    let(:sender) { 'admin-user@gmail.com' }
    let(:ip_v4) { '1.2.3.4' }
    let(:ip_v6) { 'fe80::202:b3ff:fe1e:8329' }

    context 'ip_v4' do
      let(:context) { Coppertone::MacroContext.new(domain, ip_v4, sender) }
      it 'should expand as expected' do
        expect(Coppertone::MacroString::MacroExpand.new('d').expand(context))
          .to eq('yahoo.com')
        expect(Coppertone::MacroString::MacroExpand.new('d1').expand(context))
          .to eq('com')
        expect(Coppertone::MacroString::MacroExpand.new('dr').expand(context))
          .to eq('com.yahoo')
        expect(Coppertone::MacroString::MacroExpand.new('d1r').expand(context))
          .to eq('yahoo')

        expect(Coppertone::MacroString::MacroExpand.new('o').expand(context))
          .to eq('gmail.com')
        expect(Coppertone::MacroString::MacroExpand.new('o1').expand(context))
          .to eq('com')
        expect(Coppertone::MacroString::MacroExpand.new('or').expand(context))
          .to eq('com.gmail')
        expect(Coppertone::MacroString::MacroExpand.new('o1r').expand(context))
          .to eq('gmail')

        expect(Coppertone::MacroString::MacroExpand.new('l').expand(context))
          .to eq('admin-user')
        expect(Coppertone::MacroString::MacroExpand.new('l1').expand(context))
          .to eq('admin-user')
        expect(Coppertone::MacroString::MacroExpand.new('l1-').expand(context))
          .to eq('user')
        expect(Coppertone::MacroString::MacroExpand.new('lr').expand(context))
          .to eq('admin-user')
        expect(Coppertone::MacroString::MacroExpand.new('lr-').expand(context))
          .to eq('user.admin')
        expect(Coppertone::MacroString::MacroExpand.new('l1r-').expand(context))
          .to eq('admin')

        expect(Coppertone::MacroString::MacroExpand.new('i').expand(context))
          .to eq('1.2.3.4')
        expect(Coppertone::MacroString::MacroExpand.new('i2').expand(context))
          .to eq('3.4')
        expect(Coppertone::MacroString::MacroExpand.new('i6').expand(context))
          .to eq('1.2.3.4')
        expect(Coppertone::MacroString::MacroExpand.new('ir').expand(context))
          .to eq('4.3.2.1')
        expect(Coppertone::MacroString::MacroExpand.new('i2r').expand(context))
          .to eq('2.1')
        expect(Coppertone::MacroString::MacroExpand.new('i6r').expand(context))
          .to eq('4.3.2.1')

        expect(Coppertone::MacroString::MacroExpand.new('v').expand(context))
          .to eq('in-addr')
      end
    end
  end
end
