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
