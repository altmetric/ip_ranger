Gem::Specification.new do |s|
  s.name = 'ip_ranger'
  s.version = '0.0.1'
  s.summary = 'A utility for converting IP ranges to CIDR subnets'
  s.homepage = 'https://github.com/altmetric/ip_ranger'
  s.authors = ['Maciej Gajewski', 'Paul Mucur']
  s.files = Dir['lib/**/*.rb']
  s.test_files = Dir['spec/**/*.rb']

  s.add_development_dependency('rspec', '~> 3.5')
end
