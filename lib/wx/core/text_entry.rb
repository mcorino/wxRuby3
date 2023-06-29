
module Wx

  module TextEntry

    wx_auto_complete = instance_method :auto_complete
    define_method :auto_complete do |completer|
      if wx_auto_complete.bind(self).call(completer)
        @completer = completer # keep the Ruby object alive
      end
    end

  end

end
