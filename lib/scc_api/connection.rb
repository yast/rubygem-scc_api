# encoding: utf-8

require "scc_api/hw_detection"
require "scc_api/credentials"
require "scc_api/logger"

require "json"

# network related libs
require "uri"
require "net/http"
require "socket"

module SccApi

  # TODO FIXME: add Yardoc comments
  class Connection
    include Logger

    attr_accessor :url, :email, :reg_code, :insecure, :credentials

    # FIXME: internal testing SCC instance, change to the public production server later
    DEFAULT_SCC_URL = "http://10.122.166.25:3000/connect"

    MAX_REDIRECTS = 10

    JSON_HTTP_HEADER = {
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }

    def initialize(email, reg_code)
      self.url = DEFAULT_SCC_URL
      self.insecure = false
      self.email = email
      self.reg_code = reg_code
    end

    # initial registration via API
    def announce
      body = {
        "email" => email,
        "hostname" => Socket.gethostname,
        "hwinfo" => {
          # TODO FIXME: check the expected structure
          "sockets" => SccApi::HwDetection.cpu_sockets,
          # TODO FIXME: the API supports only a single vendor, change it to list?
          "graphics" => SccApi::HwDetection.graphics_card_vendors.first
        }
      }.to_json

      log.info("Sending announce data: #{body}")

      # see https://github.com/SUSE/happy-customer/wiki/Connect-API#wiki-sys_create
      # TODO FIXME: set "Accept-Language" HTTP header to set the language
      # used for error messages

      params = {
        :url => URI(url + "/announce"),
        :headers => {"Authorization" => "Token token=\"#{reg_code}\""},
        :body => body,
        :method => :post
      }

      result = json_http_handler(params)

      self.credentials = SccApi::Credentials.new(result["login"], result["password"])
    end

    def register(base_product)
      body = {
        "token" => reg_code,
        "product_ident" => base_product["name"],
        "product_version" => base_product["version"],
        "arch" => base_product["arch"]
      }.to_json

      params = {
        :url => URI(url + "/activate"),
        :body => body,
        :method => :post,
        :credentials => credentials
      }

      json_http_handler(params)
    end

    private

    # generic HTTP(S) transfer for JSON requests/responses
    # TODO: proxy support? (http://apidock.com/ruby/Net/HTTP)
    def json_http_handler(params, redirect_count = MAX_REDIRECTS)
      raise "Reached maximum number of HTTP redirects, aborting" if redirect_count == 0

      target_url = params[:url]
      raise "URL parameter missing" unless target_url

      http = create_http_connection(target_url)
      request = create_request(params[:method] || :get, target_url)

      JSON_HTTP_HEADER.merge(params[:headers] || {}).each {|k,v| request[k] = v}
      request.body = params[:body] || ""

      # use Basic Auth if credentials are present
      if params[:credentials]
        request.basic_auth(params[:credentials].username, params[:credentials].password)
      end

      response = http.request(request)

      case response
      when Net::HTTPSuccess then
        # FIXME: better test the type, this looks fragile...
        if response["content-type"] == "application/json; charset=utf-8"
          log.info("Request succeeded")
          return JSON.parse(response.body)
        else
          raise RuntimeError, "Unexpected content-type: #{response['content-type']}"
        end
      when Net::HTTPRedirection then
        location = response['location']
        params[:url] = URI(location)
        log.info("Redirected to #{location}")

        # retry recursively
        json_http_handler(params, redirect_count - 1)
      else
        # TODO error handling
        log.error("HTTP Error: #{response.inspect}")
        raise "HTTP failed: #{response.code}: #{response.message}"
      end
    end

    def create_http_connection(url)
      http = Net::HTTP.new(url.host, url.port)

      # switch to HTTPS connection
      if url.is_a? URI::HTTPS
        http.use_ssl = true
        http.verify_mode = insecure ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
        log.warn("Warning: SSL certificate verification disabled") if insecure
      else
        log.warn("Warning: Using insecure \"#{url.scheme}\" transfer protocol")
      end

      return http
    end

    def create_request(method, url)
      case method
      when :post then
        Net::HTTP::Post.new(url.request_uri)
      when :put then
        Net::HTTP::Put.new(url.request_uri)
      when :get then
        Net::HTTP::Get.new(url.request_uri)
      else
        raise "Unsupported HTTP method: #{method}"
      end
    end

  end
end
