# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class GridCtrl < Window

      include Typemap::GridCoords

      def setup
        # replace before calling super
        spec.items.replace %w[wxGrid wxGridBlockCoords wxGridBlockDiffResult wxGridSizesInfo wxGridFitMode]
        super
        spec.gc_as_untracked %w[wxGridBlockCoords wxGridBlockDiffResult wxGridSizesInfo wxGridFitMode]
        spec.gc_as_window 'wxGrid'
        spec.override_inheritance_chain('wxGrid', %w[wxScrolledCanvas wxWindow wxEvtHandler wxObject])
        spec.no_proxy 'wxGrid::SendAutoScrollEvents'
        # All of the methods have alternate versions that accept row, col pair
        # of integers, so these are redundant
        spec.ignore 'wxGrid::CellToRect(const wxGridCellCoords &)'
        spec.ignore 'wxGrid::GetCellValue(const wxGridCellCoords &)'
        spec.ignore 'wxGrid::GetDefaultEditorForCell(const wxGridCellCoords &) const'
        spec.ignore 'wxGrid::IsInSelection(const wxGridCellCoords &) const'
        spec.ignore 'wxGrid::IsVisible(const wxGridCellCoords &,bool)'
        spec.ignore 'wxGrid::MakeCellVisible(const wxGridCellCoords &)'
        spec.ignore 'wxGrid::SelectBlock(const wxGridCellCoords &,const wxGridCellCoords &,bool)'
        spec.ignore 'wxGrid::SetCellValue(const wxGridCellCoords &,const wxString &)'
        # these have overloads that have more useful returns
        spec.ignore 'wxGrid::CalcGridWindowUnscrolledPosition(int,int,int *,int *,const wxGridWindow *) const',
                    'wxGrid::CalcGridWindowScrolledPosition(int,int,int *,int *,const wxGridWindow *) const'
        # deprecated
        spec.ignore 'wxGrid::SetCellAlignment(int,int,int)'
        spec.ignore 'wxGrid::SetCellTextColour(const wxColour &)'
        spec.ignore 'wxGrid::SetCellTextColour(const wxColour &,int,int)'
        spec.ignore 'wxGrid::SetCellValue(const wxString &,int,int)'
        spec.ignore 'wxGrid::SetTable' # there is wxGrid::AssignTable now that always takes ownership

        spec.regard 'wxGrid::CanHaveAttributes',
                    'wxGrid::GetColMinimalWidth',
                    'wxGrid::GetColRight',
                    'wxGrid::GetColLeft',
                    'wxGrid::GetRowMinimalHeight'

        spec.regard 'wxGridSizesInfo::m_sizeDefault',
                    'wxGridSizesInfo::m_customSizes'
        spec.rename_for_ruby 'size_default' => 'wxGridSizesInfo::m_sizeDefault',
                             'custom_sizes' => 'wxGridSizesInfo::m_customSizes'
        spec.map 'wxUnsignedToIntHashMap' => 'Hash' do
          add_header_code <<~__CODE
            #if RUBY_API_VERSION_MAJOR<3 && RUBY_API_VERSION_MINOR<7
            typedef int (*rb_foreach_func)(ANYARGS);
            #else
            typedef int (*rb_foreach_func)(VALUE, VALUE, VALUE);
            #endif
            #define FOREACH_FUNC(x) reinterpret_cast<rb_foreach_func>((void*)&(x))
            static int _wxrb_cvt_custom_sizes(VALUE key, VALUE value, VALUE rbWxMap)
            {
              wxUnsignedToIntHashMap* wxMap;
              Data_Get_Struct(rbWxMap, wxUnsignedToIntHashMap, wxMap);
              (*wxMap)[NUM2UINT(key)] = NUM2INT(value);
              return ST_CONTINUE;
            }
            __CODE
          map_in code: <<~__CODE
            if (TYPE($input) == T_HASH)
            {
              void* ptr = &($1);
              VALUE rbWxMap = Data_Wrap_Struct(rb_cObject, 0, 0, ptr);
              rb_hash_foreach($input, FOREACH_FUNC(_wxrb_cvt_custom_sizes), rbWxMap);
            }
            else
            {
              rb_raise(rb_eArgError, "Expected Hash for %d", $argnum-1);
            }
            __CODE

          map_out code: <<~__CODE
            $result = rb_hash_new();
            wxUnsignedToIntHashMap::const_iterator it = $1.begin();
            for (; it != $1.end() ;++it)
            {
              rb_hash_aset($result, UINT2NUM(it->first), INT2NUM(it->second));
            } 
            __CODE
        end

        spec.ignore 'wxGrid::GetSelectedBlocks', ignore_doc: false  # ignore
        spec.map 'wxGridBlocks' => 'Array<Wx::GRID::GridBlockCoords>', swig: false do
          map_out code: ''
        end
        # add rubified API (finish in pure Ruby)
        spec.add_extend_code 'wxGrid', <<~__HEREDOC
          VALUE each_selected_block()
          {
            VALUE rc = Qnil;
            if (rb_block_given_p())
            {
              wxGridBlocks sel = $self->GetSelectedBlocks();
              for (const wxGridBlockCoords& gbc : sel)
              {
                rc = rb_yield (SWIG_NewPointerObj(new wxGridBlockCoords(gbc), SWIGTYPE_p_wxGridBlockCoords, SWIG_POINTER_OWN));
              }
            }
            return rc;  
          }

          VALUE each_selected_row_block()
          {
            VALUE rc = Qnil;
            if (rb_block_given_p())
            {
              wxGridBlockCoordsVector sel = $self->GetSelectedRowBlocks();
              for (const wxGridBlockCoords& gbc : sel)
              {
                rc = rb_yield (SWIG_NewPointerObj(new wxGridBlockCoords(gbc), SWIGTYPE_p_wxGridBlockCoords, SWIG_POINTER_OWN));
              }
            }
            return rc;  
          }

          VALUE each_selected_col_block()
          {
            VALUE rc = Qnil;
            if (rb_block_given_p())
            {
              wxGridBlockCoordsVector sel = $self->GetSelectedColBlocks();
              for (const wxGridBlockCoords& gbc : sel)
              {
                rc = rb_yield (SWIG_NewPointerObj(new wxGridBlockCoords(gbc), SWIGTYPE_p_wxGridBlockCoords, SWIG_POINTER_OWN));
              }
            }
            return rc;  
          }
          __HEREDOC

        spec.ignore 'wxGrid::GetGridWindowOffset(const wxGridWindow *, int &, int &) const'

        spec.add_header_code <<~__HEREDOC
          typedef wxGrid::wxGridSelectionModes wxGridSelectionModes;
          typedef wxGrid::CellSpan CellSpan;
          typedef wxGrid::TabBehaviour TabBehaviour;
          __HEREDOC

        spec.map 'wxGridBlockCoordsVector' => 'Array<Wx::GRID::GridBlockCoords>' do
          map_out code: <<~__CODE
            $result = rb_ary_new();
            for (const wxGridBlockCoords& gbc: $1)
            {
              rb_ary_push($result, SWIG_NewPointerObj(new wxGridBlockCoords(gbc), SWIGTYPE_p_wxGridBlockCoords, SWIG_POINTER_OWN));
            }
            __CODE
        end

        # Needed for methods that return cell and label alignments and other argout type mappings
        spec.map_apply 'int *OUTPUT' => [ 'int *horiz', 'int *vert' ,
                                          'int *num_rows', 'int *num_cols' ]
        # If invalid grid-cell co-ordinates are passed into wxWidgets,
        # segfaults may result, so check to avoid this.
        spec.map 'int row', 'int col' do
          map_check code: <<~__CODE
            if ( $1 < 0 )
              rb_raise(rb_eIndexError, "Negative grid cell co-ordinate is not valid");
            __CODE
        end
        spec.add_swig_code <<~__HEREDOC
          enum wxGridSelectionModes;
          enum CellSpan;
          enum TabBehaviour;
          __HEREDOC
        spec.ignore 'wxGrid::GetOrCreateCellAttrPtr'  # ignore this variant
        # wxWidgets takes over managing the ref count
        spec.disown('wxGridTableBase* table')
        # customize mark function to handle safeguarding any customized Grid tables installed
        spec.add_header_code <<~__HEREDOC
          WXRUBY_TRACE_GUARD(WxRubyTraceGCMarkGrid, "GC_MARK_GRID")

          static void GC_mark_wxGridCtrl(void* ptr) 
          {
            WXRUBY_TRACE_IF(WxRubyTraceGCMarkGrid, 2)
              WXRUBY_TRACE("> GC_mark_wxGridCtrl : " << ptr)
            WXRUBY_TRACE_END

            if ( GC_IsWindowDeleted(ptr) )
            {
              return;
            }
            // Do standard marking routines as for all wxWindows
            GC_mark_wxWindow(ptr);
            
            // check grid table base marking need 
            wxGrid* wx_gc = (wxGrid*) ptr;
            wxGridTableBase* wx_gtbl = wx_gc->GetTable();
            VALUE rb_gtbl = SWIG_RubyInstanceFor(wx_gtbl);
            if (!NIL_P(rb_gtbl))
            {
              WXRUBY_TRACE_IF(WxRubyTraceGCMarkGrid, 3)
                WXRUBY_TRACE("| GC_mark_wxGridCtrl : marking gridtable " << wx_gtbl << " -> " << rb_gtbl);
              WXRUBY_TRACE_END

              rb_gc_mark(rb_gtbl);
            }

            WXRUBY_TRACE_IF(WxRubyTraceGCMarkGrid, 2)
              WXRUBY_TRACE("< GC_mark_wxGridCtrl : " << ptr)
            WXRUBY_TRACE_END
          }
        __HEREDOC
        spec.add_swig_code '%markfunc wxGrid "GC_mark_wxGridCtrl";'
        # these require wxRuby to take ownership (ref counted)
        spec.new_object('wxGrid::GetOrCreateCellAttr',
                        'wxGrid::GetCellEditor',
                        'wxGrid::GetDefaultEditor',
                        'wxGrid::GetDefaultEditorForCell',
                        'wxGrid::GetDefaultEditorForType',
                        'wxGrid::GetCellRenderer',
                        'wxGrid::GetDefaultRenderer',
                        'wxGrid::GetDefaultRendererForCell',
                        'wxGrid::GetDefaultRendererForType')
        # handled; can be suppressed
        spec.suppress_warning(473,
                              'wxGrid::GetDefaultEditorForCell',
                              'wxGrid::GetDefaultEditorForType',
                              'wxGrid::GetDefaultRendererForCell',
                              'wxGrid::GetDefaultRendererForType')

        # create a lightweight, but typesafe, wrapper for wxGridWindow
        spec.add_init_code <<~__HEREDOC
          // define wxGridWindow wrapper class
          mWxGridWindow = rb_define_class_under(mWxGRID, "GridWindow", rb_cObject);
          rb_undef_alloc_func(mWxGridWindow);
          __HEREDOC

        spec.add_header_code <<~__HEREDOC
          VALUE mWxGridWindow;

          // wxGridWindow wrapper class definition and helper functions
          static size_t __wxGridWindow_size(const void* data)
          {
            return 0;
          }

          #include <ruby/version.h> 

          static const rb_data_type_t __wxGridWindow_type = {
            "GridWindow",
          #if RUBY_API_VERSION_MAJOR >= 3
            { NULL, NULL, __wxGridWindow_size, 0, {}},
          #else
            { NULL, NULL, __wxGridWindow_size, {}},
          #endif 
            NULL, NULL, RUBY_TYPED_FREE_IMMEDIATELY
          };

          VALUE _wxRuby_Wrap_wxGridWindow(wxGridWindow* gw)
          {
            if (gw)
            {
              void* data = gw;
              VALUE ret = TypedData_Wrap_Struct(mWxGridWindow, &__wxGridWindow_type, data);
              return ret;
            }
            else
              return Qnil;
          } 

          wxGridWindow* _wxRuby_Unwrap_wxGridWindow(VALUE rbgw)
          {
            if (NIL_P(rbgw))
              return nullptr;
            else
            {
              void *data = 0;
              TypedData_Get_Struct(rbgw, void, &__wxGridWindow_type, data);
              return reinterpret_cast<wxGridWindow*> (data);
            }
          }

          bool _wxRuby_Is_wxGridWindow(VALUE rbgw)
          {
            return rb_typeddata_is_kind_of(rbgw, &__wxGridWindow_type) == 1;
          } 
          __HEREDOC

        spec.map 'wxGridWindow*' => 'Wx::GRID::GridWindow' do
          map_in code: '$1 = _wxRuby_Unwrap_wxGridWindow($input);'
          map_out code: '$result = _wxRuby_Wrap_wxGridWindow($1);'
          map_typecheck code: '$1 = _wxRuby_Is_wxGridWindow($input);'
        end

        # Add custom code to handle GC marking for Grid cell attributes, editors and renderers.
        # Ruby created instances of these are registered in global tables whenever they are assigned to
        # a Grid (for a cell, default or named type). The global tables will be scanned during the GC marking stage
        # and any registered instances marked.
        # We define specialized wxClientData derivatives for the three types of classes we need to
        # manage GC for which are associated with an attribute/editor/renderer instance through SetClientObject()
        # at the moment of registration (which is actually performed on creation of the client data object).
        # Whenever an attribute/editor/renderer is deleted (bc it's ref count reached zero) it will also delete
        # the associated client data object which will at that moment deregister the associated attribute/editor
        # or renderer instance from the global table thus freeing it for GC collection.
        spec.add_header_code <<~__HEREDOC
          #include <wx/clntdata.h>

          WXRUBY_TRACE_GUARD(WxRubyTraceGCMarkGridCellAttr, "GC_MARK_GRID_CELL_ATTR")
          WXRUBY_TRACE_GUARD(WxRubyTraceGCTrackGridCellAttr, "GC_TRACK_GRID_CELL_ATTR")
          WXRUBY_TRACE_GUARD(WxRubyTraceGCMarkGridCellEditor, "GC_MARK_GRID_CELL_EDITOR")
          WXRUBY_TRACE_GUARD(WxRubyTraceGCTrackGridCellEditor, "GC_TRACK_GRID_CELL_EDITOR")
          WXRUBY_TRACE_GUARD(WxRubyTraceGCMarkGridCellRenderer, "GC_MARK_GRID_CELL_RENDERER")
          WXRUBY_TRACE_GUARD(WxRubyTraceGCTrackGridCellRenderer, "GC_TRACK_GRID_CELL_RENDERER")

          static const std::string WXRUBY_GRID_CELL_ATTR = { "WXRUBY_GRID_CELL_ATTR" };

          // define the grid cell attribute marker
          static void wxRuby_markGridCellAttr(const TGCTrackingValueMap& values)
          {
            WXRUBY_TRACE_IF(WxRubyTraceGCMarkGridCellAttr, 2)
              WXRUBY_TRACE("> wxRuby_markGridCellAttr")
            WXRUBY_TRACE_END

            for(const auto& ti : values)
            {
              VALUE obj = ti.second;

              WXRUBY_TRACE_IF(WxRubyTraceGCMarkGridCellAttr, 2)
                WXRUBY_TRACE_WITH(void *c_ptr = (TYPE(obj) == T_DATA ? DATA_PTR(obj) : 0))
                WXRUBY_TRACE("| wxRuby_markGridCellAttr : " << ti.first << "|" << (void*)c_ptr)
              WXRUBY_TRACE_END

              rb_gc_mark(obj);
            }

            WXRUBY_TRACE_IF(WxRubyTraceGCMarkGridCellAttr, 2)
              WXRUBY_TRACE("< wxRuby_markGridCellAttr")
            WXRUBY_TRACE_END
          }

          static void wxRuby_UnregisterGridCellAttr(wxGridCellAttr* wx_attr)
          {
            WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellAttr, 2)
              WXRUBY_TRACE("> wxRuby_UnregisterGridCellAttr : " << wx_attr << " -> " << wxRuby_FindCategoryValue(WXRUBY_GRID_CELL_ATTR, wx_attr))
            WXRUBY_TRACE_END

            wxRuby_UnlinkCategoryValue(WXRUBY_GRID_CELL_ATTR, wx_attr);
            wxRuby_UnregisterCategoryValue(WXRUBY_GRID_CELL_ATTR, wx_attr);

            WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellAttr, 2)
              WXRUBY_TRACE("< wxRuby_UnregisterGridCellAttr : " << wx_attr)
            WXRUBY_TRACE_END
          }

          extern VALUE wxRuby_GridCellAttrInstance(wxGridCellAttr* wx_attr)
          {
            return wxRuby_FindCategoryValue(WXRUBY_GRID_CELL_ATTR, wx_attr);
          }

          // specialized client data class
          class WXRBGridCellAttrMonitor : public wxClientData
          {
          public:
            WXRBGridCellAttrMonitor() : wx_attr(0), rb_attr(Qnil) {}
            WXRBGridCellAttrMonitor(wxGridCellAttr* a, VALUE v) : wx_attr(a), rb_attr(v) 
            { wxRuby_RegisterCategoryValue(WXRUBY_GRID_CELL_ATTR, wx_attr, rb_attr); }
            virtual ~WXRBGridCellAttrMonitor()
            { wxRuby_UnregisterGridCellAttr(wx_attr); }
          private:
            wxGridCellAttr* wx_attr;
            VALUE           rb_attr;
          };

          // and it's associated registration/de-registration functions
          extern void wxRuby_RegisterGridCellAttr(wxGridCellAttr* wx_attr, VALUE rb_attr)
          {
            static bool is_marker_registered = false;

            WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellAttr, 2)
              WXRUBY_TRACE("> wxRuby_RegisterGridCellAttr : " << wx_attr << " -> " << rb_attr)
            WXRUBY_TRACE_END

            if (wx_attr && !NIL_P(rb_attr))
            {
              if (!is_marker_registered)
              {
                wxRuby_RegisterTrackingCategory(WXRUBY_GRID_CELL_ATTR, wxRuby_markGridCellAttr, true);
                is_marker_registered = true;
              }
 
              // see if this attr is already tracked 
              if (wxRuby_FindCategoryValue(WXRUBY_GRID_CELL_ATTR, wx_attr) == Qnil)
              {
                WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellAttr, 2)
                  WXRUBY_TRACE("| wxRuby_RegisterGridCellAttr : installing monitor")
                WXRUBY_TRACE_END

                // either a new Ruby created instance or an unwrapped C++ created instance 
                // always disown; wxWidgets takes over or keeps ownership of reference count
                RDATA(rb_attr)->dfree = 0;

                wx_attr->SetClientObject(new WXRBGridCellAttrMonitor(wx_attr, rb_attr));
              }
              else  // already registered; will be disowned already
              {
                // increase the reference count for C++ to take over
                wx_attr->IncRef();
              }
            }

            WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellAttr, 2)
              WXRUBY_TRACE("< wxRuby_RegisterGridCellAttr : " << wx_attr)
            WXRUBY_TRACE_END
          }

          static const std::string WXRUBY_GRID_CELL_EDITOR = { "WXRUBY_GRID_CELL_EDITOR" };

          // define the grid cell editor marker
          static void wxRuby_markGridCellEditor(const TGCTrackingValueMap& values)
          {
            WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellEditor, 2)
              WXRUBY_TRACE("> wxRuby_markGridCellEditor")
            WXRUBY_TRACE_END

            for(const auto& ti : values)
            {
              VALUE obj = ti.second;

              WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellEditor, 2)
                WXRUBY_TRACE_WITH(void *c_ptr = (TYPE(obj) == T_DATA ? DATA_PTR(obj) : 0))
                WXRUBY_TRACE("| wxRuby_markGridCellEditor : " << it->first << "|" << (void*)c_ptr)
              WXRUBY_TRACE_END

              rb_gc_mark(obj);
            }

            WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellEditor, 2)
              WXRUBY_TRACE("< wxRuby_markGridCellEditor")
            WXRUBY_TRACE_END
          }

          static void wxRuby_UnregisterGridCellEditor(wxGridCellEditor* wx_edt)
          {
            WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellEditor, 2)
              WXRUBY_TRACE("> wxRuby_UnregisterGridCellEditor : " << wx_edt << " -> " << wxRuby_FindCategoryValue(WXRUBY_GRID_CELL_EDITOR, wx_edt))
            WXRUBY_TRACE_END

            wxRuby_UnlinkCategoryValue(WXRUBY_GRID_CELL_EDITOR, wx_edt);
            wxRuby_UnregisterCategoryValue(WXRUBY_GRID_CELL_EDITOR, wx_edt);

            WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellEditor, 2)
              WXRUBY_TRACE("< wxRuby_UnregisterGridCellEditor : " << wx_edt)
            WXRUBY_TRACE_END
          }

          extern VALUE wxRuby_GridCellEditorInstance(wxGridCellEditor* wx_edt)
          {
            return wxRuby_FindCategoryValue(WXRUBY_GRID_CELL_EDITOR, wx_edt);
          }

          // specialized client data class
          class WXRBGridCellEditorMonitor : public wxClientData
          {
          public:
            WXRBGridCellEditorMonitor() : wx_edt(0), rb_edt(Qnil) {}
            WXRBGridCellEditorMonitor(wxGridCellEditor* a, VALUE v) : wx_edt(a), rb_edt(v) 
            { wxRuby_RegisterCategoryValue(WXRUBY_GRID_CELL_EDITOR, wx_edt, rb_edt); }
            virtual ~WXRBGridCellEditorMonitor()
            { wxRuby_UnregisterGridCellEditor(wx_edt); }
          private:
            wxGridCellEditor* wx_edt;
            VALUE             rb_edt;
          };

          // and it's associated registration function
          extern void wxRuby_RegisterGridCellEditor(wxGridCellEditor* wx_edt, VALUE rb_edt)
          {
            static bool is_marker_registered = false;

            WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellEditor, 2)
              WXRUBY_TRACE("> wxRuby_RegisterGridCellEditor : " << wx_edt << " -> " << rb_edt)
            WXRUBY_TRACE_END

            if (wx_edt && !NIL_P(rb_edt))
            {
              if (!is_marker_registered)
              {
                wxRuby_RegisterTrackingCategory(WXRUBY_GRID_CELL_EDITOR, wxRuby_markGridCellEditor, true);
                is_marker_registered = true;
              }
 
              // see if this renderer is already tracked 
              if (wxRuby_FindCategoryValue(WXRUBY_GRID_CELL_EDITOR, wx_edt) == Qnil)
              {
                WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellEditor, 2)
                  WXRUBY_TRACE("| wxRuby_RegisterGridCellEditor : installing monitor")
                WXRUBY_TRACE_END

                // either a new Ruby created instance or an unwrapped C++ created instance 
                // always disown; wxWidgets takes over or keeps ownership of reference count
                RDATA(rb_edt)->dfree = 0;

                wx_edt->SetClientObject(new WXRBGridCellEditorMonitor(wx_edt, rb_edt));
              }
              else  // already registered; will be disowned already
              {
                // increase the reference count for C++ to take over
                wx_edt->IncRef();
              }
            }

            WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellEditor, 2)
              WXRUBY_TRACE("< wxRuby_RegisterGridCellEditor : " << wx_edt)
            WXRUBY_TRACE_END
          }

          static const std::string WXRUBY_GRID_CELL_RENDERER = { "WXRUBY_GRID_CELL_RENDERER" };

          // define the grid cell renderer marker
          static void wxRuby_markGridCellRenderer(const TGCTrackingValueMap& values)
          {
            WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellRenderer, 2)
              WXRUBY_TRACE("> wxRuby_markGridCellRenderer")
            WXRUBY_TRACE_END

            for(const auto& ti : values)
            {
              VALUE obj = ti.second;

              WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellRenderer, 2)
                WXRUBY_TRACE_WITH(void *c_ptr = (TYPE(obj) == T_DATA ? DATA_PTR(obj) : 0))
                WXRUBY_TRACE("| wxRuby_markGridCellRenderer : " << it->first << "|" << (void*)c_ptr)
              WXRUBY_TRACE_END

              rb_gc_mark(obj);
            }

            WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellRenderer, 2)
              WXRUBY_TRACE("< wxRuby_markGridCellRenderer")
            WXRUBY_TRACE_END
          }

          static void wxRuby_UnregisterGridCellRenderer(wxGridCellRenderer* wx_rnd)
          {
            WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellRenderer, 2)
              WXRUBY_TRACE("> wxRuby_UnregisterGridCellRenderer : " << wx_rnd << " -> " << wxRuby_FindCategoryValue(WXRUBY_GRID_CELL_RENDERER, wx_rnd))
            WXRUBY_TRACE_END

            wxRuby_UnlinkCategoryValue(WXRUBY_GRID_CELL_RENDERER, wx_rnd);
            wxRuby_UnregisterCategoryValue(WXRUBY_GRID_CELL_RENDERER, wx_rnd);

            WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellRenderer, 2)
              WXRUBY_TRACE("< wxRuby_UnregisterGridCellRenderer : " << wx_rnd)
            WXRUBY_TRACE_END
          }

          extern VALUE wxRuby_GridCellRendererInstance(wxGridCellRenderer* wx_rnd)
          {
            return wxRuby_FindCategoryValue(WXRUBY_GRID_CELL_RENDERER, wx_rnd);
          }

          // specialized client data class
          class WXRBGridCellRendererMonitor : public wxClientData
          {
          public:
            WXRBGridCellRendererMonitor() : wx_rnd(0), rb_rnd(Qnil) {}
            WXRBGridCellRendererMonitor(wxGridCellRenderer* a, VALUE v) : wx_rnd(a), rb_rnd(v) 
            { wxRuby_RegisterCategoryValue(WXRUBY_GRID_CELL_RENDERER, wx_rnd, rb_rnd); }
            virtual ~WXRBGridCellRendererMonitor()
            { wxRuby_UnregisterGridCellRenderer(wx_rnd); }
          private:
            wxGridCellRenderer* wx_rnd;
            VALUE               rb_rnd;
          };

          // and it's associated registration/de-registration functions
          extern void wxRuby_RegisterGridCellRenderer(wxGridCellRenderer* wx_rnd, VALUE rb_rnd)
          {
            static bool is_marker_registered = false;

            WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellRenderer, 2)
              WXRUBY_TRACE("> wxRuby_RegisterGridCellRenderer : " << wx_rnd << " -> " << rb_rnd)
            WXRUBY_TRACE_END

            if (wx_rnd && !NIL_P(rb_rnd))
            {
              if (!is_marker_registered)
              {
                wxRuby_RegisterTrackingCategory(WXRUBY_GRID_CELL_RENDERER, wxRuby_markGridCellRenderer, true);
                is_marker_registered = true;
              }
 
              // see if this renderer is already tracked 
              if (wxRuby_FindCategoryValue(WXRUBY_GRID_CELL_RENDERER, wx_rnd) == Qnil)
              {
                WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellRenderer, 2)
                  WXRUBY_TRACE("| wxRuby_RegisterGridCellRenderer : installing monitor")
                WXRUBY_TRACE_END

                // either a new Ruby created instance or an unwrapped C++ created instance 
                // always disown; wxWidgets takes over or keeps ownership of reference count
                RDATA(rb_rnd)->dfree = 0;

                wx_rnd->SetClientObject(new WXRBGridCellRendererMonitor(wx_rnd, rb_rnd));
              }
              else  // already registered; will be disowned already
              {
                // increase the reference count for C++ to take over
                wx_rnd->IncRef();
              }
            }

            WXRUBY_TRACE_IF(WxRubyTraceGCTrackGridCellRenderer, 2)
              WXRUBY_TRACE("< wxRuby_RegisterGridCellRenderer : " << wx_rnd)
            WXRUBY_TRACE_END
          }

          __HEREDOC
        # add type mappings to handle registration
        # first declare 'normal' type mapping for const pointer (for DrawCellHighlight)
        spec.map 'const wxGridCellAttr *'  => 'Wx::GRID::GridCellAttr' do
          map_check code: ''  # do nothing; this instance does not get managed by wxWidgets
        end
        # next handle registering mappings
        spec.map 'wxGridCellAttr *' => 'Wx::GRID::GridCellAttr' do
          map_out code: <<~__CODE
            $result = wxRuby_GridCellAttrInstance($1); // check for already registered instance
            if (NIL_P($result))
            {
              // As this editor was created in C++ it seems we have no registration yet
              // but the reference counter will be at least 2 now (1 for C++ owner and 1
              // increment for returning to us).
              // We will now register a new Ruby object, keep it disowned and decrement
              // for now. If passing to C++ again we will increment there.     
              $result = SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_wxGridCellAttr, 0);
              wxRuby_RegisterGridCellAttr($1, $result);
              $1->DecRef();
            }
            else
            {
              // as this cell attr got passed from C++ it wll have incremented it's reference counter
              // decrease that here; if we pass it back to C++ we will increase there
              $1->DecRef();
            }
            __CODE
          map_check code: 'wxRuby_RegisterGridCellAttr($1, argv[$argnum-2]);'
        end
        spec.map 'wxGridCellEditor *' => 'Wx::GRID::GridCellEditor' do
          add_header_code 'extern VALUE wxRuby_WrapWxGridCellEditorInRuby(const wxGridCellEditor *wx_gce);'
          map_out code: '$result = wxRuby_WrapWxGridCellEditorInRuby($1);'
          map_check code: 'wxRuby_RegisterGridCellEditor($1, argv[$argnum-2]);'
        end
        spec.map 'wxGridCellRenderer *' => 'Wx::GRID::GridCellRenderer' do
          add_header_code 'extern VALUE wxRuby_WrapWxGridCellRendererInRuby(const wxGridCellRenderer *wx_gcr);'
          map_out code: '$result = wxRuby_WrapWxGridCellRendererInRuby($1);'
          map_check code: 'wxRuby_RegisterGridCellRenderer($1, argv[$argnum-2]);'
        end
        # add constants missing from documentation
        spec.add_swig_code '%constant char* wxGRID_VALUE_STRING = "string";',
                           '%constant char* wxGRID_VALUE_BOOL = "bool";',
                           '%constant char* wxGRID_VALUE_NUMBER = "long";',
                           '%constant char* wxGRID_VALUE_FLOAT = "double";',
                           '%constant char* wxGRID_VALUE_CHOICE = "choice";',
                           '%constant char* wxGRID_VALUE_DATE = "date";',
                           '%constant char* wxGRID_VALUE_TEXT = "string";',
                           '%constant char* wxGRID_VALUE_LONG = "long";'
        # fix naming mismatch with #evt_grid_cmd_col_size
        spec.add_swig_code '%constant int EVT_GRID_CMD_COL_SIZE = wxEVT_GRID_COL_SIZE;',
                           '%constant int EVT_GRID_CMD_ROW_SIZE = wxEVT_GRID_ROW_SIZE;',
                           '%constant int EVT_GRID_CMD_EDITOR_CREATED = wxEVT_GRID_EDITOR_CREATED;',
                           '%constant int EVT_GRID_CMD_RANGE_SELECTING = wxEVT_GRID_RANGE_SELECTING;',
                           '%constant int EVT_GRID_CMD_RANGE_SELECTED = wxEVT_GRID_RANGE_SELECTED;'
      end

      def doc_generator
        GridCtrlDocGenerator.new(self)
      end
    end # class GridCtrl

  end # class Director

  class GridCtrlDocGenerator < DocGenerator

    protected def gen_constants_doc(fdoc)
      super
      xref_table = package.all_modules.reduce(DocGenerator.constants_db) { |db, mod| db[mod] }
      gen_constant_doc(fdoc, 'EVT_GRID_CMD_COL_SIZE', xref_table['EVT_GRID_COL_SIZE'], 'wxRuby specific alias for Wx::EVT_GRID_COL_SIZE')
      gen_constant_doc(fdoc, 'EVT_GRID_CMD_ROW_SIZE', xref_table['EVT_GRID_ROW_SIZE'], 'wxRuby specific alias for Wx::EVT_GRID_ROW_SIZE')
      gen_constant_doc(fdoc, 'EVT_GRID_CMD_EDITOR_CREATED', xref_table['EVT_GRID_EDITOR_CREATED'], 'wxRuby specific alias for Wx::EVT_GRID_EDITOR_CREATED')
      gen_constant_doc(fdoc, 'EVT_GRID_CMD_RANGE_SELECTING', xref_table['EVT_GRID_RANGE_SELECTING'], 'wxRuby specific alias for Wx::wxEVT_GRID_RANGE_SELECTING')
      gen_constant_doc(fdoc, 'EVT_GRID_CMD_RANGE_SELECTED', xref_table['EVT_GRID_RANGE_SELECTED'], 'wxRuby specific alias for Wx::wxEVT_GRID_RANGE_SELECTED')
    end

  end

end # module WXRuby3
