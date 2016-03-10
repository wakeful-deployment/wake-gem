require 'helper'
require 'stub_config'
require 'wake/utils/run'

describe Utils::Run do
  it "captures stdout" do
    o, e = Utils::Run.run("ls /")

    refute o.empty?
    assert e.empty?
  end

  it "captures stderr" do
    o, e = Utils::Run.run("ls /crap")

    assert o.empty?
    refute e.empty?
  end

  it "captures stdoutd, stderr, and to a stream" do
    path_to_app = File.expand_path("../../fixtures/output_app.rb", __FILE__)
    cmd = "ruby #{path_to_app}"
    stream = ""

    o, e = Utils::Run.run(cmd, stream: stream)

    # only stars on stdout
    assert ["*"], o.lines.map(&:chomp).join.chars.uniq
    # only dollars on stderr
    assert ["$"], e.lines.map(&:chomp).join.chars.uniq

    # ok, did it interleave it correctly
    assert_equal <<~EOF, stream.lines.sort.join
      # $ #{cmd}
      $$$$$$$$$$
      $$$$$$$$$$
      $$$$$$$$$$
      **********
      **********
      **********
    EOF
  end
end
