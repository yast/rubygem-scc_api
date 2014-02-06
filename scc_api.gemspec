Gem::Specification.new do |s|
  s.name = "scc_api"
  s.version = File.read("VERSION").chomp
  s.summary = "Library for accessing SUSE Customer Center API"
  s.description = "This rubygem provides easy access to the SUSE Customer Center API."
  s.files = [
    "Gemfile",
    "README.md",
    "README-for-developers.md",
    "Rakefile",
    "VERSION",
    "LICENSE",
    "scc_api.gemspec",
    ] + Dir["lib/**/*"]
  s.test_files = Dir["test/**/*"]
  s.require_path = 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md", "README-for-developers.md"]
  s.rdoc_options = ['--line-numbers', "--main", "README"]
  s.authors = ["Ladislav Slezak"]
  s.email = "lslezak@suse.cz"
  s.homepage = "http://github.com/yast/rubygem-scc_api"
  s.licenses = ["LGPL-2.1"]
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = ">= 2.0.0"
  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "rspec"
  s.add_development_dependency "packaging_rake_tasks"
end
