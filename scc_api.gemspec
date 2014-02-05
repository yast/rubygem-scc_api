Gem::Specification.new do |s|
  s.name = "scc_api"
  s.version = File.read("VERSION").chomp
  s.summary = "Library for accessing SUSE Customer Center API"
  s.description = "This rubygem provides easy access to the SUSE Customer Center API."
  s.files = [
    "Gemfile",
    "README.md",
    "Rakefile",
    "VERSION",
    "lib/scc_api.rb",
    "lib/scc_api/connection.rb",
    "lib/scc_api/credentials.rb",
    "lib/scc_api/hw_detection.rb",
    "lib/scc_api/logger.rb",
    "scc_api.gemspec",
    ]
  s.test_files = [
    "test/fixtures/lscpu_1_socket.out",
    "test/fixtures/lspci_intel_gfx.out",
    "test/fixtures/lspci_no_gfx.out",
    "test/fixtures/SUSE_SLES_credentials",
    "test/spec_helper.rb",
    "test/hw_detection_test.rb",
    "test/scc_test.rb",
    "test/credentials_test.rb",
  ]
  s.require_path = 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.md"]
  s.rdoc_options = ['--line-numbers', "--main", "README"]
  s.authors = ["Ladislav Slezak"]
  s.email = "lslezak@suse.cz"
  s.homepage = "http://github.com/yast/rubygem-scc_api"
  s.licenses = ["GPL-2.0", "Ruby"]
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = ">= 2.0.0"
  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "rspec"
  s.add_development_dependency "packaging_rake_tasks"
end
