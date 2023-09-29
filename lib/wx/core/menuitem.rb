# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# An individual item within a frame or popup menu

class Wx::MenuItem
  # Get the Wx id, not Ruby's deprecated Object#id
  alias :id :get_id
  # In case a more explicit option is preferred.
  alias :wx_id :get_id
end
