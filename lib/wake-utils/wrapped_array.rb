require "delegate"

class WrappedArray < SimpleDelegator
  def [](index)
    value = super
    wrap(value)
  end

  def to_ary
    __get_obj__
  end
  alias_method :to_a, :to_ary

  private

  def wrap(value)
    if value.is_a?(Hash)
      RequireableHash.new(value)
    elsif value.is_a?(Array)
      self.class.new(value)
    else
      value
    end
  end
end
