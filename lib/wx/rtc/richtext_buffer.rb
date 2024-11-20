# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

class Wx::RTC::RichTextBuffer

  class << self
    wx_each_handler = instance_method :each_handler
    wx_redefine_method :each_handler do |&block|
      if block_given?
        wx_each_handler.bind(self).call(&block)
      else
        ::Enumerator.new { |y| wx_each_handler.bind(self).call { |h| y << h } }
      end
    end

    wx_each_field_type = instance_method :each_field_type
    wx_redefine_method :each_field_type do |&block|
      if block_given?
        wx_each_field_type.bind(self).call(&block)
      else
        ::Enumerator.new { |y| wx_each_field_type.bind(self).call { |ft| y << ft } }
      end
    end

    wx_each_drawing_handler = instance_method :each_drawing_handler
    wx_redefine_method :each_drawing_handler do |&block|
      if block_given?
        wx_each_drawing_handler.bind(self).call(&block)
      else
        ::Enumerator.new { |y| wx_each_drawing_handler.bind(self).call { |h| y << h } }
      end
    end
  end

end
