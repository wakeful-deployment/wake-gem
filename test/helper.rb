require 'minitest/autorun'
require 'minitest/rg'
require 'webmock/minitest'
require 'stub_config'

WebMock.disable_net_connect!

class Minitest::Test
  # add global helpers here
end
