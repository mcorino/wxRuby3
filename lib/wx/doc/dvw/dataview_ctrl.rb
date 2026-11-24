# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:

module Wx

  module DVW

    # Boolean constant signifying if a native DataViewCtrl is implemented.
    HAS_NATIVE_DATAVIEWCTRL = Wx.has_feature?(:USE_NATIVE_DATAVIEWCTRL) &&
                              !Wx.has_feature?(:WXUNIVERSAL) &&
                              (Wx.has_feature?(:WXGTK) || Wx.has_feature?(:WXOSX))

    # Boolean constant signifying if the generic DataViewCtrl is implemented.
    HAS_GENERIC_DATAVIEWCTRL = !HAS_NATIVE_DATAVIEWCTRL

  end

end
