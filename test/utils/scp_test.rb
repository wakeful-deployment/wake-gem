require "helper"
require "wake/utils/scp"

describe Utils::SCP do
  it "calls run!" do
    scp = Utils::SCP.new(ip: "127.0.0.1", local_path: "/crap.txt", username: "foo")
    scp.stub(:run!, :success) do
      assert_equal :success, scp.call
    end
  end
end
