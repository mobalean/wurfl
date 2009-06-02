# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{wurfl}
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul McMahon", "Zev Blut"]
  s.date = %q{2009-06-02}
  s.description = %q{TODO}
  s.email = %q{info@mobalean.com}
  s.executables = ["uaproftowurfl.rb", "wurflsanitycheck.rb", "wurflinspector.rb", "wurflloader.rb", "uaprofwurflcomparator.rb", "wurflcomparator.rb"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/uaproftowurfl.rb",
     "bin/uaprofwurflcomparator.rb",
     "bin/wurflcomparator.rb",
     "bin/wurflinspector.rb",
     "bin/wurflloader.rb",
     "bin/wurflsanitycheck.rb",
     "lib/wurfl/handset.rb",
     "lib/wurfl/loader.rb",
     "lib/wurfl/uaproftowurfl.rb",
     "lib/wurfl/utils.rb",
     "test/data/wurfl.simple.xml",
     "test/handset_test.rb",
     "test/loader_test.rb",
     "wurfl.gemspec"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/pwim/wurfl}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Library and tools for manipulating the WURFL}
  s.test_files = [
    "test/loader_test.rb",
     "test/handset_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
