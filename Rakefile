require "rake"
require "rspec/core/rake_task"
require "bundler"

Bundler::GemHelper.install_tasks

desc "Run tests"
RSpec::Core::RakeTask.new("test") do |t|
  t.pattern ="test/**/*.rb"
end

begin
  require "yard"
  YARD::Rake::YardocTask.new do |t|
    t.files   = ["lib/**/*.rb"]
    t.options = []
  end
rescue LoadError
  puts "Yard not available, install it with 'gem install yard' command"
end

task :default => :test

desc "Create package directory containing all things to build RPM"
task :package => [:build] do
  pkg_name = "rubygem-scc_api"
  include FileUtils::Verbose
  rm_rf "package"
  mkdir "package"
  cp "#{pkg_name}.changes","package/"
  cp "#{pkg_name}.spec.template","package/#{pkg_name}.spec"
  sh 'cp pkg/*.gem package/'
  sh "sed -i \"s:<VERSION>:`cat VERSION`:\" package/#{pkg_name}.spec"
end
