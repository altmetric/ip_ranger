# IP Ranger

A gem for converting an arbitrary IP range to the minimal CIDR notation required to describe it exactly.

**Current version:** 0.0.2  
**Supported Ruby versions:** 1.8.7, 1.9.2, 1.9.3, 2.0, 2.1, 2.2, 2.3

## Installation

```
gem install ip_ranger -v '~> 0.0.2'
```

Or, in your `Gemfile`:

```ruby
gem 'ip_ranger', '~> 0.0.2'
```

## Usage

```ruby
require 'ip_ranger'

ip_range = IPRanger::IPRange.new('192.168.1.5', '192.168.1.42')
ip_range.cidrs
# => [#<IPAddr: IPv4:192.168.1.5/255.255.255.255>,
#  #<IPAddr: IPv4:192.168.1.6/255.255.255.254>,
#  #<IPAddr: IPv4:192.168.1.8/255.255.255.248>,
#  #<IPAddr: IPv4:192.168.1.16/255.255.255.240>,
#  #<IPAddr: IPv4:192.168.1.32/255.255.255.248>,
#  #<IPAddr: IPv4:192.168.1.40/255.255.255.254>,
#  #<IPAddr: IPv4:192.168.1.42/255.255.255.255>]
```

## API Documentation

### `IPRanger::IPRange.new(start, finish)`

```ruby
ip_range = IPRanger::IPRange.new('192.168.1.1', '192.168.1.32')
ip_range = IPRanger::IPRange.new(IPAddr.new('10.0.0.1'), IPAddr.new('10.0.0.100'))
```

Return a new `IPRanger::IPRange` instance representing a range between the given `start` and `finish` IP addresses. Addresses can be given as either strings or [`IPAddr`](http://ruby-doc.org/stdlib/libdoc/ipaddr/rdoc/IPAddr.html) instances.

### `IPRanger::IPRange#cidrs`

```ruby
ip_range = IPRanger::IPRange.new('192.168.1.0', '192.168.1.255')
ip_range.cidrs
#=> [#<IPAddr: IPv4:192.168.1.0/255.255.255.0>]

ip_range = IPRanger::IPRange.new('192.168.1.0', '192.168.8.255')
ip_range.cidrs
#=> [#<IPAddr: IPv4:192.168.1.0/255.255.255.0>,
#    #<IPAddr: IPv4:192.168.2.0/255.255.254.0>,
#    #<IPAddr: IPv4:192.168.4.0/255.255.252.0>,
#    #<IPAddr: IPv4:192.168.8.0/255.255.255.0>]
```

Return an array with a minimal number of `IPRanger::IPAddress` objects (wrappers for instances of `IPAddr`), each representing a mask that together cover the entire IP range.

### `IPRanger::IPAddress.new(ip_addr)`

```ruby
ip_address = IPRanger::IPAddress.new(IPAddr.new('192.168.1.1'))
```

A wrapper for instances of Ruby's `IPAddr`that can be used interchangeably with `IPAddr` but with some additional methods for working with CIDR notation.

Typically, you should not need to instantiate these yourself but they will be returned by methods on `IPRanger::IPRanger` and `IPRanger::IPAddress` itself.

### `IPRanger::IPAddress#width`

```ruby
ip_address = IPRanger::IPAddress.new(IPAddr.new('192.168.1.0'))
ip_address.width #=> 32

ip_address = IPRanger::IPAddress.new(IPAddr.new('::1'))
ip_address.width #=> 128
```

Return the width in bits of the IP address: either 32 for an IPv4 or 128 for an IPv6.

### `IPRanger::IPAddress#succ`

```ruby
ip_address = IPRanger::IPAddress.new(IPAddr.new('192.168.1.0'))
ip_address.succ #=> #<IPAddr: IPv4:192.168.1.1/255.255.255.0>
```

Return the successor to this IP address as an `IPRanger::IPAddress` (e.g. `192.168.0.2` succeeds `192.168.0.1`).

### `IPRanger::IPAddress#pred`

```ruby
ip_address = IPRanger::IPAddress.new(IPAddr.new('192.168.1.0'))
ip_address.pred #=> #<IPAddr: IPv4:192.168.0.255/255.255.255.255>
```

Return the predecessor to this IP address as an `IPRanger::IPAddress` (e.g. `192.168.0.1` preceeds `192.168.0.2`).

### `IPRanger::IPAddress#prefixlen`

```ruby
ip_address = IPRanger::IPAddress.new(IPAddr.new('192.168.1.0/24'))
ip_address.prefixlen #=> 24
```

Return the length in bits of the IP address's prefix.

### `IPRanger::IPAddress#to_cidr`

```ruby
ip_address = IPRanger::IPAddress.new(IPAddr.new('192.168.1.0'))
ip_address.to_cidr #=> "192.168.1.0/32"
```

Return the string CIDR notation for this IP address.

## Acknowledgements

* This began as a Ruby port of the Python [netaddr](https://pypi.python.org/pypi/netaddr) library's `iprange_to_cidrs` feature.

## License

Copyright © 2016-2024 Altmetric LLP

Distributed under the MIT License.
