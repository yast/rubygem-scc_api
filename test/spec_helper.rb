
# this needs to be at the very top of the file!!
begin
  require 'simplecov'
  # ignore coverage in tests
  SimpleCov.add_filter "/test/"
  SimpleCov.start
rescue LoadError
  $stderr.puts "Code coverage disabled: simplecov gem not installed"
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

def fixtures_dir
  File.expand_path("../fixtures", __FILE__)
end
