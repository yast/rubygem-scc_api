# encoding: utf-8

require "scc_api/credentials"
require "scc_api/exceptions"
require "scc_api/http_request"
require "scc_api/logger"
require "scc_api/product_services"

require "json"

# network related libs
require "uri"
require "net/http"
require "openssl"

module SccApi

  # TODO FIXME: add Yardoc comments
  class Connection
    include Logger

    # @see http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.4 for expected
    # language value
    attr_accessor :url, :email, :reg_code, :insecure, :credentials, :language

    # default URL used for registration
    DEFAULT_SCC_URL = "https://scc.suse.com/connect"

    MAX_REDIRECTS = 10

    def initialize(email, reg_code)
      self.url = DEFAULT_SCC_URL
      self.insecure = false
      self.email = email
      self.reg_code = reg_code
    end

    # initial registration via API
    def announce
      request = AnnounceRequest.new(self)
      result = json_http_handler(request)

      # the global credentials returned by announce should be saved
      # to /etc/zypp/credentials.d/SCCCredentials file
      self.credentials = Credentials.new(result["login"], result["password"],
        Credentials::DEFAULT_CREDENTIALS_DIR + "/SCCCredentials")
    end

    # Register the product and get the services assigned to it
    # @return [ProductServices] registered product services
    def register(product)
      request = RegisterRequest.new(self, product)
      services = json_http_handler(request)
      log.info "Registered services: #{services}"

      return ProductServices.from_hash(services)
    end

    # Get the extensions for the product
    # @return [ProductExtensions] extensions available for product
    def extensions_for(product)
      request = ExtensionsRequest.new(self, product)
      extensions = json_http_handler(request)
      log.info "Got extensions: #{extensions}"

      return ProductExtensions.from_hash(extensions)
    end

    private

    # generic HTTP(S) transfer for JSON requests/responses
    # TODO: proxy support? (http://apidock.com/ruby/Net/HTTP)
    def json_http_handler(request, redirect_count = MAX_REDIRECTS)
      raise SccApi::RedirectionLimit if redirect_count == 0

      http = create_http_connection(request.url)
      # send the HTTP request
      response = http.request(request.create_request)

      case response
      when Net::HTTPSuccess then
        # .content_type removes the optional attribues
        # e.g. "application/json; charset=utf-8" => "application/json"
        if response.content_type == "application/json"
          log.info("Request succeeded")
          return JSON.parse(response.body)
        else
          raise "Unexpected content-type: #{response.content_type}"
        end
      when Net::HTTPRedirection then
        location = response['location']
        log.info("Redirected to #{location}")

        # retry recursively with redirected URL
        request.url = URI(location)
        json_http_handler(request, redirect_count - 1)
      when Net::HTTPUnauthorized then
        raise SccApi::NotAuthorized
      # 422 use SCC to report errors with registration
      when Net::HTTPUnprocessableEntity then
        log.error("SCC returns 422")
        log.info("Response body: #{response.body}")
        raise SccApi::ErrorResponse.new(response)
      else
        log.error("HTTP Error: #{response.inspect}")
        log.info("Response body: #{response.body}")
        raise SccApi::HttpError.new(response)
      end
    #raise nice exception if there is no network connection
    rescue SocketError
      raise SccApi::NoNetworkError
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

  end
end
