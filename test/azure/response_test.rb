require 'helper'
require 'wake/azure/response'

module Azure
  describe Response do
    let(:response) { Response.new code: "200", body: '{"foo":"bar"}' }

    it "has a status" do
      assert_equal 200, response.status
    end

    it "can parse a json body" do
      assert_equal({"foo" => "bar"}, response.parsed_body)
    end
  end
end
