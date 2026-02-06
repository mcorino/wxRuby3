# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class PropertyGrid < Window

      include Typemap::PGProperty

      include Typemap::PGCell

      include Typemap::PGPropArg

      def setup
        super
        spec.gc_as_window 'wxPropertyGrid'
        spec.override_inheritance_chain('wxPropertyGrid', %w[wxScrolledControl wxControl wxWindow wxEvtHandler wxObject])
        spec.add_header_code 'typedef wxScrolled<wxControl> wxScrolledControl;'
        spec.no_proxy 'wxPropertyGrid::SendAutoScrollEvents',
                      'wxPropertyGrid::RefreshProperty',
                      'wxPropertyGrid::GetStatusBar'
        # not usable in wxRuby
        spec.ignore 'wxPropertyGrid::SetSortFunction',
                    'wxPropertyGrid::GetSortFunction'
        spec.ignore 'wxPropertyGrid::RegisterEditorClass' # defined in pure Ruby
        spec.disown 'wxPGEditor *editor' # for DoRegisterEditorClass
        # special doc-only mapping to remove this arg from docs as wxRuby always passes false here
        spec.map 'bool noDefCheck', swig: false do
          map_in ignore: true
        end
        # replace by custom extension
        spec.add_header_code <<~__HEREDOC
          static int wxRuby_PropertyGridSortFunction(wxPropertyGrid* pg, wxPGProperty* pp1, wxPGProperty* pp2)
          {
            static WxRuby_ID call_id("call");

            VALUE rb_pg = SWIG_RubyInstanceFor(pg);
            VALUE rb_pp1 = SWIG_NewPointerObj(SWIG_as_voidptr(pp1), SWIGTYPE_p_wxPGProperty, 0);
            VALUE rb_pp2 = SWIG_NewPointerObj(SWIG_as_voidptr(pp2), SWIGTYPE_p_wxPGProperty, 0);
            VALUE rb_sorter = rb_iv_get(rb_pg, "@__sorter");
            if (NIL_P(rb_sorter))
            {
              VALUE msg = rb_inspect(rb_pg);
              rb_raise(rb_eRuntimeError, "Nil @__sorter for %s",
                                         StringValuePtr(msg));
            }
            return INT2NUM(rb_funcall(rb_sorter, call_id(), 3, rb_pg, rb_pp1, rb_pp2));
          }
          __HEREDOC
        spec.add_extend_code 'wxPropertyGrid', <<~__HEREDOC
          void SetSorter(VALUE proc)
          {
            VALUE rb_self = SWIG_RubyInstanceFor(self);
            rb_iv_set(rb_self, "@__sorter", proc);
            self->SetSortFunction(wxRuby_PropertyGridSortFunction);
          }
          VALUE GetSorter()
          {
            VALUE rb_self = SWIG_RubyInstanceFor(self);
            return rb_iv_get(rb_self, "@__sorter");
          }
          __HEREDOC
        spec.add_swig_code 'typedef const wxPGPropArgCls& wxPGPropArg;'
        # mixin PropertyGridInterface
        spec.include_mixin 'wxPropertyGrid', 'Wx::PG::PropertyGridInterface'
        # customize mark function
        spec.add_header_code <<~__HEREDOC
          WXRUBY_EXPORT bool WXRuby_Is_In_GC_mark_wxPropertyGridManager();

          static void GC_mark_wxPropertyGrid(void* ptr) 
          {
          #ifdef __WXRB_DEBUG__
            if (wxRuby_TraceLevel()>1)
              std::wcout << "> GC_mark_wxPropertyGrid : " << ptr << std::endl;
          #endif
            if ( GC_IsWindowDeleted(ptr) )
            {
              return;
            }
            // Do standard marking routines as for all wxWindows
            GC_mark_wxWindow(ptr);
            
            // no need to mark properties if called from GC_mark_wxPropertyGridManager
            // as that will mark properties through the property grid pages
            if (WXRuby_Is_In_GC_mark_wxPropertyGridManager())
              return;

          #ifdef __WXRB_DEBUG__
            long l = 0, n = 0;
          #endif
            wxPropertyGrid* wx_pg = (wxPropertyGrid*) ptr;

            VALUE rb_root_prop = SWIG_RubyInstanceFor(wx_pg->GetRoot());
            if (!NIL_P(rb_root_prop))
            {
              rb_gc_mark(rb_root_prop);
          #ifdef __WXRB_DEBUG__
              ++n;
          #endif
            }
            // mark all properties
            wxPGVIterator it =
                wx_pg->GetVIterator(wxPG_ITERATOR_FLAGS_ALL | wxPG_IT_CHILDREN(wxPG_ITERATOR_FLAGS_ALL));
            // iterate all
            for ( ; !it.AtEnd(); it.Next() )
            {
          #ifdef __WXRB_DEBUG__
              ++l;
          #endif
              wxPGProperty* wx_p = it.GetProperty();
              VALUE rb_prop = SWIG_RubyInstanceFor(wx_p);
              if (!RB_NIL_P(rb_prop)) 
              {
                rb_gc_mark(rb_prop);
          #ifdef __WXRB_DEBUG__
                ++n;
          #endif
              }
            }
          #ifdef __WXRB_DEBUG__
            if (wxRuby_TraceLevel()>1)
              std::wcout << "GC_mark_wxPropertyGrid: iterated " << l << " properties; marked " << n << std::endl;
          #endif
          }
          __HEREDOC
        spec.add_swig_code '%markfunc wxPropertyGrid "GC_mark_wxPropertyGrid";'
        # missing from XML docs
        spec.extend_interface 'wxPropertyGrid',
                              'virtual bool Destroy()',
                              'wxPoint GetGoodEditorDialogPosition(wxPGProperty* p, const wxSize& sz)',
                              'wxWindow* GetPrimaryEditor() const',
                              'wxWindow* GetEditorControlSecondary() const',
                              'wxRect GetPropertyRect(const wxPGProperty* p1, const wxPGProperty* p2) const'
        # for SetSelection
        spec.map 'const wxArrayPGProperty &newSelection' => 'Array<Wx::PG::PGProperty>' do
          map_in temp: 'wxArrayPGProperty tmp', code: <<~__CODE
            if (TYPE($input) == T_ARRAY)
            {
              for (int i = 0; i < RARRAY_LEN($input); i++)
              {
                void* ptr = 0;
                VALUE rb_pgprop = rb_ary_entry($input, i);
                int res = SWIG_ConvertPtr(rb_pgprop, &ptr,SWIGTYPE_p_wxPGProperty, 0);
                if (!SWIG_IsOK(res)) 
                {
                  VALUE msg = rb_inspect($input);
                  rb_raise(rb_eTypeError, "Expected array of Wx::PG::PGProperty for 1 but got %s", StringValuePtr(msg));
                }
                wxPGProperty *pgprop_ptr = reinterpret_cast< wxPGProperty * >(ptr);
                tmp.push_back(pgprop_ptr);
              }
              $1 = &tmp;
            }
            else
            {
              SWIG_exception_fail(SWIG_TypeError, Ruby_Format_TypeError( "", "Array","$symname", $argnum, $input));
            } 
            __CODE
        end
        # add extension code to retrieve the internal standard editors
        # can't use the global variables directly to create constants as these will
        # only be initialized after the app has started so we add a module method
        # to retrieve the variables and use that to initialize the constants using
        # delayed init
        spec.include 'wx/propgrid/advprops.h'
        spec.add_extend_code 'wxPropertyGrid', <<~__HEREDOC
          static wxPGEditor* get_standard_editor_class(const wxString& editor_name)
          {
            // will trigger registration of all property editors
            wxPropertyGridInterface::RegisterAdditionalEditors();
            if (editor_name == wxS("TextCtrl"))
            {
              return wxPGEditor_TextCtrl;
            }
            if (editor_name == wxS("TextCtrlAndButton"))
            {
              return wxPGEditor_TextCtrlAndButton;
            }
            if (editor_name == wxS("Choice"))
            {
              return wxPGEditor_Choice;
            }
            if (editor_name == wxS("ComboBox"))
            {
              return wxPGEditor_ComboBox;
            }
            if (editor_name == wxS("CheckBox"))
            {
              return wxPGEditor_CheckBox;
            }
            if (editor_name == wxS("ChoiceAndButton"))
            {
              return wxPGEditor_ChoiceAndButton;
            }
            if (editor_name == wxS("SpinCtrl"))
            {
              return wxPGEditor_SpinCtrl;
            }
            if (editor_name == wxS("DatePickerCtrl"))
            {
              return wxPGEditor_DatePickerCtrl;
            }
            return 0;
          }
        __HEREDOC
      end
    end # class PropertyGrid

  end # class Director

end # module WXRuby3
