module SccApi
  class ProductExtensions
    attr_reader :extensions

    def initialize(extensions)
      @extensions = extensions
    end

    # create ProductExtensions from a SCC response
    # @param [Hash] response from SCC server (parsed JSON)
    def self.from_hash(extensions_response)
      extensions = extensions_response.map do |extension|
        # We do not currently have long_name or description in the SCC response
        Extension.new(extension["zypper_name"], extension["name"], extension["architecture_id"], free: extension["free"])
      end

      ProductExtensions.new(extensions)
    end
  end

  # Repository service
  class Extension

    # TODO FIXME: missing dependencies
    attr_reader :short_name, :long_name, :description, :product_ident, :free, :arch

    def initialize(product_ident, short_name, arch, long_name: "", description: "", free: false)
      @arch = arch
      @short_name = short_name
      @long_name = long_name
      @description = description
      @product_ident = product_ident
      @free = free
    end
  end
end
