module ConfigFormatter
  module_function

  def format_string(value, keys)
    value.gsub!(/ /, ' ') # non-breaking space so column will do the right thing

    out = "#{keys.join(".")}\t#{value}"

    out.gsub!(/\.\[/, '[') # remove . from before [0] so arrays look better

    out
  end

  def format_array(array, keys = [])
    array.each_with_index.map do |v, index|
      keys.push("[#{index}]")
      output = if v.is_a?(Hash)
        format_hash(v, keys)
      elsif v.is_a?(Array)
        format_array(v, keys)
      else
        format_string(v, keys)
      end
      keys.pop
      output
    end
  end

  def format_hash(hash, keys = [])
    hash.map do |k, v|
      keys.push(k)
      output = if v.is_a?(Hash)
        format_hash(v, keys)
      elsif v.is_a?(Array)
        format_array(v, keys)
      else
        format_string(v, keys)
      end
      keys.pop
      output
    end.flatten
  end
end