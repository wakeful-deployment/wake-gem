require 'shellwords'
require 'wake/utils/powershell'

module Utils
  module Escape
    def self.escape_spaces!(string)
      string.replace "\"#{string}\""
    end

    def self.escape_double_quotes!(string)
      string.gsub!(/"/) { "\"\"" }
      string.replace "\"#{string}\""
    end

    def self.escape_single_quotes!(string)
      string.gsub!(/'/) { "''" }
      string.replace "\"#{string}\""
    end

    def self.escape_powershell(string)
      string = string.to_s.dup # mutate a copy

      if string.include? ?"
        escape_double_quotes! string
      elsif string.include? ?'
        escape_single_quotes! string
      elsif string.include? ?\s
        escape_spaces! string
      end

      string
    end

    module_function

    def escape(string)
      if Powershell.powershell?
        escape_powershell(string)
      else
        Shellwords.escape(string)
      end
    end
  end
end
