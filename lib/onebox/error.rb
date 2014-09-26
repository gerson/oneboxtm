module Onebox
  class Error < StandardError
    attr_accessor :error_code
    def initialize(error_message, error_code=400)
      @error_code = error_code
      super(error_message)
    end
  end

  class ResponseError < Error
    class << self
      def initialize(response)
        case response.code
        when 404
          Error.new "The requested resource could not be found but may be available again in the future", response.code
        when 407
          Error.new "Proxy Authentication Required", response.code
        when 500
          Error.new "Internal Server Error", response.code
        when 503
          Error.new "The server is currently unavailable", response.code
        else
          Error.new response_values(response), response.code
        end
      end

      def response_values(response)
        {:status => response.code, :headers => response.to_hash.inspect, :body => response.body}
      end
    end
  end

end