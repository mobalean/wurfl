require 'rake/rdoctask'
require 'rake/testtask'
require 'rubygems'
require 'shoulda/tasks'

task :default => ['test']

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/*_test.rb']
  t.ruby_opts = ['-rubygems'] if defined? Gem
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "wurfl"
    s.summary = "Library and tools for manipulating the WURFL"
    s.description = "Library and tools for manipulating the WURFL"
    s.email = "info@mobalean.com"
    s.homepage = "http://wurfl.rubyforge.org"
    s.authors = ["Paul McMahon", "Zev Blut"]
    s.rubyforge_project = 'wurfl'
  end
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'WURFL'
  rdoc.main     = "README.rdoc"
  rdoc.rdoc_files.include("README.rdoc", "LICENSE", "lib/**/*.rb")
end
