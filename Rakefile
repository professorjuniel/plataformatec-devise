# encoding: UTF-8

require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run tests for all ORMs.'
task :default => :test

desc 'Run Devise tests for all ORMs.'
task :pre_commit do
  Dir[File.join(File.dirname(__FILE__), 'test', 'orm', '*.rb')].each do |file|
    orm = File.basename(file).split(".").first
    # "Some day, my son, rake's inner wisdom will reveal itself.  Until then,
    # take this `system` -- may its brute force protect you well."
    exit 1 unless system "rake test DEVISE_ORM=#{orm}"
  end
end

desc 'Run Devise unit tests.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for Devise.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Devise'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
