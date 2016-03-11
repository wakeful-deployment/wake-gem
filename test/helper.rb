require 'minitest/autorun'
require 'minitest/rg'
require 'webmock/minitest'
require 'stub_config'

WebMock.disable_net_connect!(net_http_connect_on_start: true)

class Minitest::Test
  # add global helpers here
end
