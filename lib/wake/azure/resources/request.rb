require 'net/http'
require 'json'
require 'wake/azure/resources/response'

module Azure
  class Request
    BASE_URI = URI("https://management.azure.com").freeze

    VERBS = {
      head: Net::HTTP::Head,
      get: Net::HTTP::Get,
      post: Net::HTTP::Post,
      put: Net::HTTP::Put,
      patch: Net::HTTP::Patch,
      delete: Net::HTTP::Delete
    }.freeze

    BODIES = [:post, :put, :patch].freeze

    attr_reader :token, :verb, :body, :headers, :original_response, :response

    def initialize(token:, uri:, verb:, body: nil, headers: {})
      @state = :pending
      @token = token
      @uri = uri
      @verb = verb
      @body = body
      @headers = headers
    end

    def complete?
      @state == :complete
    end

    def uri
      if @uri.scheme
        @uri
      else
        URI("#{BASE_URI}#{@uri}")
      end
    end

    def to_curl
      o = "curl"
      o << " -H 'Authorization: #{token.to_header}'"
      o << " -H 'Accept: application/json'"

      headers.each do |k, v|
        o << " -H '#{k}: #{v}'"
      end

      if BODIES.include?(verb)
        o << " -H 'Content-type: application/json'"
        o << " -d '#{body}'"
      end

      o << " '#{uri}'"
    end

    private def make_request
      Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
        klass = VERBS[verb]
        request = klass.new uri

        request["Authorization"] = token.to_header
        request["Accept"] = "application/json"

        headers.each do |k, v|
          request[k] = v
        end

        if BODIES.include?(verb) && body
          request["Content-type"] = "application/json"
          request.body = if String === body then body else JSON.generate(body) end

          Wake.debug request.body
        end

        @original_response = http.request request
      end

      @response = Response.new(request: self,
                               code: original_response.code,
                               body: original_response.body,
                               headers: original_response.to_hash)

    rescue => e
      @original_response = nil

      response_body = JSON.generate({
        type: "exception",
        exception: {
          message: e.message,
          backtrace: e.backtrace
        }
      })

      response_code = if Errno::ETIMEDOUT === e then "504" else "599" end

      @response = Response.new(request: self,
                               code: response_code,
                               body: response_body,
                               headers: {})
    end

    def call
      Wake.log [uri, verb]

      make_request

      Wake.log [uri, @response.status]
      Wake.debug @response.body

      @state = :complete
    end
  end
end
