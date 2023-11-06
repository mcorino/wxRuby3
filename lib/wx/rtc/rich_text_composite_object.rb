# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx

  module RTC

    class RichTextCompositeObject

      # Overload to provide Enumerator without block
      wx_each_child = instance_method :each_child
      define_method :each_child do |&block|
        if block
          wx_each_child.bind(self).call(&block)
        else
          ::Enumerator.new { |y| wx_each_child.bind(self).call { |rto| y << rto } }
        end
      end

    end

  end

end
