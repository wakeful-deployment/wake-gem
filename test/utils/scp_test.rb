require "helper"
require "wake/utils/scp"

describe Utils::SCP do
  it "calls run!" do
    scp = Utils::SCP.new(ip: "127.0.0.1", local_path: "/crap.txt")
    scp.stub(:run!, :success) do
      result = scp.call
      assert_equal :success, result
    end
  end
end
