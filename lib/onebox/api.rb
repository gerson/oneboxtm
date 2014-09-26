require 'onebox/rest'
require 'onebox/error'

module Onebox
  class API

    include Onebox::REST

    attr_accessor :user, :secretKey, :terminal, :license, :env, :host, :channel

    SANDBOX_HOST = 'http://pre.rest2.oneboxtickets.com'
    PRODUCTION_HOST = 'http://pre.rest2.oneboxtickets.com'

    def initialize(environment = 'sandbox', options = {})
      #user, secretKey, terminal, license, channel=nil, pos=nil
      required_params = [:user, :secretKey, :terminal, :license]
      if options.any?
        @env = environment
        @host = @env == 'sandbox' ? SANDBOX_HOST : PRODUCTION_HOST

        required_params.each do |param|
          unless options[param].present?
            raise Error.new("You must provide #{param.to_s} param")
          else
            instance_variable_set("@#{param}", options[param])
          end
        end
      else
        raise Error.new("You must provide required params")
      end
    end

  end
end

