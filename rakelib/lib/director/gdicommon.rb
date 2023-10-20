# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class GDICommon < Director

      def setup
        spec.items.replace %w{wxPoint wxSize wxRect wxRealPoint wxColourDatabase}
        # all ctors
        spec.require_app 'wxColourDatabase'
        # global functions
        spec.require_app %w[wxColourDisplay wxDisplayDepth wxSetCursor wxGetClientDisplayRect
                            wxGetDisplayPPI wxGetDisplaySize wxGetDisplaySizeMM]
        spec.ignore %w{
          wxTheColourDatabase
        }
        if Config.instance.wx_version >= '3.3.0'
          spec.ignore 'wxColourDatabase::GetAllNames', ignore_doc: false
          spec.add_extend_code 'wxColourDatabase', <<~__HEREDOC
            VALUE get_all_names() const
            {
              wxVector<wxString> nms = $self->GetAllNames();
              VALUE rb_nms = rb_ary_new();
              for (const wxString& nm : nms)
              {
                rb_ary_push(rb_nms, WXSTR_TO_RSTR(nm));
              } 
              return rb_nms;
            }
            __HEREDOC
          spec.map 'wxVector<wxString>' => 'Array<String>', swig: false do
            map_out code: ''
          end
        end
        spec.ignore [
          'wxClientDisplayRect(int *,int *,int *,int *)',
          'wxDisplaySize(int *,int *)',
          'wxDisplaySizeMM(int *,int *)',
          'wxRect::Inflate(wxCoord,wxCoord) const',
          'wxRect::Deflate(wxCoord,wxCoord) const',
          'wxRect::Intersect(const wxRect &)',
          'wxRect::Union(const wxRect &)'
        ]
        spec.regard 'wxRect::Offset', regard_doc: false
        # overrule common wxPoint mapping for wxRect ctor to fix ctor ambiguities here wrt wxSize
        spec.map 'const wxPoint& topLeft', 'const wxPoint& bottomRight', as: 'Wx::Point' do
          map_in code: <<~__CODE
            if ( TYPE($input) == T_DATA )
            {
              void* argp$argnum;
              SWIG_ConvertPtr($input, &argp$argnum, $1_descriptor, 1 );
              $1 = reinterpret_cast< $1_basetype * >(argp$argnum);
            }
            else
            {
              rb_raise(rb_eTypeError, "Wrong type for $1_basetype parameter");
            }
          __CODE
          map_typecheck precedence: 'POINTER', code: <<~__CODE
            void *vptr = 0;
            $1 = 0;
            if (TYPE($input) == T_DATA && SWIG_CheckState (SWIG_ConvertPtr ($input, &vptr, $1_descriptor, 0)))
              $1 = 1;
          __CODE
        end
        spec.map 'wxRect&' => 'Wx::Rect', 'wxSize&' => 'Wx::Size' do
          map_out code: '$result = self; wxUnusedVar(result);'
        end
        spec.regard %w[
          wxPoint::x wxPoint::y
          wxRealPoint::x wxRealPoint::y
          ]
        spec.ignore('wxStockCursor.wxCURSOR_DEFAULT') unless Config.instance.features_set?('__WXGTK__')
        unless Config.instance.features_set?('__X__')
          spec.ignore %w{
            wxStockCursor.wxCURSOR_CROSS_REVERSE
            wxStockCursor.wxCURSOR_DOUBLE_ARROW
            wxStockCursor.wxCURSOR_BASED_ARROW_UP
            wxStockCursor.wxCURSOR_BASED_ARROW_DOWN
          }
        end
        spec.ignore('wxStockCursor.wxCURSOR_COPY_ARROW') unless Config.instance.features_set?('__WXOSX__')
        spec.add_extend_code 'wxRect', <<~__HEREDOC
          wxRect add(const wxRect &rect) const {
            return (*(const wxRect*)$self) + rect;
          }
          wxRect mul(const wxRect &rect) const {
            return (*(const wxRect*)$self) * rect;
          }
        __HEREDOC
        spec.swig_import 'swig/classes/include/wxDefs.h'
        super
      end

      def process(gendoc: false)
        defmod = super
        e = defmod.find('wxBitmapType')
        e.items.each do |item|
          item.ignore if item.name.end_with?('_RESOURCE')
        end
        defmod
      end
    end # class GDICommon

  end # class Director

end # module WXRuby3
