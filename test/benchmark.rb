$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require 'wurfl/loader'
require 'benchmark'

if $0 == __FILE__
  loader = Wurfl::Loader.new
  r = Benchmark.measure do
    loader.load_wurfl(File.join(File.dirname(__FILE__), "data", "wurfl.large.xml"))
  end
  puts r
end
