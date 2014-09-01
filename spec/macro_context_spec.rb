require 'spec_helper'

describe Coppertone::MacroContext do
  let(:domain) { 'yahoo.com' }
  let(:sender) { 'test em!?axt@gmail.com' }
  let(:ip_v4) { '1.2.3.4' }
  let(:ip_v6) { 'fe80::202:b3ff:fe1e:8329' }

  let(:machine_hostname) { 'mta.receiver-1.xyz.com' }

  before do
    allow(Coppertone::Utils::HostUtils)
      .to receive(:hostname).and_return(machine_hostname)
  end

  context 'ip_v4' do
    it 'should map as expected' do
      mc = Coppertone::MacroContext.new(domain, ip_v4, sender)
      expect(mc.s).to eq(sender)
      expect(mc.l).to eq('test em!?axt')
      expect(mc.o).to eq('gmail.com')
      expect(mc.d).to eq(domain)
      expect(mc.i).to eq(ip_v4)
      expect(mc.v).to eq('in-addr')
      # TODO: PMG - Add support for 'p'
      expect(mc.c).to eq(ip_v4)
      before = Time.now.to_i
      t = mc.t
      after = Time.now.to_i
      expect(t >= before).to eq(true)
      expect(t <= after).to eq(true)
      expect(mc.r).to eq(machine_hostname)

      expect(mc.S).to eq('test%20em!%3Faxt%40gmail.com')
      expect(mc.L).to eq('test%20em!%3Faxt')
      expect(mc.O).to eq('gmail.com')
      expect(mc.D).to eq(domain)
      expect(mc.I).to eq(ip_v4)
      expect(mc.V).to eq('in-addr')
    end
  end

  context 'ip_v6' do
    it 'should map as expected' do
      mc = Coppertone::MacroContext.new(domain, ip_v6, sender)
      expect(mc.s).to eq(sender)
      expect(mc.l).to eq('test em!?axt')
      expect(mc.o).to eq('gmail.com')
      expect(mc.d).to eq(domain)
      dip = 'F.E.8.0.0.0.0.0.0.0.0.0.0.0.0.0.0.2.0.2.B.3.F.F.F.E.1.E.8.3.2.9'
      expect(mc.i).to eq(dip)
      expect(mc.v).to eq('ip6')
      # TODO: PMG - Add support for 'p'
      expect(mc.c).to eq(ip_v6)
      before = Time.now.to_i
      t = mc.t
      after = Time.now.to_i
      expect(t >= before).to eq(true)
      expect(t <= after).to eq(true)

      expect(mc.S).to eq('test%20em!%3Faxt%40gmail.com')
      expect(mc.L).to eq('test%20em!%3Faxt')
      expect(mc.O).to eq('gmail.com')
      expect(mc.D).to eq(domain)
      expect(mc.I).to eq(dip)
      expect(mc.V).to eq('ip6')
    end
  end
end
