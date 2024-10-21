require 'ip_ranger'

RSpec.describe IPRanger::IPRange do
  it 'converts an IP range to two IPs' do
    ip_range = described_class.new('1.1.1.1', '1.1.1.2')

    expect(ip_range.cidrs).to contain_exactly(IPAddr.new('1.1.1.1/32'), IPAddr.new('1.1.1.2/32'))
  end

  it 'converts an IP range with two common subnets to CIDR blocks' do
    ip_range = described_class.new('1.1.3.5', '1.1.11.50')

    expect(ip_range.cidrs).to contain_exactly(
      IPAddr.new('1.1.3.5/32'),
      IPAddr.new('1.1.3.6/31'),
      IPAddr.new('1.1.3.8/29'),
      IPAddr.new('1.1.3.16/28'),
      IPAddr.new('1.1.3.32/27'),
      IPAddr.new('1.1.3.64/26'),
      IPAddr.new('1.1.3.128/25'),
      IPAddr.new('1.1.4.0/22'),
      IPAddr.new('1.1.8.0/23'),
      IPAddr.new('1.1.10.0/24'),
      IPAddr.new('1.1.11.0/27'),
      IPAddr.new('1.1.11.32/28'),
      IPAddr.new('1.1.11.48/31'),
      IPAddr.new('1.1.11.50/32')
    )
  end

  it 'converts an IP range with no common subnets to CIDR blocks' do
    ip_range = described_class.new('192.168.0.1', '200.50.50.50')

    expect(ip_range.cidrs).to contain_exactly(
      IPAddr.new('192.168.0.1/32'),
      IPAddr.new('192.168.0.2/31'),
      IPAddr.new('192.168.0.4/30'),
      IPAddr.new('192.168.0.8/29'),
      IPAddr.new('192.168.0.16/28'),
      IPAddr.new('192.168.0.32/27'),
      IPAddr.new('192.168.0.64/26'),
      IPAddr.new('192.168.0.128/25'),
      IPAddr.new('192.168.1.0/24'),
      IPAddr.new('192.168.2.0/23'),
      IPAddr.new('192.168.4.0/22'),
      IPAddr.new('192.168.8.0/21'),
      IPAddr.new('192.168.16.0/20'),
      IPAddr.new('192.168.32.0/19'),
      IPAddr.new('192.168.64.0/18'),
      IPAddr.new('192.168.128.0/17'),
      IPAddr.new('192.169.0.0/16'),
      IPAddr.new('192.170.0.0/15'),
      IPAddr.new('192.172.0.0/14'),
      IPAddr.new('192.176.0.0/12'),
      IPAddr.new('192.192.0.0/10'),
      IPAddr.new('193.0.0.0/8'),
      IPAddr.new('194.0.0.0/7'),
      IPAddr.new('196.0.0.0/6'),
      IPAddr.new('200.0.0.0/11'),
      IPAddr.new('200.32.0.0/12'),
      IPAddr.new('200.48.0.0/15'),
      IPAddr.new('200.50.0.0/19'),
      IPAddr.new('200.50.32.0/20'),
      IPAddr.new('200.50.48.0/23'),
      IPAddr.new('200.50.50.0/27'),
      IPAddr.new('200.50.50.32/28'),
      IPAddr.new('200.50.50.48/31'),
      IPAddr.new('200.50.50.50/32')
    )
  end

  it 'returns one address when the range is a single IP' do
    ip_range = described_class.new('192.168.1.1', '192.168.1.1')

    expect(ip_range.cidrs).to contain_exactly(IPAddr.new('192.168.1.1/32'))
  end

  it 'converts an IPv6 range to CIDR blocks' do
    ip_range = described_class.new('2001:db8::', '2001:db8:0000:0000:0000:0000:0000:0001')

    expect(ip_range.cidrs).to contain_exactly(IPAddr.new('2001:db8::/127'))
  end

  it 'raises if given incompatible IP addresses' do
    expect { described_class.new('192.168.1.1', '2001:0db8:0000:0042:0000:8a2e:0370:7334') }
      .to raise_error('IP sequence cannot contain both IPv4 and IPv6!')
  end
end
