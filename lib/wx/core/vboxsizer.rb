# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Just a shortcut version for creating a vertical box sizer

class Wx::VBoxSizer < Wx::BoxSizer
  def initialize
    super(Wx::VERTICAL)
  end
end

# Just a shortcut version for creating a vertical wrap sizer
class Wx::VWrapSizer < Wx::WrapSizer
  def initialize(flags=Wx::WRAPSIZER_DEFAULT_FLAGS)
    super(Wx::VERTICAL)
  end
end
