###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
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
      end
    end # class AboutDialogInfo

  end # class Director

end # module WXRuby3
