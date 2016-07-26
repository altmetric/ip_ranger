Gem::Specification.new do |s|
  s.name = 'russet'
  s.version = '0.0.1'
  s.summary = 'A utility for converting an IP range to CIDR subnets'
  s.homepage = 'https://github.com/altmetric/russet'
  s.authors = ['Maciej Gajewski', 'Paul Mucur']
  s.files = Dir['lib/**/*.rb']
  s.test_files = Dir['spec/**/*.rb']

  s.add_development_dependency('rspec', '~> 3.5')
end
