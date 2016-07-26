require 'ipaddr'
require 'delegate'

module Russet
  class IPAddress < DelegateClass(IPAddr)
    def self.from_integer(i, family, mask = nil)
      address = IPAddr.new(i, family)
      address = address.mask(mask) if mask

      new(address)
    end

    def width
      ipv4? ? 32 : 128
    end

    def succ
      new(super)
    end

    def pred
      new(IPAddr.new(to_i - 1, family))
    end

    def prefixlen
      mask_addr.to_s(2).count('1')
    end

    def first
      to_range.first.to_i
    end

    def last
      to_range.last.to_i
    end

    private

    def mask_addr
      __getobj__.instance_variable_get('@mask_addr')
    end
  end
end
