# -*- mode: ruby -*-
Gem::Specification.new do |s|
  s.name = 'ixtlan-error-handler'
  s.version = '0.3.0'

  s.summary = 'dump errors on filesystem and notify developers'
  s.description = 'dump errors on filesystem and notify developers, map different errors to specific pages'
  s.homepage = 'http://github.com/mkristian/ixtlan-error-handler'

  s.authors = ['Christian Meier']
  s.email = ['m.kristian@web.de']

  s.files = Dir['MIT-LICENSE']
  s.licenses << 'MIT'
#  s.files += Dir['History.txt']
  s.files += Dir['README.textile']
#  s.extra_rdoc_files = ['History.txt','README.textile']
  s.rdoc_options = ['--main','README.textile']
  s.files += Dir['lib/**/*']
  s.files += Dir['spec/**/*']
  s.test_files += Dir['spec/**/*_spec.rb']
  s.add_dependency 'slf4r', '~> 0.4.2'
  s.add_development_dependency 'rspec', '~> 2.11'
  s.add_development_dependency 'rake', '~> 10.0.2'
  s.add_development_dependency 'dm-core', '~> 1.2.0'
  s.add_development_dependency 'dm-migrations', '~> 1.2.0'
  s.add_development_dependency 'dm-sqlite-adapter', '~> 1.2.0'
  s.add_development_dependency 'copyright-header', '~> 1.0.7'
end

# vim: syntax=Ruby
