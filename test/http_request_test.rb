#!/usr/bin/env rspec

require_relative "spec_helper"

require "scc_api/http_request"
require "scc_api/connection"

describe SccApi::AnnounceRequest do
  describe ".new" do
    before do
      @hw_data = {"sockets" => 1, "graphics" => "foo"}
      @hostname = "mock"
      @connection = SccApi::Connection.new("email", "reg_code")
      SccApi::HwDetection.should_receive(:collect_hw_data).and_return(@hw_data)
      Socket.should_receive(:gethostname).and_return(@hostname)
    end

    it "collects hardware data in body" do
      request = SccApi::AnnounceRequest.new(@connection)
      expect(request.body).to eq({
          "email" => "email",
          "hostname" => @hostname,
          "hwinfo" => @hw_data
        })
      expect(request.headers).to include("Authorization")
      expect(request.create_request.fetch("Authorization")).to start_with("Token ")
    end
  end
end

describe SccApi::RegisterRequest do
  before do
    @connection = SccApi::Connection.new("email", "reg_code")
  end

  describe ".new" do
    it "sends product data and registration code in body" do
      product = {"name" => "SUSE_SLES", "arch" => "x86_64", "version" => "12"}
      @connection.credentials = SccApi::Credentials.new("user", "password", product["name"])

      request = SccApi::RegisterRequest.new(@connection, product)
      expect(request.body).to eq({
          "product_ident" => product["name"],
          "product_version" => product["version"],
          "arch" => product["arch"],
          "token" => "reg_code"
        })
      expect(request.create_request.fetch("Authorization")).to start_with("Basic ")
    end
  end
end

describe SccApi::HttpRequest do
  before do
    @url = URI("https://example.com/connect")
    @connection = SccApi::Connection.new("email", "reg_code")
  end

  describe "#create_request" do
    it "creates GET request by default" do
      request = SccApi::HttpRequest.new(@url, @connection)
      expect(request.create_request).to be_a Net::HTTP::Get
    end

    it "supports GET request" do
      request = SccApi::HttpRequest.new(@url, @connection, method: :get)
      expect(request.create_request).to be_a Net::HTTP::Get
    end

    it "supports POST request" do
      request = SccApi::HttpRequest.new(@url, @connection, method: :post)
      expect(request.create_request).to be_a Net::HTTP::Post
    end

    it "supports PUT request" do
      request = SccApi::HttpRequest.new(@url, @connection, method: :put)
      expect(request.create_request).to be_a Net::HTTP::Put
    end

    it "supports HEAD request" do
      request = SccApi::HttpRequest.new(@url, @connection, method: :head)
      expect(request.create_request).to be_a Net::HTTP::Head
    end

    it "raises exception if unknown method is requested" do
      request = SccApi::HttpRequest.new(@url, @connection, method: :foo)
      expect {request.create_request}.to raise_error(RuntimeError)
    end

    it "sends body as JSON" do
      body = { "a" => 1, "b" => 2}
      request = SccApi::HttpRequest.new(@url, @connection, body: body)
      http_request = request.create_request

      expect(http_request.content_type).to eq("application/json")
      expect(http_request.body).to eq(body.to_json)
    end

    it "does not send Accept-Language header if a language is not set" do
      request = SccApi::HttpRequest.new(@url, @connection)
      expect(request.create_request["Accept-Language"]).to be_nil
    end

    it "sends Accept-Language header if a language is set" do
      @connection.language = "cs-CZ"
      request = SccApi::HttpRequest.new(@url, @connection)
      expect(request.create_request.fetch("Accept-Language")).to eq("cs-CZ")
    end

  end

end

