#--------------------------------------------------------------------
# @file    data_object.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class DataObject < Director

      def setup
        super
        spec.gc_as_object
        spec.swig_include '../shared/data_format.i'
        spec.swig_include '../shared/data_object_common.i'
      end
    end # class DataObject

  end # class Director

end # module WXRuby3
