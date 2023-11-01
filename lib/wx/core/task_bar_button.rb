# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.


module Wx

  if Wx::PLATFORM == 'WXMSW'
    class TaskBarButton

      wx_remove_thumb_bar_button = instance_method :remove_thumb_bar_button
      define_method :remove_thumb_bar_button do |button|
        button = button.get_id if button.is_a?(Wx::ThumbBarButton)
        wx_remove_thumb_bar_button.bind(self).call(button)
      end

    end
  end
end
