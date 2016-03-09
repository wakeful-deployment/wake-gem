require "wake/utils/errors"

module Utils
  class Key
    def initialize(name)
      @name = name
    end

    def get(h)
      if h.is_a?(Hash)
        h[@name]
      end
    end

    def self.default
      {}
    end

    def get_or_create(h, default:)
      if h.is_a?(Hash)
        h[@name] ||= default
      else
        fail CannotCreate
      end
    end

    def key?(h)
      if h.is_a?(Hash)
        h.key?(@name)
      end
    end

    def update(h, value:)
      if h.is_a?(Hash)
        h[@name] = value
      else
        fail CannotUpdate
      end
    end

    def delete(h)
      if h.is_a?(Hash)
        h.delete(@name)
      end
    end
  end
end
