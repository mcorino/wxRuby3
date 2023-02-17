
module Wx

  class PlatformInfo

    # make all methods of the singleton accessible through the class
    def self.method_missing(sym, *args)
      Wx::PlatformInfo.instance.__send__(sym, *args)
    end

  end

end
