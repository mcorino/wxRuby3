# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class PGEditor < Director

      def setup
        super
        spec.items.concat %w[wxPGCheckBoxEditor wxPGChoiceEditor wxPGChoiceAndButtonEditor wxPGComboBoxEditor
                             wxPGTextCtrlEditor wxPGSpinCtrlEditor wxPGTextCtrlAndButtonEditor wxPGEditorDialogAdapter]
        spec.includes << 'wx/propgrid/propgriddefs.h'
        if Config.instance.wx_version_check('3.2.4') > 0
          # make sure SWIG knows this as enum type
          spec.add_swig_code 'enum wxPGPropertyFlags;'
        end
        spec.add_header_code <<~__HEREDOC
          // template specialization to circumvent lack of default ctor
          template <> wxPGWindowList SwigValueInit<wxPGWindowList>() {
            return wxPGWindowList(0);
          }
          __HEREDOC
        # SWIG fails to use SwigValueInit for local var init properly (SWIG 4 partially)
        # so we fix it ourselves
        spec.post_processors << :update_pg_window_list
        spec.map 'wxPGWindowList' => 'Wx::Window,Array<Wx::Window,Wx::Window>' do
          map_out code: <<~__CODE
            wxWindow *winsec = $1.GetSecondary();
            if (winsec) 
            {
              $result = rb_ary_new();
              rb_ary_push($result, wxRuby_WrapWxObjectInRuby($1.GetPrimary()));
              rb_ary_push($result, wxRuby_WrapWxObjectInRuby(winsec));
            }
            else
            {
              $result = wxRuby_WrapWxObjectInRuby($1.GetPrimary());
            }
            __CODE
          map_directorout code: <<~__CODE
            if (TYPE($input) == T_ARRAY && RARRAY_LEN($input) >= 1)
            {
              void *ptr;
              int res = SWIG_ConvertPtr(rb_ary_entry($input, 0), &ptr, SWIGTYPE_p_wxWindow, 0 |  0);
              if (!SWIG_IsOK(res)) 
              {
                Swig::DirectorTypeMismatchException::raise(swig_get_self(), "$symname", SWIG_ErrorType(SWIG_ArgError(res)), "in primary output value of type 'wxWindow *'");
              }
              $result = wxPGWindowList(static_cast<wxWindow*>(ptr));
              if (RARRAY_LEN($input) > 1)
              {
                res = SWIG_ConvertPtr(rb_ary_entry($input, 1), &ptr, SWIGTYPE_p_wxWindow, 0 |  0);
                if (!SWIG_IsOK(res)) 
                {
                  Swig::DirectorTypeMismatchException::raise(swig_get_self(), "$symname", SWIG_ErrorType(SWIG_ArgError(res)), "in secundary output value of type 'wxWindow *'");
                }
                $result.SetSecondary(static_cast<wxWindow*>(ptr));
              }
            }
            __CODE
        end
        # since OnEvent is const we need a slightly different version of this type map
        spec.map 'wxEvent &event' => 'Wx::Event' do
          map_directorin code: <<~__CODE
            #ifdef __WXRB_DEBUG__
            $input = wxRuby_WrapWxEventInRuby(const_cast<void*> (static_cast<const void*> (this)), &$1);
            #else
            $input = wxRuby_WrapWxEventInRuby(&$1);
            #endif
          __CODE

          # Thin and trusting wrapping to bypass SWIG's normal mechanisms; we
          # don't want SWIG changing ownership or typechecking these.
          map_in code: '$1 = (wxEvent*)DATA_PTR($input);'
        end
        # add method for correctly wrapping PGEditor output references
        spec.add_header_code <<~__CODE
          extern VALUE mWxPG; // declare external module reference
          extern VALUE wxRuby_WrapWxPGEditorInRuby(const wxPGEditor *wx_pe)
          {
            // If no object was passed to be wrapped.
            if ( ! wx_pe )
              return Qnil;

            // check if this instance is already tracked; return tracked value if so 
            VALUE r_pe = SWIG_RubyInstanceFor(const_cast<wxPGEditor*> (wx_pe));
            if (r_pe && !NIL_P(r_pe)) return r_pe;              

            // Get the wx class and the ruby class we are converting into
            wxString class_name( wx_pe->GetClassInfo()->GetClassName() ); 
            VALUE r_class = Qnil;
            if ( class_name.Len() > 2 )
            {
              wxCharBuffer wx_classname = class_name.mb_str();
              VALUE r_class_name = rb_intern(wx_classname.data () + 2); // wxRuby class name (minus 'wx')
              if (rb_const_defined(mWxPG, r_class_name))
                r_class = rb_const_get(mWxPG, r_class_name);
            }

            // If we cannot find the class output a warning and return nil
            if ( r_class == Qnil )
            {
              rb_warn("Error wrapping object; class `%s' is not (yet) supported in wxRuby",
                      (const char *)class_name.mb_str() );
              return Qnil;
            }


            // Otherwise, retrieve the swig type info for this class and wrap it
            // in Ruby. wxRuby_GetSwigTypeForClass is defined in wx.i
            swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(r_class);
            return SWIG_NewPointerObj(const_cast<wxPGEditor*> (wx_pe), swig_type, 0);
          }
          __CODE
        # ignore the variables themselves
        spec.ignore 'wxPGEditor_TextCtrl',
                    'wxPGEditor_Choice',
                    'wxPGEditor_ComboBox',
                    'wxPGEditor_TextCtrlAndButton',
                    'wxPGEditor_CheckBox',
                    'wxPGEditor_ChoiceAndButton',
                    'wxPGEditor_SpinCtrl',
                    'wxPGEditor_DatePickerCtrl'
      end

    end # class PGEditor

  end # class Director

  module SwigRunner
    # wxPGWindowList lacks a default ctor (stupid!) and therefor cannot be used by SWIG
    # for return by value setups.
    # We declared a compatible version in the header which can be used for var decls
    # and here we're going to replace all SWIG generated decls to use the custom class.
    class Processor
      class UpdatePgWindowList < Processor
        def run
          # just replace all occurrences of wxPGWindowList result var decls by SwigValueInit decls.
          update_source do |line|
            if /\A(\s*)wxPGWindowList\s+(c_)?result\s*;/ =~ line
              line = "#{$1}wxPGWindowList #{$2}result = SwigValueInit<wxPGWindowList>();"
            end
            line
          end
        end
      end
    end
  end

end # module WXRuby3
