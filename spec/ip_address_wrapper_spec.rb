require 'spec_helper'

describe Coppertone::IPAddressWrapper do
  it 'should raise an ArgumentError when passed a nil arg' do
    expect do
      Coppertone::IPAddressWrapper.new(nil)
    end.to raise_error(ArgumentError)
  end

  it 'should raise an ArgumentError when passed an invalid arg' do
    expect do
      Coppertone::IPAddressWrapper.new('invalid')
    end.to raise_error(ArgumentError)
  end

  context 'ipv4' do
    it 'should yield expected values' do
      ip_as_s = '1.2.3.4'
      ipw = Coppertone::IPAddressWrapper.new(ip_as_s)
      expect(ipw.ip_v4).to eq(IPAddr.new(ip_as_s))
      expect(ipw.ip_v6).to be_nil
      expect(ipw.c).to eq(ip_as_s)
      expect(ipw.i).to eq(ip_as_s)
      expect(ipw.v).to eq('in-addr')
    end

    it 'should raise an ArgumentError when passed an IP with a prefix' do
      expect do
        Coppertone::IPAddressWrapper.new('1.2.3.4/24')
      end.to raise_error(ArgumentError)
    end
  end

  context 'ipv6' do
    context 'when the address is not IP4 mapped' do
      it 'should yield expected values' do
        ip_as_s = 'FE80:0000:0000:0000:0202:B3FF:FE1E:8329'
        ipw = Coppertone::IPAddressWrapper.new(ip_as_s)
        expect(ipw.ip_v6).to eq(IPAddr.new(ip_as_s))
        expect(ipw.ip_v4).to be_nil
        dotted =
          'F.E.8.0.0.0.0.0.0.0.0.0.0.0.0.0.0.2.0.2.B.3.F.F.F.E.1.E.8.3.2.9'
        expect(ipw.i).to eq(dotted)
        expect(ipw.v).to eq('ip6')
      end
    end

    context 'when the address is IP4 mapped' do
      it 'should treat it as an IP4 address' do
        ip_v4_as_s = '1.2.3.4'
        ip_as_s = "::ffff:#{ip_v4_as_s}"
        ipw = Coppertone::IPAddressWrapper.new(ip_as_s)
        expect(ipw.ip_v6).to be_nil
        expect(ipw.ip_v4).to eq(IPAddr.new(ip_v4_as_s))
        expect(ipw.c).to eq(ip_v4_as_s)
        expect(ipw.i).to eq(ip_v4_as_s)
        expect(ipw.v).to eq('in-addr')
      end
    end

    it 'should raise an ArgumentError when passed an IP with a prefix' do
      expect do
        Coppertone::IPAddressWrapper.new('1.2.3.4/96')
      end.to raise_error(ArgumentError)
    end
  end
end
