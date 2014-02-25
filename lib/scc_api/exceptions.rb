# encoding: utf-8

require "json"

module SccApi
  class NoNetworkError < RuntimeError
    def initialize
      super "Network is down and no connection to SCC is possible"
    end
  end

  class NotAuthorized < RuntimeError
    def initialize
      super "SCC did not accept the given credentials"
    end
  end

  class ErrorResponse < RuntimeError
    def initialize response
      # TODO parse response and fill useful data
      super response.body
    end
  end

  class RedirectionLimit < RuntimeError
    def initialize
      super "HTTP Redirection limit reached"
    end
  end
end
