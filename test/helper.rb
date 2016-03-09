require 'minitest/autorun'

class Minitest::Test
  def capture_std
    old_stdout, old_stderr = $stdout, $stderr
    o, e = StringIO.new, StringIO.new
    $stdout, $stderr = o, e

    yield

    [o.tap(&:rewind).read, e.tap(&:rewind).read]
  ensure
    $stdout, $stderr = old_stdout, old_stderr
  end
end
