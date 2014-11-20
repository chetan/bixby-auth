module ApiAuth

  # Builds the canonical string given a request object.
  class Headers

    include RequestDrivers

    def initialize(request)
      @original_request = request
      @request = initialize_request_driver(request)
      true
    end

    def initialize_request_driver(request)
      clazz = request.class.to_s
      if RequestDrivers.drivers.include?(clazz) then
        return RequestDrivers.drivers[clazz].new(request)

      elsif clazz == "ActionController::TestRequest" then
        # special handling for rails 3 vs 4
        if defined?(ActionDispatch) then
          return ActionDispatchRequest.new(request)
        else
          return ActionControllerRequest.new(request)
        end

      elsif Module.const_defined?(:Rack) && Rack.const_defined?(:Request) && request.kind_of?(Rack::Request) then
        # this goes last because TestRequest is also a subclass of Rack::Request
        return RackRequest.new(request)
      end

      raise UnknownHTTPRequest, "#{clazz} is not yet supported."
    end
    private :initialize_request_driver

    # Returns the request timestamp
    def timestamp
       @request.timestamp
    end

    # Returns the canonical string computed from the request's headers
    def canonical_string
      [ @request.content_type,
        @request.content_md5,
        @request.request_uri.gsub(/https?:\/\/[^(,|\?|\/)]*/,''), # remove host
        @request.timestamp
      ].join(",")
    end

    # Returns the authorization header from the request's headers
    def authorization_header
      @request.authorization_header
    end

    def set_date
      @request.set_date if @request.timestamp.empty?
    end

    def calculate_md5
      @request.populate_content_md5 if @request.content_md5.empty?
    end

    def md5_mismatch?
      if @request.content_md5.empty?
        false
      else
        @request.md5_mismatch?
      end
    end

    # Sets the request's authorization header with the passed in value.
    # The header should be the ApiAuth HMAC signature.
    #
    # This will return the original request object with the signed Authorization
    # header already in place.
    def sign_header(header)
      @request.set_auth_header header
    end

  end

end
