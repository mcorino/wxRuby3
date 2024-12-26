# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class AboutDialogInfo < Director

      def setup
        spec.include('wx/generic/aboutdlgg.h')
        # overrule common typemap to allow default NULL
        spec.map 'wxWindow* parent' do
          map_check code: ''
        end
        super
        spec.ignore 'wxGenericAboutBox' # wrapped with wxGenericAboutDialog
      end
    end # class AboutDialogInfo

  end # class Director

end # module WXRuby3
