require "wake/utils/key"
require "wake/utils/index"

module Utils
  class KeysAndIndexes
    attr_reader :ops

    def initialize(ops)
      @ops = ops
    end

    def get(thing)
      ops.reduce(thing) do |sub_thing, op|
        op.get(sub_thing)
      end
    end

    def key?(thing)
      list = ops[0..-2]

      bottom_thing = list.reduce(thing) do |sub_thing, op|
        op.get(sub_thing)
      end

      if bottom_thing
        ops.last.key?(bottom_thing)
      end
    end

    def update(thing, value:)
      ops_to_create_through = ops[0..-2]
      shifted = ops[1..-1]
      list = ops_to_create_through.zip(shifted)

      bottom_thing = list.reduce(thing) do |sub_thing, (op, next_op)|
        op.get_or_create(sub_thing, default: next_op.class.default)
      end

      ops.last.update(bottom_thing, value: value)
    end

    def delete(thing)
      list = ops[0..-2]

      bottom_thing = list.reduce(thing) do |sub_thing, op|
        op.get(sub_thing)
      end

      if bottom_thing
        ops.last.delete(bottom_thing)
      end
    end

    def self.normalize_dots(string)
      string.gsub(/\[(\d+)\]/, '.[\\1].').gsub(/\.{2,}/, '.')
    end

    def self.parse(string)
      normalize_dots(string).split('.').map do |s|
        if s =~ /\A\[(\d+)\]\z/
          Index.new($1.to_i)
        else
          Key.new(s)
        end
      end
    end

    def self.from(string)
      new(parse(string))
    end
  end
end
