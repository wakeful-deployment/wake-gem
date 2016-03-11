require 'uri'
require 'wake/azure'
require 'wake/azure/request'
require 'wake/azure/status_poller'
require 'wake/azure/provisioning_state_poller'

module Azure
  TokenExpired = Class.new(StandardError)

  class Action
    attr_reader :token, :model, :verb, :version, :request, :response, :body

    def initialize(token: Azure.token_provider, verb:, version:, uri:, body: nil)
      @state = :pending
      @token = token
      @verb = verb
      @version = version
      @uri = URI(uri)
      @body = body
    end

    def complete?
      @state == :complete
    end

    def params
      { "api-version" => version }
    end

    def base_uri
      @uri
    end

    def uri
      base_uri.dup.tap do |u|
        u.query = params.map { |k, v| "#{k}=#{URI.encode(v.to_s)}" }.join("&")
      end
    end

    def to_hash
      if complete?
        response.parsed_body
      end
    end

    def to_model
      fail NotImplementedError
    end

    def make_request
      @request = Request.new(token: token, uri: uri, body: body, verb: verb)
    end

    def responses
      if @responses
        @responses
      else
        [@response].compact
      end
    end

    def call(poll: true)
      make_request
      @request.call
      @response = @request.response

      if response.status == 401
        @state = :error
        fail TokenExpired
      end

      if poll then poll! end

      if response.status > 499
        @state = :error
      else
        @state = :complete
      end
    end

    def poll!
      if StatusPoller.poll?(response)
        @responses = [@response]

        poll_uri = URI(response.headers["location"].first)
        poller = StatusPoller.new(token: token, uri: poll_uri)
        poller.call

        @response = poller.response
        @responses << @response
      end

      if ProvisioningStatePoller.poll?(response)
        @responses = [@response]

        poller = ProvisioningStatePoller.new(token: token, uri: uri)
        poller.call

        @response = poller.response
        @responses << @response
      end
    end
  end

  class Head < Action
    def initialize(token: Azure.token_provider, version:, uri:)
      super verb: :head, token: token, version: version, uri: uri
    end
  end

  class Get < Action
    def initialize(token: Azure.token_provider, version:, uri:)
      super verb: :get, token: token, version: version, uri: uri
    end
  end

  class Post < Action
    def initialize(token: Azure.token_provider, version:, uri:, body:)
      super verb: :post, token: token, version: version, uri: uri, body: body
    end
  end

  class Put < Action
    def initialize(token: Azure.token_provider, version:, uri:, body:)
      super verb: :put, token: token, version: version, uri: uri, body: body
    end
  end

  class Patch < Action
    def initialize(token: Azure.token_provider, version:, uri:, body:)
      super verb: :patch, token: token, version: version, uri: uri, body: body
    end
  end

  class Delete < Action
    def initialize(token: Azure.token_provider, version:, uri:)
      super verb: :delete, token: token, version: version, uri: uri
    end
  end
end
