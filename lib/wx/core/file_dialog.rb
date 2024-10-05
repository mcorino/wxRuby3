# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# WxRuby Extensions - Dialog functors for wxRuby3

module Wx

  class FileDialog

    wx_set_customize_hook = instance_method :set_customize_hook
    define_method :set_customize_hook do |hook|
      wx_set_customize_hook.bind(self).call(hook)
      @hook = hook # cache hook to prevent premature GC collection
    end

  end

  class FileDialogCustomizeHook

    # prevent construction of abstract base
    def self.new(*)
      raise NotImplementedError, 'Wx::FileDialogCustomizeHook is an abstract class.' if self == Wx::FileDialogCustomizeHook
      super
    end

    # provide default no-ops

    def add_custom_controls(customizer) end

    def update_custom_controls; end

    def transfer_data_from_custom_controls; end

  end

end
