require 'rake/rdoctask'
require 'rake/testtask'
require 'rubygems'

task :default => ['test']

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/*_test.rb']
  t.ruby_opts = ['-rubygems'] if defined? Gem
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "wurfl"
    gemspec.summary = "Library and tools for manipulating the WURFL"
    gemspec.description = "Library and tools for manipulating the WURFL"
    gemspec.email = "info@mobalean.com"
    gemspec.homepage = "http://github.com/pwim/wurfl"
    gemspec.description = "TODO"
    gemspec.authors = ["Paul McMahon", "Zev Blut"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'WURFL'
  rdoc.main     = "README.rdoc"
  rdoc.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end
