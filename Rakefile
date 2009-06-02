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
  Jeweler::Tasks.new do |s|
    s.name = "wurfl"
    s.summary = "Library and tools for manipulating the WURFL"
    s.description = "Library and tools for manipulating the WURFL"
    s.email = "info@mobalean.com"
    s.homepage = "http://github.com/pwim/wurfl"
    s.description = "TODO"
    s.authors = ["Paul McMahon", "Zev Blut"]
    s.rubyforge_project = 'wurfl'
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

begin
  require 'rake/contrib/sshpublisher'
  namespace :rubyforge do

    desc "Release gem and RDoc documentation to RubyForge"
    task :release => ["rubyforge:release:gem", "rubyforge:release:docs"]

    namespace :release do
      desc "Publish RDoc to RubyForge."
      task :docs => [:rdoc] do
        config = YAML.load(
            File.read(File.expand_path('~/.rubyforge/user-config.yml'))
        )

        host = "#{config['username']}@rubyforge.org"
        remote_dir = "/var/www/gforge-projects/wurfl/"
        local_dir = 'rdoc'

        Rake::SshDirPublisher.new(host, remote_dir, local_dir).upload
      end
    end
  end
rescue LoadError
  puts "Rake SshDirPublisher is unavailable or your rubyforge environment is not configured."
end

