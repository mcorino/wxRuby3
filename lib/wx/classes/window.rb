# Copyright 2004-2007 by Kevin Smith
# released under the MIT-style wxruby2 license

# The base class for all things displayed on screen
class Wx::Window

  # Ruby's Object#id is deprecated and will be removed in 1.9; therefore
  # for classes inheriting from Wx::Window, the id method returns the
  # wxRuby Window id
  alias :id :get_id
  # In case a more explicit option is preferred.
  alias :wx_id :get_id

  # The name of Wx::Window#raise conflicts with Ruby's core Kernel#raise
  # method. This can cause unexpected errors when undecorated #raise is
  # used inside a Window method. For wxRuby 2.0 it's too late to remove
  # Window#raise completely, but for now, offer alternatives to
  # raise/lower that could replace them in future versions.
  alias :bring_to_front :raise
  alias :send_to_back :lower

  # Recursively searches all windows below +self+ and returns the first
  # window which has the id +an_id+. This corresponds to the find_window
  # method method in WxWidgets when called with an integer.
  def find_window_by_id(an_id)
    Wx::Window.find_window_by_id(an_id, self)
  end

  # Searches all windows below +self+ and returns the first window which
  # has the name +a_name+ This corresponds to the find_window method method
  # in WxWidgets when called with an string.
  def find_window_by_name(a_name)
    Wx::Window.find_window_by_name(a_name, self)
  end

  # Searches all windows below +self+ and returns the first window which
  # has the label +a_label+.
  def find_window_by_label(a_label)
    Wx::Window.find_window_by_label(a_label, self)
  end

  alias :__old_evt_paint :evt_paint
  # This modified version of evt_paint sets a variable indicating that a
  # paint event is being handled just before running the event
  # handler. This ensures that any call to Window#paint within the
  # handler will supply a Wx::PaintDC (see swig/Window.i).
  def evt_paint(meth = nil, &block)
    paint_proc = acquire_handler(meth, block)
    wrapped_block = proc do | event |
      instance_variable_set("@__painting__", true)
      paint_proc.call(event)
      remove_instance_variable("@__painting__")
    end
    __old_evt_paint(&wrapped_block)
  end

  # Provides bufferd drawing facility to reduce flicker for complex
  # drawing commands. Works similar to BufferedDC and BufferedPaintDC in
  # the wxWidgets API, by doing drawing on an in-memory Bitmap, then
  # copying the result in bulk to the screen.
  #
  # The method may be passed an existing Wx::Bitmap as the +buffer+,
  # otherwise one will be created.
  #
  # Works like wxAutoBufferedDC in that additional buffering will only
  # be done on platforms that do not already natively support buffering
  # for the standard PaintDC / ClientDC - Windows, in particular.
  def paint_buffered(buffer = nil)
    # OS X and GTK do double-buffering natively
    if self.double_buffered?
      paint { | dc | yield dc }
    else
      # client_size is the window area available for drawing upon
      c_size = client_size
      # Create an in-memory buffer if none supplied
      buffer ||= Wx::Bitmap.new(c_size.width, c_size.height)
      buffer.draw do | mem_dc |
        mem_dc.background = Wx::TRANSPARENT_BRUSH
        mem_dc.clear
        # Yield the bitmap for the user code to draw upon
        yield mem_dc
        paint do | dc |
          # Copy the buffer to the window
          dc.blit(0, 0, c_size.width, c_size.height, mem_dc, 0, 0)
        end
      end
    end
  end
end
