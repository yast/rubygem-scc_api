#!/usr/bin/env rspec

require_relative "spec_helper"

require "scc_api/http_request"
require "scc_api/credentials"

describe SccApi::AnnounceRequest do
  describe ".new" do
    before do
      @hw_data = {"sockets" => 1, "graphics" => "foo"}
      @hostname = "mock"
      SccApi::HwDetection.should_receive(:collect_hw_data).and_return(@hw_data)
      Socket.should_receive(:gethostname).and_return(@hostname)
    end

    it "collects hardware data in body" do
      url = "https://example.com/connect"
      request = SccApi::AnnounceRequest.new(url, "email", "reg_code")
      expect(request.body).to eq({
          "email" => "email",
          "hostname" => @hostname,
          "hwinfo" => @hw_data
        })
      expect(request.url.to_s).to start_with(url)
      expect(request.headers).to include("Authorization")
      expect(request.create_request.fetch("Authorization")).to start_with("Token ")
    end
  end
end

describe SccApi::RegisterRequest do
  describe ".new" do
    it "sends product data and registration code in body" do
      url = "https://example.com/connect"
      product = {"name" => "SUSE_SLES", "arch" => "x86_64", "version" => "12"}
      credentials = SccApi::Credentials.new("user", "password")
      regcode = "reg_code"

      request = SccApi::RegisterRequest.new(url, regcode, product, credentials)
      expect(request.body).to eq({
          "product_ident" => product["name"],
          "product_version" => product["version"],
          "arch" => product["arch"],
          "token" => regcode
        })
      expect(request.credentials).to be(credentials)
      expect(request.url.to_s).to start_with(url)
      expect(request.create_request.fetch("Authorization")).to start_with("Basic ")
    end
  end
end

describe SccApi::HttpRequest do
  before do
    @url = URI("https://example.com/connect")
  end

  describe "#create_request" do
    it "creates GET request by default" do
      request = SccApi::HttpRequest.new(@url)
      expect(request.create_request).to be_a Net::HTTP::Get
    end

    it "supports GET request" do
      request = SccApi::HttpRequest.new(@url, method: :get)
      expect(request.create_request).to be_a Net::HTTP::Get
    end

    it "supports POST request" do
      request = SccApi::HttpRequest.new(@url, method: :post)
      expect(request.create_request).to be_a Net::HTTP::Post
    end

    it "supports PUT request" do
      request = SccApi::HttpRequest.new(@url, method: :put)
      expect(request.create_request).to be_a Net::HTTP::Put
    end

    it "supports HEAD request" do
      request = SccApi::HttpRequest.new(@url, method: :head)
      expect(request.create_request).to be_a Net::HTTP::Head
    end

    it "raises exception if unknown method is requested" do
      request = SccApi::HttpRequest.new(@url, method: :foo)
      expect {request.create_request}.to raise_error(RuntimeError)
    end

    it "sends body as JSON" do
      body = { "a" => 1, "b" => 2}
      request = SccApi::HttpRequest.new(@url, body: body)
      http_request = request.create_request

      expect(http_request.content_type).to eq("application/json")
      expect(http_request.body).to eq(body.to_json)
    end
  end

end

