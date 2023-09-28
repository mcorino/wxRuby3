# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

class Wx::Validator
  # Default implementation of clone, may need to be over-ridden if
  # custom subclasses should state variables that need to be copied
  def clone
    self.class.new
  end
end
