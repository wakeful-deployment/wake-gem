require "helper"
require "wake/utils/ssh"

describe Utils::SSH do
  it "calls exec" do
    ssh = Utils::SSH.new(ip: "127.0.0.1", username: "foo")
    ssh.stub(:exec, :success) do
      assert_equal :success, ssh.call
    end
  end

  it "calls run when a command is provided" do
    ssh = Utils::SSH.new(ip: "127.0.0.1", username: "foo", command: "ls")
    ssh.stub(:run, :success) do
      assert_equal :success, ssh.call
    end
  end

  it "calls exec when force_exec is provided" do
    ssh = Utils::SSH.new(ip: "127.0.0.1", username: "foo", command: "ls", force_exec: true)
    ssh.stub(:exec, :success) do
      assert_equal :success, ssh.call
    end
  end
end
