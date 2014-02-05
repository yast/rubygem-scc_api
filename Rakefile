require "rake"

require "packaging/configuration"
require "packaging/tasks"
# skip license check, specific "package" is defined here
Packaging::Tasks.load_tasks(:exclude => ["check_license.rake", "tarball.rake", "package.rake"])

Packaging.configuration do |conf|
  conf.obs_api = "https://api.suse.de"
  conf.obs_project = "Devel:YaST:Head"
  conf.package_name = "rubygem-scc_api"
  conf.obs_target = "SLE-12"
  conf.obs_sr_project = "SUSE:SLE-12:GA"
end

begin
  require "bundler"
  Bundler::GemHelper.install_tasks
  # we have our own "build" task, remove the task from bundler
  Rake::Task["build"].clear
rescue LoadError
  puts "Bundler not available, install it with 'gem install bundler' command" if verbose == true
end

begin
  require "rspec/core/rake_task"

  desc "Run tests"
  RSpec::Core::RakeTask.new("test") do |t|
    t.pattern = "test/**/*{_test,_spec}.rb"
  end
rescue LoadError
  puts "RSpec not available, install it with 'gem install rspec' command" if verbose == true
end

begin
  require "yard"
  YARD::Rake::YardocTask.new
rescue LoadError
  puts "Yard not available, install it with 'gem install yard' command" if verbose == true
end

task :default => :test

desc "Create package directory containing all things to build RPM"
task :package => ["check:syntax", "check:committed", :build] do
  config = Packaging::Configuration.instance
  pkg_name = config.package_name
  version = config.version
  include FileUtils::Verbose
  rm_rf "package"
  mkdir "package"
  cp "#{pkg_name}.changes", "package/"
  cp "#{pkg_name}.spec.template", "package/#{pkg_name}.spec"
  sh "cp scc_api-#{version}.gem package/"
  sh "sed -i \"s:<VERSION>:#{version}:\" package/#{pkg_name}.spec"
end

# build the gem using "gem" command
# "build" task from bundler might not be available
desc "Build scc_api-#{Packaging::Configuration.instance.version}.gem file"
task :build do
  include FileUtils::Verbose
  sh "gem build scc_api.gemspec"
end
