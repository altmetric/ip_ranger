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

      if cidr_span.numerical_lower_bound < first
        exclude = first.pred
        cidr_list = cidr_partition(cidr_span, exclude).last
        cidr_span = cidr_list.pop
      end

      if cidr_span.numerical_upper_bound > last
        exclude = last.succ
        cidr_list += cidr_partition(cidr_span, exclude).first
      else
        cidr_list << cidr_span
      end

      cidr_list
    end

    private

    def first
      start.numerical_lower_bound
    end

    def last
      finish.numerical_upper_bound
    end

    def spanning_cidr
      ipnum = last
      lower_bound = first

      subnet_mask = finish.subnet_mask
      address_space = finish.address_space

      while subnet_mask > 0 && ipnum > lower_bound
        subnet_mask -= 1
        ipnum &= -(1 << (address_space - subnet_mask))
      end

      IPAddress.from_integer(ipnum, finish.family, subnet_mask)
    end

    def cidr_partition(target, exclude)
      exclude = IPAddress.from_integer(exclude, target.family)

      if exclude.numerical_upper_bound < target.numerical_lower_bound
        return [], [], [target]
      elsif target.numerical_upper_bound < exclude.numerical_lower_bound
        return [target], [], []
      end

      return [], [target], [] if target.subnet_mask >= exclude.subnet_mask

      left = []
      right = []

      new_subnet_mask = target.subnet_mask + 1
      target_address_space = target.address_space

      target_first = target.numerical_lower_bound
      i_lower = target_first
      i_upper = target_first + (2 ** (target_address_space - new_subnet_mask))

      while exclude.subnet_mask >= new_subnet_mask
        if exclude.numerical_lower_bound >= i_upper
          left << IPAddress.from_integer(i_lower, target.family, new_subnet_mask)
          matched = i_upper
        else
          right << IPAddress.from_integer(i_upper, target.family, new_subnet_mask)
          matched = i_lower
        end

        new_subnet_mask += 1
        break if new_subnet_mask > target_address_space

        i_lower = matched
        i_upper = matched + (2 ** (target_address_space - new_subnet_mask))
      end

      [left, [exclude], right.reverse]
    end
  end
end
