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
  t.test_files = FileList['test/**/*_test.rb']
  # t.verbose = true
end

task :default => :test

# format stuff

code_files = FileList["**/*.rb"]
code_files.include("**/*.sh")
code_files.include("**/*.erb")
code_files.include("**/*.json")
code_files.include("**/Dockerfile*")

task :crlf do
  code_files.each do |file|
    new_file = File.read(file, universal_newline: true).lines.map { |line| line.delete("\r") }.join
    File.open(file, mode: "w", universal_newline: true) { |f| f << new_file }
  end
end

require 'rubocop/rake_task'

desc 'Run RuboCop'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['**/*.rb']
  task.formatters = ['files']
  task.fail_on_error = false
end

task :format => [:crlf, :rubocop]
