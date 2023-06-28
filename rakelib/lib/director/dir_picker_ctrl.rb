###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class DirPickerCtrl < Window

      def setup
        super
        spec.make_concrete 'wxDirPickerCtrl'
        spec.do_not_generate(:variables, :defines, :enums, :functions) # with FileDirPickerEvent
      end
    end # class DirPickerCtrl

  end # class Director

end # module WXRuby3
