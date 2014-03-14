module SccApi
  class ProductExtensions
    attr_reader :extensions

    def initialize(extensions)
      @extensions = extensions
    end

    # create ProductExtensions from a SCC response
    # @param [Hash] response from SCC server (parsed JSON)
    def self.from_hash(extensions_response)
      extensions = extensions_response.each do |extension|
        # We do not currently have long_name or description in the SCC response
        Extension.new(extension['name'], '', '', extension['zypper_name'])
      end

      ProductExtensions.new(extensions)
    end
  end

  # Repository service
  class Extension

    attr_reader :short_name, :long_name, :description, :product_ident

    # Constructor
    def initialize(short_name, long_name, description, product_ident)
      @short_name = short_name
      @long_name = long_name
      @description = description
      @product_ident = product_ident
    end
  end
end
