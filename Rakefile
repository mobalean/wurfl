require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'rubygems'

task :default => ['test']

Rake::TestTask.new(:test) do |t|
  t.test_files = FileList['test/*_test.rb']
  t.ruby_opts = ['-rubygems'] if defined? Gem
end

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = "Library and tools for manipulating the WURFL"
  s.name = "wurfl"
  s.version = "1.0.2"
  s.author = "mobalean"
  s.email = "info@mobalean.com"
  s.homepage = "http://www.mobalean.com/"
  s.files = FileList["{lib}/**/*"].to_a
  s.require_path = "lib"
  s.test_files = FileList["{test}/{lib}/**/*_test.rb"].to_a
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'WURFL'
  rdoc.main     = "README.rdoc"
  rdoc.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end
