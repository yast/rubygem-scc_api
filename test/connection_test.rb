#!/usr/bin/env rspec

require_relative "spec_helper"

require "scc_api/connection"

describe SccApi::Connection do
  before(:each) do
    @success = Net::HTTPSuccess.new("1.1", 200, "OK")
    @success.content_type = "application/json; charset=utf-8"

    @redirection = Net::HTTPRedirection.new("1.1", 302, "Found")
    @redirection["location"] = "http://redirected.com"

    @connection = SccApi::Connection.new("email", "reg_code")
    @connection.url = "http://example.com/connection"

    SccApi::HwDetection.stub(:collect_hw_data).and_return({"sockets" => 1, "graphics" => "unknown"})
  end

  describe ".announce" do
    it "registers the system" do
      @success.stub(:body).and_return('{"login":"SCC_3b336b", "password":"24f057"}')

      Net::HTTP.any_instance.should_receive(:request)
        .with(an_instance_of(Net::HTTP::Post)).and_return(@success)

      result = @connection.announce()

      expect(result.username).to eq("SCC_3b336b")
      expect(result.password).to eq("24f057")
    end

    it "handles HTTP redirection" do
      @success.stub(:body).and_return('{"login":"SCC_3b336b", "password":"24f057"}')

      http = double()
      Net::HTTP.stub(:new).and_return(http)
      http.should_receive(:request).exactly(2).times.and_return(@redirection, @success)

      result = @connection.announce()

      expect(result.username).to eq("SCC_3b336b")
      expect(result.password).to eq("24f057")
    end

    it "limits the numer of redirections" do
      http = double()
      Net::HTTP.stub(:new).and_return(http)
      http.stub(:request).and_return(@redirection)

      expect {@connection.announce}.to raise_error(RuntimeError)
    end


    it "uses SSL for HTTPS URL" do
      @success.stub(:body).and_return('{"login":"SCC_3b336b", "password":"24f057"}')

      Net::HTTP.any_instance.should_receive(:request)
        .with(an_instance_of(Net::HTTP::Post)).and_return(@success)
      Net::HTTP.any_instance.should_receive(:use_ssl=).with(true)
      Net::HTTP.any_instance.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_PEER)

      @connection.url = "https://example.com"
      @connection.announce()
    end

    it "SSL verification can be disabled by SccApi::Connection.insecure=true" do
      @success.stub(:body).and_return('{"login":"SCC_3b336b", "password":"24f057"}')

      Net::HTTP.any_instance.should_receive(:request)
        .with(an_instance_of(Net::HTTP::Post)).and_return(@success)
      Net::HTTP.any_instance.should_receive(:use_ssl=).with(true)
      Net::HTTP.any_instance.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)

      @connection.url = "https://example.com"
      @connection.insecure = true
      @connection.announce()
    end

    it "raises exception on HTTP error" do
      response = Net::HTTPClientError.new("1.1", 422, "Error")

      Net::HTTP.any_instance.should_receive(:request)
        .with(an_instance_of(Net::HTTP::Post)).and_return(response)

      connection = SccApi::Connection.new("email", "reg_code")
      expect{ connection.announce() }.to raise_error
    end

    it "raises exception on unsupported Content-Type" do
      response = Net::HTTPSuccess.new("1.1", 200, "OK")
      response.content_type = "application/xml"

      Net::HTTP.any_instance.should_receive(:request)
        .with(an_instance_of(Net::HTTP::Post)).and_return(response)

      connection = SccApi::Connection.new("email", "reg_code")
      expect{ connection.announce() }.to raise_error
    end
  end

  describe ".register" do
    it "registers a product" do
      @success.stub(:body).and_return('{"sources":{"SUSE_Linux_Enterprise_Server":
         "http://localhost:3000/service?credentials=SUSE_Linux_Enterprise_Server"},
         "norefresh":["SLES12-Extension-Store"],"enabled": ["SLES12-Pool"]}')


      Net::HTTP.any_instance.should_receive(:request)
        .with(an_instance_of(Net::HTTP::Post)).and_return(@success)

      product = {"name" => "SUSE_SLES", "arch" => "x86_64", "version" => "12"}
      result = @connection.register(product)

      expect(result.services.first.name).to eq("SUSE_Linux_Enterprise_Server")
      expect(result.services.first.url).to eq(URI("http://localhost:3000/service?credentials=SUSE_Linux_Enterprise_Server"))
      expect(result.norefresh_repos).to eq(["SLES12-Extension-Store"])
      expect(result.enabled_repos).to eq(["SLES12-Pool"])
    end

  end
end

