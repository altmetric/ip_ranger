# Russet [![Build Status](https://travis-ci.org/altmetric/russet.svg?branch=master)](https://travis-ci.org/altmetric/russet)

A gem for converting an IP range to a list of CIDR subnets that matches exactly.

**Current version:** 0.0.1
**Supported Ruby versions:** 1.8.7, 1.9.2, 1.9.3, 2.0, 2.1, 2.2

## Usage

```ruby
require 'russet'
ip_range = Russet::IPRange.new('192.168.1.5', '192.168.1.42')
ip_range.cidrs
# => [#<IPAddr: IPv4:192.168.1.5/255.255.255.255>,
#  #<IPAddr: IPv4:192.168.1.6/255.255.255.254>,
#  #<IPAddr: IPv4:192.168.1.8/255.255.255.248>,
#  #<IPAddr: IPv4:192.168.1.16/255.255.255.240>,
#  #<IPAddr: IPv4:192.168.1.32/255.255.255.248>,
#  #<IPAddr: IPv4:192.168.1.40/255.255.255.254>,
#  #<IPAddr: IPv4:192.168.1.42/255.255.255.255>]
```

## Acknowledgements

* This is a Ruby port of the Python [netaddr](https://pypi.python.org/pypi/netaddr) library's `iprange_to_cidrs` feature.

## License

Copyright © 2016 Altmetric LLP

Distributed under the MIT License.
