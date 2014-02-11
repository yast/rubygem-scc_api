#!/usr/bin/env rspec

require_relative "spec_helper"

require "scc_api/credentials"
require "tmpdir"

describe SccApi::Credentials do
  describe ".read" do
    it "creates Credentials object from a credentials file" do
      file = File.join(fixtures_dir, "SUSE_SLES_credentials")
      credentials = SccApi::Credentials.read(file)
      expect(credentials.username).to eq "SUSE_SLES_f93f438773944ef087a30a37af7fc0a5"
      expect(credentials.password).to eq "231982b59ce961e38777c83685a5c42f"
      expect(credentials.service).to eq "SUSE_SLES"
      expect(credentials.file).to eq file
    end

    it "raises an error when the file does not exist" do
      expect{SccApi::Credentials.read("this_file_does_not_exist")}.to raise_error
    end
  end

  describe "#write" do
    it "creates a credentials file accessible only by user" do
      credentials = SccApi::Credentials.new("name", "1234", :service => "SLES")
      original_file = credentials.file

      # use a tmpdir for writing the file
      Dir.mktmpdir do |dir|
        expect {credentials.write(dir)}.not_to raise_error

        # before saving the file path is not set
        expect(original_file).to be_nil
        # the file is not empty
        expect(File.size(credentials.file)).to be > 0
        # standard file with "rw-------" permissions
        expect(File.stat(credentials.file).mode).to eq 0100600
      end
    end

    it "raises an error when service name neither file name is set" do
      credentials = SccApi::Credentials.new("name", "1234")
      expect {credentials.write()}.to raise_error
    end

    it "the written file can be read back" do
      credentials = SccApi::Credentials.new("name", "1234", :service => "SLES")

      # use a tmpdir for writing the file
      Dir.mktmpdir do |dir|
        credentials.write(dir)
        read_credentials = SccApi::Credentials.read(credentials.file)

        # the read credentials are exactly the same as written
        expect(read_credentials.username).to eq credentials.username
        expect(read_credentials.password).to eq credentials.password
        expect(read_credentials.service).to eq credentials.service
      end
    end
  end

  describe "#to_s" do
    it "does not serialize password (to avoid logging it)" do
      user = "USER"
      service = "SERVICE"
      password = "*eiW0yie2*"
      credentials_str = SccApi::Credentials.new(user, password, :service => service).to_s
      expect(credentials_str).not_to include(password), "The password is logged"
      expect(credentials_str).to include(user)
      expect(credentials_str).to include(service)
    end
  end

end
