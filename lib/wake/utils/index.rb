require "wake/utils/errors"

module Utils
  class Index
    def initialize(number)
      @number = number
    end

    def get(a)
      if a.is_a?(Array)
        a[@number]
      end
    end

    def self.default
      []
    end

    def get_or_create(a, default:)
      if a.is_a?(Array)
        a[@number] ||= default
      else
        fail CannotCreate
      end
    end

    def key?(a)
      if a.is_?(Array)
        !a[@number].nil?
      end
    end

    def update(a, value:)
      if a.is_a?(Array)
        a[@number] = value
      else
        fail CannotUpdate
      end
    end

    def delete(a)
      if a.is_a?(Array)
        a.delete_at(@number)
      end
    end
  end
end
