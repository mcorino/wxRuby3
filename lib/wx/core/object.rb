# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# The root class for most (not all) WxRuby classes

module Wx

  class Object
    # Massage the output of inspect to show the public module name (Wx),
    # instead of the internal name (Wxruby2)
    # def to_s
    #   super.sub('ruby2', '')
    # end

    # Returns a string containing the C++ pointer address of this
    # object. Only useful for debugging.
    def ptr_addr
      Wx::ptr_addr(self)
    end

    # By default Wx:::Object derived class instances cannot be #dup-licated.
    def dup
      nil
    end

    # By default Wx::Object derived class instances cannot be cloned but instead return self.
    def clone
      self
    end

  end

end
