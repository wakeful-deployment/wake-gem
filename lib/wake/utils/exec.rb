require "wake/utils/powershell"

module Utils
  module Exec
    module_function

    def exec(command)
      if Powershell.powershell?
        system command
        exit $?.exitstatus
      else
        Kernel.exec command
      end
    end
  end
end
