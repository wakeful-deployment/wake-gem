require 'wake/azure/poller'

module Azure
  class ProvisioningStatePoller
    def poll?(response)
      response.parsed_body.dig("properties", "provisioningState")
    end

    def should_break?(response)
      body = result.response.parsed_body
      state = body["properties"] && body["properties"]["provisioningState"]

      state.nil? || state == "Succeeded"
    end
  end
end
