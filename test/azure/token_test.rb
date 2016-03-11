require 'helper'
require 'wake/azure/token'

module Azure
  describe Token do
    let(:token) { Token.new type: "foo", expires_on: Time.now.to_i+100, resource: "foo", access_token: "foo" }

    it "is not expired" do
      refute token.expired?
    end

    it "is expiring soon" do
      assert token.expires_soon?
    end

    it "can be made ready to be an http header" do
      assert token.to_header
    end
  end
end
