# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class DragDrop < Director

      def setup
        super
        spec.items.replace %w[wxDropSource wxDropTarget wxFileDropTarget wxTextDropTarget dnd.h]
        spec.gc_as_object
        # wxWidgets will free the DataObject once it's owned by DropSource or DropTarget
        spec.disown 'wxDataObject* data'
        # special mark functions to preserve Ruby object during GC
        spec.add_header_code <<~__HEREDOC
          static void mark_wxDropTarget(void* ptr) 
          {
            if ( GC_IsWindowDeleted(ptr) ) return;
            
            wxDropTarget* drop_tgt = (wxDropTarget*)ptr;
            wxDataObject* data_obj = drop_tgt->GetDataObject();
            if ( data_obj )
              rb_gc_mark( SWIG_RubyInstanceFor(data_obj) );
          }

          static void mark_wxDropSource(void* ptr) 
          {
            if ( GC_IsWindowDeleted(ptr) ) return;
            
            wxDropSource* drop_src = (wxDropSource*)ptr;
            wxDataObject* data_obj = drop_src->GetDataObject();
            if ( data_obj )
              rb_gc_mark( SWIG_RubyInstanceFor(data_obj) );
          }
          __HEREDOC
        spec.add_swig_code '%markfunc wxDropSource "mark_wxDropSource";',
                           '%markfunc wxDropTarget "mark_wxDropTarget";'
        spec.extend_interface 'wxDropSource', 'virtual ~wxDropSource()' # correct interface omission
        # make Ruby director and wrappers use custom implementation
        spec.use_class_implementation('wxDropTarget', 'wxRubyDropTarget')
        spec.make_concrete('wxDropTarget')
        spec.no_proxy %w[wxDropTarget::OnData]  # prevent director overload; custom impl handles this
        spec.add_header_code <<~__HEREDOC
          class wxRubyDropTarget : public wxDropTarget
          {
          public:
            wxRubyDropTarget(wxDataObject *dataObject = nullptr ) : wxDropTarget(dataObject) {} 

            virtual wxDragResult OnData(wxCoord x, wxCoord y, wxDragResult dflt) override
            {
              static WxRuby_ID on_data_id("on_data");
              wxDragResult c_result = wxDragError;
              VALUE SWIGUNUSED result;
              
              VALUE rb_x = INT2NUM(static_cast< int >(x));
              VALUE rb_y = INT2NUM(static_cast< int >(y));
              VALUE rb_dflt = wxRuby_GetEnumValueObject("DragResult", static_cast<int>(dflt));
              if (rb_dflt == Qnil)
              {
                std::cerr << "Unexpected argument error: invalid value for Wx::DragResult in wxDropTarget::OnData [" << dflt << "]" << std::endl;
              }
              else
              {
                VALUE self = SWIG_RubyInstanceFor(this);
                bool ex = false;
                result = wxRuby_Funcall(ex, self, rb_intern("on_data"), 3,rb_x, rb_y, rb_dflt);
                if (ex)
                {
                  wxRuby_PrintException(result);
                }
                else
                {
                  int eval;
                  if (!wxRuby_GetEnumValue("DragResult", result, eval))
                  {
                    std::cerr << "Type Error: invalid value for Wx::DragResult returned from Wx::DropTarget#on_data" << std::endl;
                  }
                  else
                  {
                    c_result = static_cast<wxDragResult>(eval);
                  }
                }
              }
              return (wxDragResult) c_result;
            } 
          };
          __HEREDOC
        spec.ignore %w[wxFileDropTarget::OnDrop wxTextDropTarget::OnDrop]
        spec.no_proxy %w[wxFileDropTarget::OnDrop wxFileDropTarget::OnData]
        spec.no_proxy %w[wxTextDropTarget::OnDrop wxTextDropTarget::OnData]
        # type mapping for wxFileDropTarget::OnDropFiles
        spec.map 'const wxArrayString&' => 'Array<String>' do
          map_directorin code: <<~__CODE
            $input = rb_ary_new();
            for (size_t i = 0; i < $1.GetCount(); i++)
            {
              rb_ary_push($input, WXSTR_TO_RSTR($1.Item(i)));
            }
            __CODE
        end
      end
    end # class DragDrop

  end # class Director

end # module WXRuby3
