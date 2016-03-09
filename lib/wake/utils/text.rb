module Utils
  module Text
    def columnize(string)
      columnBoundary = string.lines.map{|line| line.split[0].length}.max
      string.lines.map do |line|
        tokens = line.split
        "%-#{columnBoundary}s %s\n" %[tokens[0], tokens[1]]
      end.join
    end

    def indent(string, amount)
      string.lines.map do |line|
        spaces = " " * amount
        "#{spaces}#{line}"
      end.join
    end
  end
end
