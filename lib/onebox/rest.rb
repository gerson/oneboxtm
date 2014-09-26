require 'base64'
require 'openssl'
require 'digest/md5'
require 'net/http'
require 'onebox/error'

module Onebox
  module REST

    PATH = '/onebox-rest2'
    USER_VALIDATE_PATH = '/rest/user/validate' #user info Method: GET
    EVENTS_SEARCH = '/rest/events/search' #list of events which contains the matching sessions. Method: POST or GET
    SESSION_INFO = '/rest/session/{idSession}/info' 

    def validateUser
      response = get_request(USER_VALIDATE_PATH)
      data = ActiveSupport::JSON.decode(response.body)
      setChannel(data)
      data
    end

    def searchEvents(params = {})
      validateUser if @channel.nil?
      headers = {:OB_Channel => @channel}
      response = post_request(EVENTS_SEARCH,headers,params)
      ActiveSupport::JSON.decode(response.body)
    end

    def sessionInfo(params = {})
      validateUser if @channel.nil?
      headers = {:OB_Channel => @channel}
      response = get_request(SESSION_INFO.gsub('{idSession}','108714'),headers,params)
      ActiveSupport::JSON.decode(response.body)
    end

    private
    #Setting channel value from validateUser request
    def setChannel(data)
      @channel = data['entity']['channels']['channel']['@id']
    end

    def addFilters(endPoint, http_method, timestamp, params = {})
      raise Error.new("You must provide an endPoint") if endPoint.nil?
      raise Error.new("You must provide http method") if http_method.nil?
      canonical = canonicalize(endPoint, http_method.upcase, timestamp, sort_params(params))  
      sign_request(canonical)
    end

    def canonicalize(endPoint, http_method, timestamp, params = {})
      canonical = "#{http_method}\n#{timestamp}\n#{PATH}#{endPoint}"
      unless params.empty?        
        params.each_with_index do |(key,value),index| 
          canonical += "?" if index == 0
          canonical += "#{key}=#{value}"
          canonical += "&" unless index == params.size - 1
        end
      end
      canonical
    end

    def sign_request(canonical)
      private_key = @secretKey + @license
      signature = "OB_HMAC "+Base64.encode64(OpenSSL::HMAC.digest('sha1', private_key, canonical)).gsub("\n", '')
    end

    def get_request(endPoint, headers = {}, params = {})
      set_uri(endPoint, 'GET', params)
      @req = Net::HTTP::Get.new(@uri.request_uri)      
      set_headers(@signature, @timestamp, headers)
      res = Net::HTTP.start(@uri.hostname, @uri.port) {|http|
        http.request(@req)
      }
      unless res == Net::HTTPSuccess
        raise ResponseError.new(res)
      end
      res
    end

    def post_request(endPoint, headers = {}, params = {})
      set_uri(endPoint, 'POST', params)
      @req = Net::HTTP::Post.new(@uri.request_uri)
      @req.set_form_data(params) unless params.empty?
      set_headers(@signature, @timestamp, headers)
      res = Net::HTTP.start(@uri.hostname, @uri.port) {|http|
        http.request(@req)
      }
      unless res == Net::HTTPSuccess
        raise ResponseError.new(res)
      end
      res
    end

    def set_uri(endPoint, http_method, params = {})
      @uri = URI("#{@host}#{PATH}#{endPoint}")
      @timestamp = Time.now.to_i
      @signature = addFilters(endPoint, http_method, Time.now.to_i,params)
    end

    def sort_params(params)
      params.sort_by {|k,v| k}
    end

    def set_headers(signature, timestamp, headers = {})
      raise Error.new("You must provide signature") if signature.nil?
      if headers.any?
        headers.each do |key, value|
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

