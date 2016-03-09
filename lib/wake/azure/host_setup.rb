require 'wake/azure/setup/seed'
require 'wake/azure/setup/server'
require 'wake/azure/setup/agent'

module Azure
  module Setup
    TYPES = {
      "seed"   => Seed,
      "server" => Server,
      "agent"  => Agent
    }.freeze

    def self.call(**opts)
      klass = TYPES[opts.delete(:type)]
      klass.new(**opts).tap { |k| k.call }
    end
  end
end
