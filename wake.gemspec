# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','wake','version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'wake'
  s.version = Wake::VERSION
  s.author = 'Nathan Herald, Ryan Levick'
  s.email = 'me@nathanherald.com'
  s.homepage = 'https://github.com/wakeful-deployment/wake-gem'
  s.platform = Gem::Platform::RUBY
  s.summary = 'An opinionated deployment cli'
  s.files = `git ls-files`.lines.compact
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['DOC.rdoc', 'wake.rdoc']
  s.rdoc_options << '--title' << 'wake' << '--main' << 'DOC.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'wake'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_runtime_dependency('gli', '~> 2.13.4')
end
