# -*- mode: ruby -*-
Gem::Specification.new do |s|
  s.name = 'ixtlan-error-handler'
  s.version = '0.1.0'

  s.summary = 'dump errors on filesystem and notify developers'
  s.description = 'dump errors on filesystem and notify developers, map different errors to specific pages'
  s.homepage = 'http://github.com/mkristian/ixtlan-error-handler'

  s.authors = ['mkristian']
  s.email = ['m.kristian@web.de']

  s.files = Dir['MIT-LICENSE']
  s.licenses << 'MIT-LICENSE'
#  s.files += Dir['History.txt']
  s.files += Dir['README.textile']
#  s.extra_rdoc_files = ['History.txt','README.textile']
  s.rdoc_options = ['--main','README.textile']
  s.files += Dir['lib/**/*']
  s.files += Dir['spec/**/*']
  s.files += Dir['features/**/*rb']
  s.files += Dir['features/**/*feature']
  s.test_files += Dir['spec/**/*_spec.rb']
  s.test_files += Dir['features/*.feature']
  s.test_files += Dir['features/step_definitions/*.rb']
  s.add_development_dependency 'rails', '3.0.1'
  s.add_development_dependency 'rspec', '2.0.1'
  s.add_development_dependency 'cucumber', '0.9.4'
  s.add_development_dependency 'rake', '0.8.7'
end

# vim: syntax=Ruby
