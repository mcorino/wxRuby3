# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Copyright 2004-2007 by Kevin Smith
# Copyright 2022 by Martin Corino
# released under the MIT(-style) wxruby2/3 license

# The base class for all things displayed on screen
class Wx::Window

  # Add the deprecated/removed GetSize method
  def get_size
    rect.size
  end
  alias :size :get_size

  # Ruby's Object#id is deprecated and will be removed in 1.9; therefore
  # for classes inheriting from Wx::Window, the id method returns the
  # wxRuby Window id
  alias :id :get_id
  # In case a more explicit option is preferred.
  alias :wx_id :get_id

  # Z-order alternatives
  alias :bring_to_front :raise_window
  alias :send_to_back :lower_window

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
  # handler will supply a Wx::PaintDC (see Window SWIG director).
  def evt_paint(meth = nil, &block)
    paint_proc = acquire_handler(meth, block)
    wrapped_block = proc do | event |
      instance_variable_set('@__painting__', true)
      paint_proc.call(event)
      remove_instance_variable('@__painting__')
    end
    __old_evt_paint(&wrapped_block)
  end

  # Overload the wrapper method to check for @__painting__
  wx_paint_buffered = instance_method :paint_buffered
  define_method :paint_buffered do |&block|
    if instance_variable_defined?('@__painting__')
      wx_paint_buffered.bind(self).call(&block)
    else
      self.paint(&block)
    end
  end

  # Overload to provide Enumerator without block
  wx_each_child = instance_method :each_child
  define_method :each_child do |&block|
    if block
      wx_each_child.bind(self).call(&block)
    else
      ::Enumerator.new { |y| wx_each_child.bind(self).call { |c| y << c } }
    end
  end

  # implement non-static variants of these

  def from_dip(*args)
    Wx::Window.from_dip(*args, self)
  end
  def to_dip(*args)
    Wx::Window.to_dip(*args, self)
  end

  def from_phys(*args)
    Wx::Window.from_phys(*args, self)
  end
  def to_phys(*args)
    Wx::Window.to_phys(*args, self)
  end

  # implement Window update locker
  def locked(&block)
    self.freeze
    begin
      block.call if block_given?
    ensure
      self.thaw
    end
  end
end
