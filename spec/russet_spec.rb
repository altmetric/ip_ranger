require 'ipaddr'

class IPAddr
  def width
    ipv4? ? 32 : 128
  end

  def pred
    clone.set!(@addr - 1, @family)
  end

  def prefixlen
    @mask_addr.to_s(2).count('1')
  end

  def first
    to_range.first.to_i
  end

  def last
    to_range.last.to_i
  end
end

class Russet
  def self.iprange_to_cidrs(start, finish)
    cidr_list = []

    start = IPAddr.new(start)
    finish = IPAddr.new(finish)

    iprange = [start.first, finish.last]

    cidr_span = spanning_cidr([start, finish])

    if cidr_span.first < iprange[0]
      exclude = iprange[0].pred
      cidr_list = cidr_partition(cidr_span, exclude)[2]
      cidr_span = cidr_list.pop
    end

    if cidr_span.last > iprange[1]
      exclude = iprange[1].succ
      cidr_list += cidr_partition(cidr_span, exclude)[0]
    else
      cidr_list << cidr_span
    end

    cidr_list
  end

  def self.spanning_cidr(ip_addrs)
    fail 'IP sequence cannot contain both IPv4 and IPv6!' if ip_addrs.map(&:family).uniq.length > 1

    sorted_ips = ip_addrs.sort
    fail 'IP sequence must contain at least 2 elements!' unless sorted_ips.length > 1

    lowest_ip = sorted_ips.first
    highest_ip = sorted_ips.last

    ipnum = highest_ip.last
    prefixlen = highest_ip.prefixlen
    lowest_ipnum = lowest_ip.first
    width = highest_ip.width

    while prefixlen > 0 && ipnum > lowest_ipnum
      prefixlen -= 1
      ipnum &= -(1 << (width - prefixlen))
    end

    IPAddr.new(ipnum, highest_ip.family).mask(prefixlen)
  end

  def self.cidr_partition(target, exclude)
    exclude = IPAddr.new(exclude, target.family)

    if exclude.last < target.first
      return [], [], [target]
    elsif target.last < exclude.first
      return [target], [], []
    end

    if target.prefixlen >= exclude.prefixlen
      return [], [target], []
    end

    left = []
    right = []

    new_prefixlen = target.prefixlen + 1
    target_width = target.width

    target_first = target.first
    i_lower = target_first
    i_upper = target_first + (2 ** (target_width - new_prefixlen))

    while exclude.prefixlen >= new_prefixlen
      if exclude.first >= i_upper
        left << IPAddr.new(i_lower, target.family).mask(new_prefixlen)
        matched = i_upper
      else
        right << IPAddr.new(i_upper, target.family).mask(new_prefixlen)
        matched = i_lower
      end

      new_prefixlen += 1
      break if new_prefixlen > target_width

      i_lower = matched
      i_upper = matched + (2 ** (target_width - new_prefixlen))
    end

    [left, [exclude], right.reverse]
  end
end

RSpec.describe Russet do
  it 'converts an IP range to two IPs' do
    expect(described_class.iprange_to_cidrs('1.1.1.1', '1.1.1.2')).to contain_exactly(IPAddr.new('1.1.1.1/32'), IPAddr.new('1.1.1.2/32'))
  end

  it 'converts an IP range to CIDR blocks' do
    expect(described_class.iprange_to_cidrs('1.1.3.5', '1.1.11.50')).to contain_exactly(
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

  it 'converts an IP range to CIDR blocks #2' do
    expect(described_class.iprange_to_cidrs('192.168.0.1', '200.50.50.50')).to contain_exactly(
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

  it 'return one CIDR address' do
    expect(described_class.iprange_to_cidrs('192.168.1.1', '192.168.1.1')).to contain_exactly(IPAddr.new('192.168.1.1/32'))
  end

  it 'converts an IPv6 range to CIDR blocks' do
    expect(described_class.iprange_to_cidrs('2001:db8::', '2001:db8:0000:0000:0000:0000:0000:0001')).to contain_exactly(IPAddr.new('2001:db8::/127'))
  end

  it 'raises if given incompatible IP addresses' do
    expect { described_class.iprange_to_cidrs('192.168.1.1', '2001:0db8:0000:0042:0000:8a2e:0370:7334') }.to raise_error('IP sequence cannot contain both IPv4 and IPv6!')
  end
end
