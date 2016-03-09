require "delegate"
require "wake/utils/errors"
require "wake/utils/requireable_array"
require "wake/utils/keys_and_indexes"

module Utils
  class RequireableHash < SimpleDelegator
    def key?(key)
      KeysAndIndexes.from(key).key?(to_hash)
    end

    def [](key)
      value = KeysAndIndexes.from(key).get(to_hash)
      wrap(value)
    end

    def []=(key, value)
      update(key, value)
    end

    def require(key)
      value = KeysAndIndexes.from(key).get(to_hash)

      fail(Error.new("no key '#{key}'")) if value.nil?

      wrap(value)
    end

    def update(key, value)
      KeysAndIndexes.from(key).update(to_hash, value: value)
    end

    def delete(key)
      KeysAndIndexes.from(key).delete(to_hash)
    end

    def to_hash
      __getobj__
    end
    alias_method :to_h, :to_hash

    private

    def wrap(value)
      if value.is_a?(Hash)
        self.class.new(value)
      elsif value.is_a?(Array)
        RequireableArray.new(value)
      else
        value
      end
    end
  end
end
