require 'ip_ranger'

RSpec.describe IPRanger::IPAddress do
  describe '#to_cidr' do
    it 'returns a full address with netmask' do
      address = described_class.new(IPAddr.new('192.168.0.0/20'))

      expect(address.to_cidr).to eq('192.168.0.0/20')
    end
  end
end
