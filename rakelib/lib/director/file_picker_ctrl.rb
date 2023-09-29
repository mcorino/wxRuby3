# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class FilePickerCtrl < Window

      def setup
        super
        spec.make_concrete 'wxFilePickerCtrl'
        spec.do_not_generate(:variables, :defines, :enums, :functions) # with FileDirPickerEvent
      end
    end # class FilePickerCtrl

  end # class Director

end # module WXRuby3
