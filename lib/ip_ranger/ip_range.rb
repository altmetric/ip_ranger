require 'ip_ranger/ip_address'

module IPRanger
  class IPRange
    attr_reader :start, :finish

    def initialize(start, finish)
      @start = IPAddress.new(start.is_a?(IPAddr) ? start : IPAddr.new(start))
      @finish = IPAddress.new(finish.is_a?(IPAddr) ? finish : IPAddr.new(finish))

      fail ArgumentError, 'IP sequence cannot contain both IPv4 and IPv6!' if @start.family != @finish.family
    end

    def cidrs
      cidr_list = []
      cidr_span = spanning_cidr

      if cidr_span.first < first
        exclude = first.pred
        cidr_list = cidr_partition(cidr_span, exclude).last
        cidr_span = cidr_list.pop
      end

      if cidr_span.last > last
        exclude = last.succ
        cidr_list += cidr_partition(cidr_span, exclude).first
      else
        cidr_list << cidr_span
      end

      cidr_list
    end

    private

    def first
      start.first
    end

    def last
      finish.last
    end

    def spanning_cidr
      ipnum = last
      lower_bound = first

      prefixlen = finish.prefixlen
      address_space = finish.address_space

      while prefixlen > 0 && ipnum > lower_bound
        prefixlen -= 1
        ipnum &= -(1 << (address_space - prefixlen))
      end

      IPAddress.from_integer(ipnum, finish.family, prefixlen)
    end

    def cidr_partition(target, exclude)
      exclude = IPAddress.from_integer(exclude, target.family)

      if exclude.last < target.first
        return [], [], [target]
      elsif target.last < exclude.first
        return [target], [], []
      end

      return [], [target], [] if target.prefixlen >= exclude.prefixlen

      left = []
      right = []

      new_prefixlen = target.prefixlen + 1
      target_address_space = target.address_space

      target_first = target.first
      i_lower = target_first
      i_upper = target_first + (2 ** (target_address_space - new_prefixlen))

      while exclude.prefixlen >= new_prefixlen
        if exclude.first >= i_upper
          left << IPAddress.from_integer(i_lower, target.family, new_prefixlen)
          matched = i_upper
        else
          right << IPAddress.from_integer(i_upper, target.family, new_prefixlen)
          matched = i_lower
        end

        new_prefixlen += 1
        break if new_prefixlen > target_address_space

        i_lower = matched
        i_upper = matched + (2 ** (target_address_space - new_prefixlen))
      end

      [left, [exclude], right.reverse]
    end
  end
end
