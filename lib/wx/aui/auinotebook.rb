# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Advanced User Interface Notebook - draggable panes etc

class Wx::AUI::AuiNotebook

  # Before wxWidgets 3.3 the AUI manager of this control would prevent
  # WindowDestroyEvent propagation so we 'patch' in a std event handler
  # that designates the event skipped.
  if Wx::WXWIDGETS_VERSION < '3.3'
    wx_initialize = instance_method :initialize
    wx_redefine_method :initialize do |*args|
      wx_initialize.bind(self).call(*args)
      evt_window_destroy { |evt| evt.skip }
    end
  end

  # Convenience method for iterating pages
  def each_page
    if block_given?
      0.upto(get_page_count - 1) do | i |
        yield get_page(i)
      end
    else
      ::Enumerator.new { |y| each_page { |pg| y << pg } }
    end
  end
end
