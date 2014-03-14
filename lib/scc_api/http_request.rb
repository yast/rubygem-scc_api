# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require "socket"
require "uri"
require "net/http"
require "json"

require "scc_api/hw_detection"
require "scc_api/logger"


module SccApi

  # Base class for SCC HTTP requests
  # Keeps all data to avoid recreating requests from scratch after redirection
  class HttpRequest
    include Logger
    
    JSON_HTTP_HEADER = {
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    }

    attr_reader :headers, :body, :method, :connection
    # URL can be changed during redirection
    attr_accessor :url

    def initialize(url, connection, headers: {}, body: nil, method: :get)
      @url = url
      @connection = connection
      @headers = headers
      @body = body
      @method = method
    end

    # create Net::HTTP::* request object for real HTTP communication
    # @return [Net::HTTP::Request] HTTP request object
    def create_request
      request = http_request(url, method)
      JSON_HTTP_HEADER.merge(headers).each {|k,v| request[k] = v}
      request["Accept-Language"] = connection.language if connection.language
      request.body = body.to_json if body
      request.basic_auth(connection.credentials.username, connection.credentials.password) if connection.credentials
      
      return request
    end
 
    private

    def http_request(url, method)
      request_class = case method
      when :post then Net::HTTP::Post
      when :put  then Net::HTTP::Put
      when :get  then Net::HTTP::Get
      when :head then Net::HTTP::Head
      else
        raise "Unsupported HTTP method: #{method}"
      end

      request_class.new(url.request_uri)
    end

  end

  # System announcement request
  # @see https://github.com/SUSE/happy-customer/wiki/Connect-API#wiki-announce-system
  class AnnounceRequest < HttpRequest
    URL_PATH = "/subscriptions/systems"

    def initialize(connection)
      target_url = URI(connection.url + URL_PATH)

      body = {
        "email" => connection.email,
        "hostname" => Socket.gethostname,
        "hwinfo" => HwDetection.collect_hw_data
      }
      log.info("Announce data: #{body}")
    
      # set headers
      headers = {"Authorization" => "Token token=\"#{connection.reg_code}\""}
      
      super(target_url, connection, headers: headers, body: body, method: :post)
    end
  end

  # Request for registering a product
  # @see https://github.com/SUSE/happy-customer/wiki/Connect-API#wiki-activate-product
  class RegisterRequest < HttpRequest
    URL_PATH = "/systems/products"

    def initialize(connection, product)
      target_url = URI(connection.url + URL_PATH)
      
      body = {
        "product_ident" => product["name"],
        "product_version" => product["version"],
        "arch" => product["arch"]
      }

      # do not log the registration code
      log.info("Registration data: #{body}")
      body["token"] = connection.reg_code

      super(target_url, connection, body: body, method: :post)
    end
  end

# Request obtaining the list of extensions for the given product
# @see https://github.com/SUSE/connect/wiki/SCC-API-(Implemented)#prod_list
  class ExtensionsRequest < HttpRequest
    URL_PATH = "/systems/products"

    def initialize(connection, product)
      target_url = URI(connection.url + URL_PATH)

      body = {
          "product_ident" => product["name"]
      }

      # do not log the registration code
      log.info("GET /systems/products data: #{body}")

      super(target_url, connection, body: body, method: :get)
    end
  end
end
