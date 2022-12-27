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
          # disable the wxBitmapBundle typemap for the copy constructor
          spec.map_disable 'const wxBitmapBundle&'
          # add typemap for bitmap vectors
          spec.map 'const wxVector<wxBitmap> &' do
            map_in from: 'Array<Wx::Bitmap>', temp: 'wxVector<wxBitmap> tmpVec', code: <<~__CODE
              $1 = &tmpVec;
              if (TYPE($input) == T_ARRAY)
              {
                for (int i = 0; i < RARRAY_LEN($input); i++)
                {
                  void* ptr;
                  VALUE obj = rb_ary_entry($input, i);
                  int res = SWIG_ConvertPtr(obj, &ptr, SWIGTYPE_p_wxBitmap, 0);
                  if (!SWIG_IsOK(res)) 
                  {
                    SWIG_exception_fail(SWIG_ArgError(res), "Expected array of Wx::Bitmap for argument 1"); 
                  }
                  tmpVec.push_back (*static_cast<wxBitmap*> (ptr));
                }
              }
              else
              {
                SWIG_exception_fail(SWIG_TypeError, "Wrong type for $1_basetype parameter $argnum");
              }
              __CODE
          end
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
