###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class Cursor < Director

      def setup
        # all but the default ctor require a running App
        spec.require_app 'wxCursor::wxCursor(const wxString &, wxBitmapType, int, int)',
                         'wxCursor::wxCursor(wxStockCursor)',
                         'wxCursor::wxCursor(const wxImage &)',
                         'wxCursor::wxCursor(const char *const *)',
                         'wxCursor::wxCursor(const wxCursor &)'
        spec.ignore 'wxCursor::wxCursor(const char[],int,int,int,int,const char[])'
        # ignore stock object (see RubyStockObjects.i)
        spec.ignore %w[wxSTANDARD_CURSOR wxHOURGLASS_CURSOR wxCROSS_CURSOR]
        super
      end
    end # class Cursor

  end # class Director

end # module WXRuby3
