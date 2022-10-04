#--------------------------------------------------------------------
# @file    about_dialog_info.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class AboutDialogInfo < Director

      def setup
        spec.include('wx/generic/aboutdlgg.h')
        spec.add_swig_code('%typemap(check) wxWindow* parent "";') # overrule common typemap to allow default NULL
        super
      end
    end # class AboutDialogInfo

  end # class Director

end # module WXRuby3
