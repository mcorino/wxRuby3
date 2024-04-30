# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Cursor < Director

      def setup
        spec.gc_as_untracked 'wxCursor'
        # all but the default ctor require a running App
        spec.require_app 'wxCursor::wxCursor(const wxString &, wxBitmapType, int, int)',
                         'wxCursor::wxCursor(wxStockCursor)',
                         'wxCursor::wxCursor(const wxImage &)',
                         'wxCursor::wxCursor(const char *const *)',
                         'wxCursor::wxCursor(const wxCursor &)'
        spec.ignore 'wxCursor::wxCursor(const char *const *)'
        if Config.instance.wx_version >= '3.3.0'
          spec.ignore 'wxCursor::wxCursor(const char[],int,int,int,int,const char[], const wxColour*, const wxColour*)'
        else
          spec.ignore 'wxCursor::wxCursor(const char[],int,int,int,int,const char[])'
        end
        # ignore stock object (see RubyStockObjects.i)
        spec.ignore %w[wxSTANDARD_CURSOR wxHOURGLASS_CURSOR wxCROSS_CURSOR]
        super
      end
    end # class Cursor

  end # class Director

end # module WXRuby3
