require 'rake/clean'
require 'rubygems'
require 'rubygems/package_task'
require 'rdoc/task'

Rake::RDocTask.new do |rd|
  rd.main = "DOC.rdoc"
  rd.rdoc_files.include("DOC.rdoc", "lib/**/*.rb", "bin/**/*")
  rd.title = 'wake: opinionated deployment cli'
end

spec = eval(File.read('wake.gemspec'))

Gem::PackageTask.new(spec) do |pkg|
end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
  # t.verbose = true
end

task :default => :test
