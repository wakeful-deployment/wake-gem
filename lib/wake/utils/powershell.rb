module Utils
  module Powershell
    module_function

    def powershell?
      ENV.key?("ISPOWERSHELL")
    end
  end
end
