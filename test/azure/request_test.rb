require 'helper'
require 'wake/azure/request'
require 'wake/azure/token'

module Azure
  describe Request do
    let(:example_token) { Token.new type: "foo", expires_on: Time.now.to_i*1_024, resource: "foo", access_token: "foo" }
    let(:example_uri) { URI("/") }
    let(:example_request) { Request.new token: example_token, uri: example_uri, verb: :get }

    it "is not complete" do
      refute example_request.complete?
    end

    it "prepends the base uri" do
      assert_match %r{^https://management}, example_request.uri.to_s
    end

    it "makes a request" do
      stub_request :get, Request::BASE_URI
      example_request.call
      assert_requested :get, Request::BASE_URI
    end

    it "produces a response even when a timeout occurs" do
      stub_request(:get, Request::BASE_URI).to_timeout
      example_request.call
      assert_equal 504, example_request.response.status
    end
  end
end
