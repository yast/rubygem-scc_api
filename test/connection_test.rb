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

  shared_examples "connection error handler" do |method, *args|
    it "raises SccApi::ErrorResponse on when SCC report 422 error" do
      response = Net::HTTPUnprocessableEntity.new("1.1", 422, "Error")
      response.stub(:body).and_return("TODO") #TODO add json example response here

      Net::HTTP.any_instance.should_receive(:request)
        .with(an_instance_of(Net::HTTP::Post)).and_return(response)

      connection = SccApi::Connection.new("email", "reg_code")
      expect{ connection.send(method, *args) }.to raise_error(SccApi::ErrorResponse)
    end

    it "raises SccApi::NotAuthorized when scc return 401" do
      response = Net::HTTPUnauthorized.new("1.1", 401, "Error")

      Net::HTTP.any_instance.should_receive(:request)
        .with(an_instance_of(Net::HTTP::Post)).and_return(response)

      connection = SccApi::Connection.new("email", "reg_code")
      expect{ connection.send(method, *args) }.to raise_error(SccApi::NotAuthorized)
    end

    it "raises SccApi::NoNetworkError when there is no network connection" do

      Net::HTTP.any_instance.should_receive(:request)
        .with(an_instance_of(Net::HTTP::Post)).and_raise(SocketError)

      connection = SccApi::Connection.new("email", "reg_code")
      expect{ connection.send(method, *args) }.to raise_error(SccApi::NoNetworkError)
    end


    it "raises RuntimeError on unsupported Content-Type" do
      response = Net::HTTPSuccess.new("1.1", 200, "OK")
      response.content_type = "application/xml"

      Net::HTTP.any_instance.should_receive(:request)
        .with(an_instance_of(Net::HTTP::Post)).and_return(response)

      connection = SccApi::Connection.new("email", "reg_code")
      expect{ connection.send(method, *args) }.to raise_error(RuntimeError)
    end
  end

  shared_examples "SSL connection supporter" do |method, *args|
    it "uses SSL for HTTPS URL" do
      @success.stub(:body).and_return('{"login":"SCC_3b336b", "password":"24f057"}')

      Net::HTTP.any_instance.should_receive(:request)
        .with(an_instance_of(Net::HTTP::Post)).and_return(@success)
      Net::HTTP.any_instance.should_receive(:use_ssl=).with(true)
      Net::HTTP.any_instance.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_PEER)

      @connection.url = "https://example.com"
      @connection.send(method, *args)
    end

    it "SSL verification can be disabled by SccApi::Connection.insecure=true" do
      @success.stub(:body).and_return('{"login":"SCC_3b336b", "password":"24f057"}')

      Net::HTTP.any_instance.should_receive(:request)
        .with(an_instance_of(Net::HTTP::Post)).and_return(@success)
      Net::HTTP.any_instance.should_receive(:use_ssl=).with(true)
      Net::HTTP.any_instance.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)

      @connection.url = "https://example.com"
      @connection.insecure = true
      @connection.send(method, *args)
    end
  end

  shared_examples "redirection handler" do |method, *args|
    it "handles HTTP redirection" do
      @success.stub(:body).and_return('{}') #FIXME maybe it fail in future if we check content

      http = double()
      Net::HTTP.stub(:new).and_return(http)
      http.should_receive(:request).twice.and_return(@redirection, @success)

      @connection.send(method, *args)
    end

    it "raises RuntimeError if number of redirections exceed limit" do
      http = double()
      Net::HTTP.stub(:new).and_return(http)
      http.stub(:request).and_return(@redirection)

      expect {@connection.send(method, *args)}.to raise_error(RuntimeError)
    end
  end

  describe ".announce" do
    it_should_behave_like "connection error handler", :announce
    it_should_behave_like "SSL connection supporter", :announce
    it_should_behave_like "redirection handler",      :announce

    it "registers the system" do
      @success.stub(:body).and_return('{"login":"SCC_3b336b", "password":"24f057"}')

      Net::HTTP.any_instance.should_receive(:request)
        .with(an_instance_of(Net::HTTP::Post)).and_return(@success)

      result = @connection.announce()

      expect(result.username).to eq("SCC_3b336b")
      expect(result.password).to eq("24f057")
    end
  end

  describe ".register" do
    PRODUCT = {
      "name" => "SLES",
      "arch" => "x86_64",
      "version" => "12-1.17"
    }

    it_should_behave_like "connection error handler", :register, PRODUCT
    it_should_behave_like "SSL connection supporter", :register, PRODUCT
    it_should_behave_like "redirection handler",      :register, PRODUCT

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

