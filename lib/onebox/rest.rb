require 'base64'
require 'openssl'
require 'digest/md5'

module Onebox
  module REST

    USER_VALIDATE_PATH = '/user/validate' #user info Method: GET
    EVENTS_SEARCH = '/events/search' #list of events which contains the matching sessions. Method: POST or GET

    def validateUser
      puts "*"*100
    end

    def addFilters
    end

  end
end