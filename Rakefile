require "rake"
require "rspec/core/rake_task"
require "bundler"

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
task :package => ["check:syntax", "check:committed", :test, :build] do
  pkg_name = "rubygem-scc_api"
  include FileUtils::Verbose
  rm_rf "package"
  mkdir "package"
  cp "#{pkg_name}.changes","package/"
  cp "#{pkg_name}.spec.template","package/#{pkg_name}.spec"
  sh 'cp pkg/*.gem package/'
  sh "sed -i \"s:<VERSION>:`cat VERSION`:\" package/#{pkg_name}.spec"
end
