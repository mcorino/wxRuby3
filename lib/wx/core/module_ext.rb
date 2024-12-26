# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Kernel

  def wx_redefine_method(mtd, &block)
    warn_lvl = $VERBOSE
    $VERBOSE = nil
    undef_method(mtd)
    define_method(mtd, &block)
  ensure
    $VERBOSE = warn_lvl
  end

end
