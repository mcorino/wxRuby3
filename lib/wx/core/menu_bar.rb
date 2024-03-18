# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

class Wx::MenuBar

  alias :wx_initialize :initialize

  def initialize(*args, &block)
    wx_initialize(*args)
    if Wx::PLATFORM == 'WXOSX'
      # OSX's standard Apple/Application menu gets titled with the executables name by default
      # which is 'ruby' for wxRuby and this title is near impossible to reliably change.
      # Therefor we implemented (a little stunted) workaround here to deal with Apple's crap.
      # We insert a disabled item at the start of this menu with the AppDisplayName and follow
      # it up with a nice separator. This way at least we will always be able to see which wxRuby
      # app the visible menu belongs to.
      apple_menu = osx_get_apple_menu
      apple_menu.insert(0, Wx::ID_NONE, Wx.get_app.get_app_display_name).enable(false)
      apple_menu.insert_separator(1)
    end
    if block
      if block.arity == -1 or block.arity == 0
        self.instance_eval(&block)
      elsif block.arity == 1
        block.call(self)
      else
        Kernel.raise ArgumentError,
                     "Block to initialize should accept a single argument or none"
      end
    end
  end

end
