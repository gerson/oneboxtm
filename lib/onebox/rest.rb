require 'base64'
require 'openssl'
require 'digest/md5'
require 'net/http'

module Onebox
  module REST

    PATH = '/onebox-rest2'
    USER_VALIDATE_PATH = '/user/validate' #user info Method: GET
    EVENTS_SEARCH = '/events/search' #list of events which contains the matching sessions. Method: POST or GET

    def validateUser
      addFilters(endPoint, http_method, Time.now.to_i)
      puts "*"*100
    end

    private

    def addFilters(endPoint, http_method, timestamp)
      raise ArgumentError.new("You must provide an endPoint") if endPoint.nil?
      raise ArgumentError.new("You must provide http method") if http_method.nil?
      canonical = canonicalize(endPoint, http_method.upcase, timestamp)
      sign_request(canonical)
    end

    def canonicalize(endPoint, http_method, timestamp)
      "#{http_method}\n#{timestamp}\n#{PATH}#{endPoint}"
    end

    def sign_request(canonical)
      private_key = @secretKey + @license
      signature = "OB_HMAC "+Base64.encode64(OpenSSL::HMAC.digest('sha1', private_key, canonical)).gsub("\n", '')
    end

    def get_request(endPoint, signature, params = {})
      uri = URI("#{@host}#{PATH}#{endPoint}")
      req = Net::HTTP::Get.new(uri.request_uri)
    end

    def post_request(endPoint, signature, params = {})
      uri = URI("#{@host}#{PATH}#{endPoint}")
      req = Net::HTTP::Post.new(uri.request_uri)
    end

    def set_headers(params, request)
      raise ArgumentError.new("You must provide a request") if request.nil?
      if params.any?
      else
      end
    end

  end
end

