#--------------------------------------------------------------------
# @file    bitmap.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class Bitmap < Director

      def setup
        if Config.instance.wx_version > '3.1.5'
          spec.items << 'wxBitmapBundle'
          spec.gc_as_object 'wxBitmapBundle'
          spec.ignore 'wxBitmapBundle::FromSVG(char *,const wxSize &)'
        end
        spec.no_proxy 'wxBitmap'
        # // Handler functions are not needed in wxRuby - all standard handlers
        # // are loaded at startup, and we don't allow custom image handlers to be
        # // written in Ruby. Should someone want to add these methods, it will
        # // also require fixing freearg typemap for wxString to free correctly in
        # // static methods
        spec.ignore %w[
          wxBitmap::AddHandler
          wxBitmap::CleanUpHandlers
          wxBitmap::FindHandler
          wxBitmap::GetHandlers
          wxBitmap::InitStandardHandlers
          wxBitmap::InsertHandler
          wxBitmap::RemoveHandler
          ]
        # problematic and not really useful in Ruby
        spec.ignore('wxBitmap::wxBitmap(const char[],int,int,int)',
                    'wxBitmap::wxBitmap(const char *const *)')
        # // wxPalette not supported in wxRuby
        spec.ignore 'wxBitmap::SetPalette'
        if Config.instance.platform == :mingw
          spec.ignore 'wxBitmap::UseAlpha'
          spec.add_extend_code 'wxBitmap', <<~__HEREDOC
            // wxw documentation incorrectly declares this method
            // with a 'bool' return type which should be void
            void use_alpha(bool val)
            {
              $self->UseAlpha(val);
            }
            __HEREDOC
        end
        spec.disown 'wxMask* mask'
        super
      end
    end # class Bitmap

  end # class Director

end # module WXRuby3
