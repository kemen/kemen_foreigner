# -*- encoding: utf-8 -*-
 
Gem::Specification.new do |s|
  s.name = 'kemen_foreigner'
  s.version = '0.0.3'
  s.summary = 'Foreign keys for Rails'
  s.description = ''

  s.required_ruby_version     = '>= 1.8.6'
  s.required_rubygems_version = '>= 1.3.5'

  s.author            = 'Cloned by Matthew Higgins'
  s.email             = ''
  s.homepage          = ''
  s.rubyforge_project = 'kemen_foreigner'

  s.extra_rdoc_files = ['README.rdoc']
  s.files = %w(MIT-LICENSE Rakefile README.rdoc) + Dir['lib/**/*.rb'] + Dir['test/**/*.rb']
  s.require_paths = %w(lib)  
end
