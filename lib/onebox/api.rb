module Onebox
  class API
    include Onebox::REST

    attr_accessor :user, :secretKey, :terminal, :license

    SANDBOX_HOST = 'http://pre.rest2.oneboxtickets.com'
    PRODUCTION_HOST = 'http://pre.rest2.oneboxtickets.com'
    PATH = '/onebox-rest2'

    def initialize(environment = 'sandbox', options = {})
      #user, secretKey, terminal, license, channel=nil, pos=nil
      required_params = [:user, :secretKey, :terminal, :license]
      if options.any?
        @env = environment
        required_params.each do |param|
          unless options[param].present?
            raise ArgumentError.new("You must provide #{param.to_s} param")
          else
            instance_variable_set("@#{param}", options[param])
          end
        end
      else
        raise ArgumentError.new("You must provide required params")
      end
    end

  end
end

