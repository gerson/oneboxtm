require 'base64'
require 'openssl'
require 'digest/md5'
require 'net/http'

module Onebox
  module REST

    PATH = '/onebox-rest2'
    USER_VALIDATE_PATH = '/rest/user/validate' #user info Method: GET
    EVENTS_SEARCH = '/rest/events/search' #list of events which contains the matching sessions. Method: POST or GET

    def validateUser
      response = get_request(USER_VALIDATE_PATH, 'GET')
      data = ActiveSupport::JSON.decode(response.body)
      setChannel(data)
    end

    private
    #Setting channel value from validateUser request
    def setChannel(data)
      @channel = data['entity']['channels']['channel']['@id']
    end

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

    def get_request(endPoint, http_method, params = {})
      set_uri(endPoint, http_method)
      @req = Net::HTTP::Get.new(@uri.request_uri)
      set_headers(@signature, @timestamp, params)
      res = Net::HTTP.start(@uri.hostname, @uri.port) {|http|
        http.request(@req)
      }
    end

    def post_request(endPoint, http_method, params = {})
      set_uri(endPoint, http_method)
      @req = Net::HTTP::Post.new(@uri.request_uri)
      set_headers(@signature, @timestamp, params)
      res = Net::HTTP.start(@uri.hostname, @uri.port) {|http|
        http.request(@req)
      }
    end

    def set_uri(endPoint, http_method)
      @uri = URI("#{@host}#{PATH}#{endPoint}")
      @timestamp = Time.now.to_i
      @signature = addFilters(endPoint, http_method, Time.now.to_i)
    end

    def set_headers(signature, timestamp, params = {})
      raise ArgumentError.new("You must provide signature") if signature.nil?
      if params.any?
        params.each do |key, value|
          @req["#{key}"] = value
        end
      end
      @req['Authorization'] = signature
      @req['OB_Terminal'] = @terminal
      @req['OB_Date'] = timestamp
      @req['OB_User'] = @user
      @req['Accept'] = "application/json"
    end

  end
end

