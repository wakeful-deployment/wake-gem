require 'helper'
require 'wake/utils/log'

def capture_std
  old_stdout, old_stderr = $stdout, $stderr
  o, e = StringIO.new, StringIO.new
  $stdout, $stderr = o, e

  yield

  [o.tap(&:rewind).read, e.tap(&:rewind).read]
ensure
  $stdout, $stderr = old_stdout, old_stderr
end

describe Utils::Log do
  after do
    Utils::Log.verbose = false
    Utils::Log.very_verbose = false
  end

  it "outputs to stdout by default" do
    o, e = capture_std do
      Utils::Log.output("something")
    end

    assert_equal "something\n", o
    assert e.empty?
  end

  it "can output to stderr" do
    o, e = capture_std do
      Utils::Log.output("something", io: $stderr)
    end

    assert o.empty?
    assert_equal "something\n", e
  end

  it "doesn't log by default" do
    o, e = capture_std do
      Utils::Log.log("something")
    end

    assert o.empty?
    assert e.empty?
  end

  it "logs to stdout if verbose" do
    Utils::Log.verbose = true

    o, e = capture_std do
      Utils::Log.log("something")
    end

    assert_equal "something\n", o
    assert e.empty?
  end

  it "doesn't debug by default" do
    o, e = capture_std do
      Utils::Log.debug("something")
    end

    assert o.empty?
    assert e.empty?
  end

  it "doesn't debug when verbose" do
    Utils::Log.verbose = true

    o, e = capture_std do
      Utils::Log.debug("something")
    end

    assert o.empty?
    assert e.empty?
  end

  it "debugs to stdout if very verbose" do
    Utils::Log.very_verbose = true

    o, e = capture_std do
      Utils::Log.debug("something")
    end

    assert_equal "something\n", o
    assert e.empty?
  end

  it "errors to stderr" do
    o, e = capture_std do
      Utils::Log.error("something")
    end

    assert o.empty?
    assert_equal "** Error: something\n", e
  end
end
