require 'ip_ranger'

RSpec.describe IPRanger::IPAddress do
  describe '#to_cidr' do
    it 'returns a full address with netmask' do
      address = described_class.new(IPAddr.new('192.168.0.0/20'))

      expect(address.to_cidr).to eq('192.168.0.0/20')
    end
  end

  describe '#width' do
    it 'returns 32 for an IPv4' do
      address = described_class.new(IPAddr.new('192.168.1.1'))

      expect(address.width).to eq(32)
    end

    it 'returns 128 for an IPv6' do
      address = described_class.new(IPAddr.new('::1'))

      expect(address.width).to eq(128)
    end
  end

  describe '#succ' do
    it 'returns the succeeding IPv4 address' do
      address = described_class.new(IPAddr.new('192.168.1.1'))

      expect(address.succ).to eq(IPAddr.new('192.168.1.2'))
    end

    it 'returns the succeeding IPv6 address' do
      address = described_class.new(IPAddr.new('::1'))

      expect(address.succ).to eq(IPAddr.new('::2'))
    end
  end

  describe '#pred' do
    it 'returns the preceeding IPv4 address' do
      address = described_class.new(IPAddr.new('192.168.1.2'))

      expect(address.pred).to eq(IPAddr.new('192.168.1.1'))
    end

    it 'returns the preceeding IPv6 address' do
      address = described_class.new(IPAddr.new('::2'))

      expect(address.pred).to eq(IPAddr.new('::1'))
    end
  end

  describe '#prefixlen' do
    it 'returns a length of 32 if a single IPv4 address' do
      address = described_class.new(IPAddr.new('192.168.1.1'))

      expect(address.prefixlen).to eq(32)
    end

    it 'returns a length of 128 if a single IPv6 address' do
      address = described_class.new(IPAddr.new('::1'))

      expect(address.prefixlen).to eq(128)
    end

    it 'returns the length if masked' do
      address = described_class.new(IPAddr.new('192.168.1.1/24'))

      expect(address.prefixlen).to eq(24)
    end
  end
end
