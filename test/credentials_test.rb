#!/usr/bin/env rspec

require_relative "spec_helper"

require "scc_api/credentials"

describe SccApi::Credentials do
  describe ".read" do
    it "creates Credentials object from a credentials file" do
      credentials = SccApi::Credentials.read(File.join(fixtures_dir, "SUSE_SLES_credentials"))
      expect(credentials.username).to eq "SUSE_SLES_f93f438773944ef087a30a37af7fc0a5"
      expect(credentials.password).to eq "231982b59ce961e38777c83685a5c42f"
      expect(credentials.service).to eq "SUSE_SLES"
    end

    it "raises an error when the file does not exist" do
      expect{SccApi::Credentials.read("this_file_does_not_exist")}.to raise_error
    end
  end

  describe "#write" do
    it "creates a credentials file accessible only by user" do
      begin
        file = "SLES_credentials"
        credentials = SccApi::Credentials.new("name", "1234", "SLES")
        expect {credentials.write(".")}.not_to raise_error

        # the file is not empty
        expect(File.size(file) > 0).to eq true
        # standard file with "rw-------" permissions
        expect(File.stat(file).mode).to eq 0100600
      ensure
        File.delete(file) if File.exist?(file)
      end
    end

    it "the written file can be read back" do
      begin
        file = "SLES_credentials"
        credentials = SccApi::Credentials.new("name", "1234", "SLES")
        credentials.write(".")

        read_credentials = SccApi::Credentials.read(file)
        # the read credentials are exactly the same as written
        expect(read_credentials.username).to eq credentials.username
        expect(read_credentials.password).to eq credentials.password
        expect(read_credentials.service).to eq credentials.service
      ensure
        File.delete(file) if File.exist?(file)
      end
    end
  end

  describe "#to_s" do
    it "does not serialize password (to avoid logging it)" do
      password = "*eiW0yie2*"
      credentials = SccApi::Credentials.new("user", password, "service")
      expect(credentials.to_s).not_to include(password), "The password is logged"
    end
  end

end
