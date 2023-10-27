# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class GridCellEditor < Director

      include Typemap::GridClientData

      def setup
        super
        spec.gc_as_untracked
        # use custom free func to be able to account for more complex inheritance
        spec.add_header_code 'extern void GC_free_GridCellEditor(void *ptr);'
        spec.add_swig_code '%feature("freefunc") wxGridCellEditor "GC_free_GridCellEditor";'
        if spec.module_name == 'wxGridCellEditor'
          spec.post_processors << :fix_gridcelleditor
          # exposing the mixin wxClientDataContainer/wxSharedClientDataContainer has no real upside
          # for wxRuby; far easier to just use member variables in derived classes
          spec.override_inheritance_chain('wxGridCellEditor', [])
          spec.regard('wxGridCellEditor::~wxGridCellEditor')
          # add method for correctly wrapping PGEditor output references
          spec.add_header_code <<~__CODE
            extern VALUE mWxGRID; // declare external module reference
            extern VALUE wxRuby_GridCellEditorInstance(wxGridCellEditor* wx_edt);
            extern void wxRuby_RegisterGridCellEditor(wxGridCellEditor* wx_edt, VALUE rb_edt);
            extern VALUE wxRuby_WrapWxGridCellEditorInRuby(const wxGridCellEditor *wx_gce)
            {
              // If no object was passed to be wrapped.
              if ( ! wx_gce )
                return Qnil;

              // check for registered instance
              VALUE rb_gce = wxRuby_GridCellEditorInstance(const_cast<wxGridCellEditor*> (wx_gce));
              if (rb_gce && !NIL_P(rb_gce))
              {
                return rb_gce;
              }

              const void *ptr = 0;
              wxString class_name;
              if ((ptr = dynamic_cast<const wxGridCellActivatableEditor*> (wx_gce)))
              {
                class_name = "GridCellActivatableEditor";
              }
              else if ((ptr = dynamic_cast<const wxGridCellBoolEditor*> (wx_gce)))
              {
                class_name = "GridCellBoolEditor";
              }
              else if ((ptr = dynamic_cast<const wxGridCellEnumEditor*> (wx_gce)))
              {
                class_name = "GridCellEnumEditor";
              }
              else if ((ptr = dynamic_cast<const wxGridCellChoiceEditor*> (wx_gce)))
              {
                class_name = "GridCellChoiceEditor";
              }
              else if ((ptr = dynamic_cast<const wxGridCellDateEditor*> (wx_gce)))
              {
                class_name = "GridCellDateEditor";
              }
              else if ((ptr = dynamic_cast<const wxGridCellFloatEditor*> (wx_gce)))
              {
                class_name = "GridCellFloatEditor";
              }
              else if ((ptr = dynamic_cast<const wxGridCellNumberEditor*> (wx_gce)))
              {
                class_name = "GridCellNumberEditor";
              }
              else if ((ptr = dynamic_cast<const wxGridCellAutoWrapStringEditor*> (wx_gce)))
              {
                class_name = "GridCellAutoWrapStringEditor";
              }
              else if ((ptr = dynamic_cast<const wxGridCellTextEditor*> (wx_gce)))
              {
                class_name = "GridCellTextEditor";
              }
              VALUE r_class = Qnil;
              if ( ptr && class_name.Len() > 0 )
              {
                wxCharBuffer wx_classname = class_name.mb_str();
                VALUE r_class_name = rb_intern(wx_classname.data ()); // wxRuby class name (minus 'wx')
                if (rb_const_defined(mWxGRID, r_class_name))
                  r_class = rb_const_get(mWxGRID, r_class_name);
              }

              // If we cannot find the class output a warning and return nil
              if ( r_class == Qnil )
              {
                rb_warn("Error wrapping object; class `%s' is not (yet) supported in wxRuby",
                        (const char *)class_name.mb_str() );
                return Qnil;
              }

              // Otherwise, retrieve the swig type info for this class and wrap it
              // in Ruby. Make it owned to manage the ref count if GC claims the object. 
              // wxRuby_GetSwigTypeForClass is defined in wx.i
              swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(r_class);
              rb_gce = SWIG_NewPointerObj(const_cast<void*> (ptr), swig_type, 0);
              wxRuby_RegisterGridCellEditor(const_cast<wxGridCellEditor*> (wx_gce), rb_gce);
              return rb_gce;
            }

            extern void GC_free_GridCellEditor(void *ptr)
            {
              wxGridCellEditor* gc_edt = (wxGridCellEditor*)ptr; 
              if (ptr)
                gc_edt->DecRef();
            }
            __CODE
        elsif spec.module_name == 'wxGridCellActivatableEditor'
          spec.post_processors << :fix_gridcelleditor
          spec.override_inheritance_chain('wxGridCellActivatableEditor', %w[wxGridCellEditor])
          spec.no_proxy %w[
            wxGridCellActivatableEditor::BeginEdit
            wxGridCellActivatableEditor::Create
            wxGridCellActivatableEditor::Destroy
            wxGridCellActivatableEditor::EndEdit
            wxGridCellActivatableEditor::ApplyEdit
            wxGridCellActivatableEditor::HandleReturn
            wxGridCellActivatableEditor::PaintBackground
            wxGridCellActivatableEditor::Reset
            wxGridCellActivatableEditor::SetSize
            wxGridCellActivatableEditor::Show
            wxGridCellActivatableEditor::StartingClick
            wxGridCellActivatableEditor::StartingKey
            wxGridCellActivatableEditor::IsAcceptedKey
            wxGridCellActivatableEditor::GetValue
            ]
        else
          spec.post_processors << :fix_gridcelleditor
          case spec.module_name
          when 'wxGridCellEnumEditor'
            spec.override_inheritance_chain(spec.module_name, %w[wxGridCellChoiceEditor wxGridCellEditor])
          when 'wxGridCellChoiceEditor'
            # unnecessary overload
            spec.ignore 'wxGridCellChoiceEditor::wxGridCellChoiceEditor(size_t, const wxString [], bool)'
            spec.override_inheritance_chain(spec.module_name, %w[wxGridCellEditor])
          when 'wxGridCellAutoWrapStringEditor', 'wxGridCellFloatEditor', 'wxGridCellNumberEditor'
            spec.override_inheritance_chain(spec.module_name, %w[wxGridCellTextEditor wxGridCellEditor])
          else
            spec.override_inheritance_chain(spec.module_name, %w[wxGridCellEditor])
          end
          # due to the flawed wxWidgets XML docs we need to explicitly add these here
          # otherwise the derived editors won't be allocable due to pure virtuals
          spec.extend_interface spec.module_name,
            'void BeginEdit(int row, int col, wxGrid *grid)',
            'wxGridCellEditor * Clone() const',
            'void Create(wxWindow *parent, wxWindowID id, wxEvtHandler *evtHandler)',
            'bool EndEdit(int row, int col, const wxGrid *grid, const wxString &oldval, wxString *newval)',
            'void ApplyEdit(int row, int col, wxGrid *grid)',
            'void Reset()',
            'wxString GetValue() const'
        end
        unless spec.module_name == 'wxGridCellEditor'
          # type mapping for Clone return ref
          spec.map 'wxGridCellEditor*' => 'Wx::GRID::GridCellEditor' do
            add_header_code 'extern VALUE wxRuby_WrapWxGridCellEditorInRuby(const wxGridCellEditor *wx_gce);'
            map_out code: '$result = wxRuby_WrapWxGridCellEditorInRuby($1);'
          end
        end
        # handled; can be suppressed
        spec.suppress_warning(473, "#{spec.module_name}::Clone")
      end

      # helper methods for custom wrapper to handle wxGridActivationResult and wxGridActivationSource
      # in wxGridCellEditor::TryActivate as SWIG cannot handle the, admittedly seriously flawed,
      # wxWidgets interface
      WRAPPER_HELPERS = <<~__HEREDOC
            static WxRuby_ID ga_ignore_id("ignore");
            static WxRuby_ID ga_show_editor_id("show_editor");
            static WxRuby_ID ga_change_id("change");
            static WxRuby_ID ga_program_id("program");
            static WxRuby_ID ga_key_id("key");
            static WxRuby_ID ga_mouse_id("mouse");

            inline wxGridActivationResult
            array_to_wxGridActivationResult(VALUE self, const char* method, VALUE rbarr)
            {
              if (rbarr == Qnil || 
                !(TYPE(rbarr) == T_ARRAY || TYPE(rbarr) == T_SYMBOL))
              {
                Swig::DirectorTypeMismatchException::raise(self, method, SWIG_ErrorType(SWIG_ArgError(SWIG_ERROR)), 
                                                           "in output value of type 'wxGridActivationResult'");
              }
              if (TYPE(rbarr) == T_SYMBOL)
              {
                if (SYM2ID(rbarr) == ga_ignore_id())
                  return wxGridActivationResult::DoNothing();
                else if (SYM2ID(rbarr) == ga_show_editor_id())
                  return wxGridActivationResult::DoEdit();
                else
                  Swig::DirectorTypeMismatchException::raise(self, method, SWIG_ErrorType(SWIG_ArgError(SWIG_ERROR)), 
                                                             "in output value of type 'wxGridActivationResult'");
              }
              else
              {
                VALUE rbAction = rb_ary_shift(rbarr);
                VALUE rbStr = rb_ary_shift(rbarr); // could be nil
                if (rbAction == Qnil || TYPE(rbAction) != T_SYMBOL)
                {
                  Swig::DirectorTypeMismatchException::raise(self, method, SWIG_ErrorType(SWIG_ArgError(SWIG_ERROR)), 
                                                             "in output value of type 'wxGridActivationResult'");
                }
                else if (SYM2ID(rbAction) == ga_change_id() && rbStr != Qnil)
                {
                  return wxGridActivationResult::DoChange(RSTR_TO_WXSTR(rbStr));
                }
                else
                {
                  if (SYM2ID(rbAction) == ga_ignore_id())
                    return wxGridActivationResult::DoNothing();
                  else if (SYM2ID(rbAction) == ga_show_editor_id())
                    return wxGridActivationResult::DoEdit();
                  else
                    Swig::DirectorTypeMismatchException::raise(self, method, SWIG_ErrorType(SWIG_ArgError(SWIG_ERROR)), 
                                                               "in output value of type 'wxGridActivationResult'");
                }
              }
              // silence compiler; should never be reached
              return wxGridActivationResult::DoNothing();
            }

            inline VALUE 
            wxGridActivationResult_to_array(const wxGridActivationResult& result)
            {
              VALUE rbresult = rb_ary_new();
              wxGridActivationResult::Action act = result.GetAction ();
              switch (act) {
              case wxGridActivationResult::Ignore:
                rb_ary_push(rbresult, ga_ignore_id.get_sym());
                break;
              case wxGridActivationResult::Change:
                rb_ary_push(rbresult, ga_change_id.get_sym());
                rb_ary_push(rbresult, WXSTR_TO_RSTR(result.GetNewValue()));
                break;
              case wxGridActivationResult::ShowEditor:
                rb_ary_push(rbresult, ga_show_editor_id.get_sym());
                break;
              }
              return rbresult;
            }
  
            inline wxGridActivationSource 
            array_to_wxGridActivationSource(VALUE rbarr, int argnum)
            {
              if (rbarr == Qnil || 
                !(TYPE(rbarr) == T_ARRAY || TYPE(rbarr) == T_SYMBOL))
              {
                rb_raise(rb_eArgError, 
                  "Expected Symbol or Array of Symbol and optional event for %d.", argnum);
              }
              if (TYPE(rbarr) == T_SYMBOL)
              {
                if (SYM2ID(rbarr) != ga_program_id())
                  rb_raise(rb_eArgError, 
                    ":key or :mouse activation sources need an event for %d.", argnum);
                else
                  return wxGridActivationSource::FromProgram();
              }
              else
              {
                VALUE rbOrg = rb_ary_shift(rbarr);
                VALUE rbEvt = rb_ary_shift(rbarr); // could be nil
                if (rbOrg == Qnil || TYPE(rbOrg) != T_SYMBOL)
                {
                  rb_raise(rb_eArgError, 
                    "expected Symbol or Array of Symbol and optional event for %d.", argnum);
                }
                else if (SYM2ID(rbOrg) == ga_program_id())
                {
                  return wxGridActivationSource::FromProgram();
                }
                else if (rbEvt != Qnil)
                {
                  const wxEvent* evt = (const wxEvent*)DATA_PTR(rbEvt);
                  if (SYM2ID(rbOrg) == ga_key_id())
                    return wxGridActivationSource::From(*(const wxKeyEvent*)evt);
                  else if (SYM2ID(rbOrg) == ga_mouse_id())
                    return wxGridActivationSource::From(*(const wxMouseEvent*)evt);
                  rb_raise(rb_eArgError, 
                    "unknown activation source for %d.", argnum);
                }
                else
                {
                  rb_raise(rb_eArgError, 
                    ":key or :mouse activation sources need an event for %d.", argnum);
                }
              }
            }

            inline VALUE 
            wxGridActivationSource_to_array(const wxGridActivationSource& arg)
            {
              VALUE rbresult = rb_ary_new();
              wxGridActivationSource::Origin org = arg.GetOrigin ();
              switch (org) {
              case wxGridActivationSource::Program:
                rb_ary_push(rbresult, ga_program_id.get_sym());
                break;
              case wxGridActivationSource::Key:
                rb_ary_push(rbresult, ga_key_id.get_sym());
            #ifdef __WXRB_DEBUG__
                rb_ary_push(rbresult, wxRuby_WrapWxEventInRuby(0, const_cast<wxKeyEvent*> (&arg.GetKeyEvent())));
            #else 
                rb_ary_push(rbresult, wxRuby_WrapWxEventInRuby(const_cast<wxKeyEvent*> (&arg.GetKeyEvent())));
            #endif 
                break;
              case wxGridActivationSource::Mouse:
                rb_ary_push(rbresult, ga_mouse_id.get_sym());
            #ifdef __WXRB_DEBUG__
                rb_ary_push(rbresult, wxRuby_WrapWxEventInRuby(0, const_cast<wxMouseEvent*> (&arg.GetMouseEvent()))); 
            #else 
                rb_ary_push(rbresult, wxRuby_WrapWxEventInRuby(const_cast<wxMouseEvent*> (&arg.GetMouseEvent()))); 
            #endif 
                break;
              }
              return rbresult;
            }

      __HEREDOC


    end # class GridCellEditor

  end # class Director

  module SwigRunner
    class Processor

      # special post-processor for GridCellEditor
      class FixGridcelleditor < Processor

        def run
          skip_lines = false
          helpers_added = false

          update_source do |line|
            if skip_lines
              if /\A}\s*\Z/ =~ line
                skip_lines = false
              else
                line = nil
              end
            elsif line["wxGridActivationResult SwigDirector_#{module_name}::TryActivate("]
              skip_lines = true
              # append new method implementation
              line << "\n" << <<~__METHOD__
                static WxRuby_ID try_activate_id("try_activate");

                VALUE obj0 = Qnil ;
                VALUE obj1 = Qnil ;
                VALUE obj2 = Qnil ;
                VALUE obj3 = Qnil ;
                VALUE SWIGUNUSED result;
                
                obj0 = SWIG_From_int(static_cast< int >(row));
                obj1 = SWIG_From_int(static_cast< int >(col));
                obj2 = SWIG_NewPointerObj(SWIG_as_voidptr(grid), SWIGTYPE_p_wxGrid,  0 );
                obj3 = wxGridActivationSource_to_array(actSource); 
                result = rb_funcall(swig_get_self(), try_activate_id(), 4,obj0,obj1,obj2,obj3);
                return array_to_wxGridActivationResult(swig_get_self(), "try_activate", result);
                __METHOD__
            elsif !helpers_added && line["SwigDirector_#{module_name}::SwigDirector_#{module_name}(VALUE self"]
              # insert helper methods
              line = [Director::GridCellEditor::WRAPPER_HELPERS, line]
              helpers_added = true
            elsif line["_wrap_#{module_name}_TryActivate(int argc, VALUE *argv, VALUE self) {"]
              skip_lines = true
              # append new method implementation
              line << "\n" << <<~__METHOD__
                  #{module_name} *arg1 = (#{module_name} *) 0 ;
                  int arg2 ;
                  int arg3 ;
                  wxGrid *arg4 = (wxGrid *) 0 ;
                  void *argp1 = 0 ;
                  int res1 = 0 ;
                  int val2 ;
                  int ecode2 = 0 ;
                  int val3 ;
                  int ecode3 = 0 ;
                  void *argp4 = 0 ;
                  int res4 = 0 ;
                  Swig::Director *director = 0;
                  bool upcall = false;
                  VALUE vresult = Qnil;
                  
                  if ((argc < 4) || (argc > 4)) {
                    rb_raise(rb_eArgError, "wrong # of arguments(%d for 4)",argc); SWIG_fail;
                  }
                  res1 = SWIG_ConvertPtr(self, &argp1,SWIGTYPE_p_#{module_name}, 0 |  0 );
                  if (!SWIG_IsOK(res1)) {
                    SWIG_exception_fail(SWIG_ArgError(res1), Ruby_Format_TypeError( "", "#{module_name} *","TryActivate", 1, self )); 
                  }
                  arg1 = reinterpret_cast< #{module_name} * >(argp1);
                  ecode2 = SWIG_AsVal_int(argv[0], &val2);
                  if (!SWIG_IsOK(ecode2)) {
                    SWIG_exception_fail(SWIG_ArgError(ecode2), Ruby_Format_TypeError( "", "int","TryActivate", 2, argv[0] ));
                  } 
                  arg2 = static_cast< int >(val2);
                  ecode3 = SWIG_AsVal_int(argv[1], &val3);
                  if (!SWIG_IsOK(ecode3)) {
                    SWIG_exception_fail(SWIG_ArgError(ecode3), Ruby_Format_TypeError( "", "int","TryActivate", 3, argv[1] ));
                  } 
                  arg3 = static_cast< int >(val3);
                  res4 = SWIG_ConvertPtr(argv[2], &argp4,SWIGTYPE_p_wxGrid, 0 |  0 );
                  if (!SWIG_IsOK(res4)) {
                    SWIG_exception_fail(SWIG_ArgError(res4), Ruby_Format_TypeError( "", "wxGrid *","TryActivate", 4, argv[2] )); 
                  }
                  arg4 = reinterpret_cast< wxGrid * >(argp4);
                  director = dynamic_cast<Swig::Director *>(arg1);
                  upcall = (director && (director->swig_get_self() == self));
                  try {
                    if (upcall) {
                      #{
                        if module_name == 'wxGridCellActivatableEditor'
                          'Swig::DirectorPureVirtualException::raise("wxGridCellActivatableEditor::TryActivate");'
                        else
                          "vresult = wxGridActivationResult_to_array((arg1)->#{module_name}::TryActivate(arg2,arg3,arg4,array_to_wxGridActivationSource(argv[3], 4)));"
                        end
                      }
                    } else {
                      vresult = wxGridActivationResult_to_array((arg1)->TryActivate(arg2,arg3,arg4,array_to_wxGridActivationSource(argv[3], 4)));
                    }
                  } catch (Swig::DirectorException& e) {
                    rb_exc_raise(e.getError());
                    SWIG_fail;
                  }
                  return vresult;
                fail:
                  return Qnil;
              __METHOD__
            end

            line
          end
        end

      end # class FixGridcelleditor

    end
  end

end # module WXRuby3
