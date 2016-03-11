require 'wake/azure/poller'

module Azure
  class StatusPoller < Poller
    def poll?(response)
      response.status == 202
    end

    def should_break?(response)
      [200, 201, 204].include? response.status
    end
  end
end
