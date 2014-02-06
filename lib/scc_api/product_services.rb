# encoding: utf-8

require "uri"

module SccApi

  # Collection of repository services relevant to a registered product
  class ProductServices

    attr_reader :services, :norefresh_repos, :enabled_repos

    # constructor
    # @param services [Array<Service>] services for the product
    # @param norefresh_repos [Array<String>] list of resitories which have
    #  autorefresh enabled by default
    # @param enabled_repos [Array<String>] list of resitories which
    #  are enabled by default
    # @return ProductServices services returned by registration
    def initialize(services, norefresh_repos = [], enabled_repos = [])
      @services = services
      @norefresh_repos = norefresh_repos
      @enabled_repos = enabled_repos
    end
    
    # create ProductServices from a SCC response
    # @param [Hash] response from SCC server (parsed JSON)
    def self.from_hash(param)
      norefresh = param["norefresh"] || []
      enabled = param["enabled"] || []
      sources = param["sources"] || {}

      services = sources.map do |name, url|
        Service.new(name, url)
      end
      
      ProductServices.new(services, norefresh, enabled)
    end
  end

  # Repository service
  class Service

    attr_reader :name, :url

    # Constructor
    # @param name [String] service name
    # @param url [URI, String] service URL
    def initialize(name, url)
      @name = name
      @url = url.is_a?(String) ? URI(url) : url
    end
  end
end
