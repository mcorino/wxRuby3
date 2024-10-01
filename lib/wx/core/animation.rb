# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

module Wx

  class Animation
    # Redefine the initialize method so it raises an exception if a
    # non-existent file is given to the constructor; otherwise, wx Widgets
    # just carries on with an empty bitmap, which may cause faults later
    wx_init = self.instance_method(:initialize)
    define_method(:initialize) do | *args |
      if args[0].kind_of? String
        if not File.exist?( File.expand_path(args[0]) )
          Kernel.raise( ArgumentError,
                        "Animation file does not exist: #{args[0]}" )
        end
        res = wx_init.bind(self).call()
        res.load_file(args[0], args[1] || Wx::ANIMATION_TYPE_ANY)
      else
        wx_init.bind(self).call(*args)
      end
    end
  end

  if Wx::WXWIDGETS_VERSION >= '3.3.0'

    class AnimationCtrl

      # Redefine this method to accept either a single animation or an animation bundle
      wx_set_animation = self.instance_method(:set_animation)
      define_method(:set_animation) do | arg |
        if Wx::Animation === arg
          arg = Wx::AnimationBundle.new(arg)
        end
        wx_set_animation.bind(self).call(arg)
      end

    end

  end

end
