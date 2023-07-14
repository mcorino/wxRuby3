###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event_handler'

module WXRuby3

  class Director

    class Window < EvtHandler

      def setup
        super
        # for all wxWindow derived classes (not wxFrame and descendants)
        spec.items.each do |itm|
          # Avoid adding unneeded directors
          spec.no_proxy("#{itm}::AddChild",
                        "#{itm}::Fit",
                        "#{itm}::FitInside",
                        "#{itm}::Freeze",
                        "#{itm}::GetBackgroundStyle",
                        "#{itm}::GetCharHeight",
                        "#{itm}::GetCharWidth",
                        "#{itm}::GetLabel",
                        "#{itm}::GetName",
                        "#{itm}::GetScreenPosition",
                        "#{itm}::GetScrollPos",
                        "#{itm}::GetScrollRange",
                        "#{itm}::GetScrollThumb",
                        "#{itm}::GetTextExtent",
                        "#{itm}::HasCapture",
                        "#{itm}::HasMultiplePages",
                        "#{itm}::IsDoubleBuffered",
                        "#{itm}::IsEnabled",
                        "#{itm}::IsFrozen",
                        "#{itm}::IsRetained",
                        "#{itm}::IsShown",
                        "#{itm}::IsShownOnScreen",
                        "#{itm}::ReleaseMouse",
                        "#{itm}::RemoveChild",
                        "#{itm}::ScrollLines",
                        "#{itm}::ScrollPages",
                        "#{itm}::ScrollWindow",
                        "#{itm}::SetAcceleratorTable",
                        "#{itm}::SetBackgroundColour",
                        "#{itm}::SetBackgroundStyle",
                        "#{itm}::SetCursor",
                        "#{itm}::SetFocus",
                        "#{itm}::SetFocusFromKbd",
                        "#{itm}::SetFont",
                        "#{itm}::SetForegroundColour",
                        "#{itm}::SetHelpText",
                        "#{itm}::SetLabel",
                        "#{itm}::SetName",
                        "#{itm}::SetScrollPos",
                        "#{itm}::SetScrollbar",
                        "#{itm}::SetThemeEnabled",
                        "#{itm}::SetThemeEnabled",
                        "#{itm}::SetValidator",
                        "#{itm}::SetWindowStyleFlag",
                        "#{itm}::ShouldInheritColour",
                        "#{itm}::Thaw",
                        "#{itm}::Layout",
                        "#{itm}::InheritAttributes",
                        "#{itm}::GetDefaultAttributes",
                        "#{itm}::GetWindowStyleFlag",
                        "#{itm}::GetDropTarget",
                        "#{itm}::GetValidator",
                        "#{itm}::IsTopLevel",
                        "#{itm}::EnableTouchEvents") unless /\.h\Z/ =~ itm
        end

        case spec.module_name
        when 'wxWindow' # only for actual wxWindow class
          # // Any of these following kind of objects become owned by the window
          # // when passed into Wx, and so will be deleted automatically; using
          # // DISOWN resets their %freefunc to avoid deleting the object twice
          spec.disown 'wxCaret* caret', 'wxSizer* sizer', 'wxToolTip* tip', 'wxDropTarget* target'
          # do not allow SetSizer and SetSizerAndFit to leave the 'old' sizer unattached alive
          spec.map 'wxSizer *sizer, bool deleteOld' => 'Wx::Sizer' do
            map_in code: <<~__CODE
                int res = SWIG_ConvertPtr($input, SWIG_as_voidptrptr(&$1), SWIGTYPE_p_wxSizer, SWIG_POINTER_DISOWN);
                if (!SWIG_IsOK(res)) {
                  SWIG_exception_fail(SWIG_ArgError(res), Ruby_Format_TypeError( "", "wxSizer *","SetSizer", 2, $input));
                }
                $2 = true; // always delete 'old' sizer
              __CODE
          end
          spec.add_extend_code 'wxWindow', <<~__HEREDOC
            VALUE SwitchSizer(VALUE new_szr)
            {
              wxSizer *new_wx_szr = 0;
              int res = SWIG_ConvertPtr(new_szr, SWIG_as_voidptrptr(&new_wx_szr), SWIGTYPE_p_wxSizer, SWIG_POINTER_DISOWN);
              if (!SWIG_IsOK(res)) {
                SWIG_Error(SWIG_ArgError(res), Ruby_Format_TypeError( "", "wxSizer *","SetSizer", 2, new_szr));
                return Qnil;
              }
              wxSizer* old_szr = self->GetSizer();
              self->SetSizer(new_wx_szr, false);
              return SWIG_NewPointerObj(old_szr, SWIGTYPE_p_wxSizer, 1); // return owned wrapper for old sizer
            }
            __HEREDOC
          spec.new_object 'wxWindow::SwitchSizer'
          # Typemap for GetChildren - casts wxObjects to correct ruby wrappers
          spec.map 'wxWindowList&' => 'Array<Wx::Window>' do
            map_out code: <<~__CODE
              $result = rb_ary_new();
              wxWindowList::compatibility_iterator node = $1->GetFirst();
              while (node)
              {
                wxObject *obj = node->GetData();
                rb_ary_push($result, wxRuby_WrapWxObjectInRuby(obj));
                node = node->GetNext();
              }
            __CODE
          end
          spec.ignore [
            'wxWindow::TransferDataFromWindow',
            'wxWindow::TransferDataToWindow',
            'wxWindow::GetAccessible',
            'wxWindow::PopEventHandler',
            'wxWindow::SetConstraints',
            'wxWindow::GetHandle',
            'wxWindow::GetSize(int *,int *) const', # no need; prefer the wxSize version
            'wxWindow::GetClientSize(int *,int *) const', # no need; prefer the wxSize version
            'wxWindow::GetVirtualSize(int *,int *) const', # no need; prefer the wxSize version
            'wxWindow::GetPosition(int *,int *) const', # no need; prefer the wxPoint version
            'wxWindow::GetScreenPosition(int *,int *) const', # no need; prefer the wxPoint version
            'wxWindow::FindWindow',
            'wxWindow::GetTextExtent(const wxString &,int *,int *,int *,int *,const wxFont *)',
            'wxWindow::SendIdleEvents',
            'wxWindow::ClientToScreen(int*,int*)', # no need; prefer the wxPoint version
            'wxWindow::ScreenToClient(int*,int*)', # no need; prefer the wxPoint version
          ]
          # redefine these so a nil parent is accepted
          spec.ignore %w[wxWindow::FindWindowById wxWindow::FindWindowByLabel wxWindow::FindWindowByName], ignore_doc: false
          # overrule common typemap to allow default NULL
          spec.map 'wxWindow* find_from_parent' do
            map_check code: ''
          end
          spec.add_extend_code 'wxWindow', <<~__HEREDOC
            static wxWindow* find_window_by_id(long id, const wxWindow *find_from_parent=0)
            {
              return wxWindow::FindWindowById(id, find_from_parent);
            }
            static wxWindow* find_window_by_label(const wxString &label, const wxWindow *find_from_parent=0)
            {
              return wxWindow::FindWindowByLabel(label, find_from_parent);
            }
            static wxWindow* find_window_by_name(const wxString &name, const wxWindow *find_from_parent=0)
            {
              return wxWindow::FindWindowByName(name, find_from_parent);
            }
            __HEREDOC
          if Config.instance.wx_port == :wxQT
            # protected for wxQT; ignore for now
            spec.ignore 'wxWindow::EnableTouchEvents'
          end
          if Config.instance.wx_version >= '3.3.0'
            spec.set_only_for('__WXMSW__', 'wxWindow::MSWDisableComposited')
          end
          spec.set_only_for('wxUSE_ACCESSIBILITY', 'wxWindow::SetAccessible')
          spec.set_only_for('wxUSE_HOTKEY', %w[wxWindow::RegisterHotKey wxWindow::UnregisterHotKey])
          spec.ignore('wxWindow::SetSize(int, int)') # not useful as the wxSize variant will also accept an array
          spec.swig_import %w{
            swig/classes/include/wxObject.h
            swig/classes/include/wxEvtHandler.h
            swig/classes/include/wxDC.h
            swig/classes/include/wxWindowDC.h
            swig/classes/include/wxClientDC.h
            swig/classes/include/wxPaintDC.h
          }
          spec.add_wrapper_code <<~__HEREDOC
            extern VALUE wxRuby_GetWindowClass() {
              return SwigClassWxWindow.klass;
            }
            // we need this static method here because we do not want SWIG to parse the preprocessor 
            // statements (#if/#else/#endif) which it does in %extend blocks
            static VALUE do_paint_buffered(wxWindow* ptr)
            {
              VALUE rc = Qnil;
              wxAutoBufferedPaintDC dc(ptr);
            #if wxALWAYS_NATIVE_DOUBLE_BUFFER
              wxPaintDC* ptr_dc = &dc;
              VALUE r_class = rb_const_get(mWxCore, rb_intern("PaintDC"));
            #else
              wxMemoryDC* ptr_dc = &dc;
              VALUE r_class = rb_const_get(mWxCore, rb_intern("MemoryDC"));
            #endif
              swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(r_class);
              VALUE rb_dc = SWIG_NewPointerObj(SWIG_as_voidptr(ptr_dc), swig_type, 0);
              rc = rb_yield(rb_dc);

              return rc;
            }
            __HEREDOC
          spec.add_header_code 'static VALUE do_paint_buffered(wxWindow* ptr);'
          spec.add_extend_code 'wxWindow', <<~__HEREDOC
            // passes a DC for drawing on Window into a passed ruby block, and
            // ensure that the DC is correctly deleted when drawing is
            // completed. This is important to avoid entering an endless loop of
            // paint events. The DC will be a PaintDC if used within a evt_paint handler
            // (recommended) or else a ClientDC.
            VALUE paint()
            {  
              static WxRuby_ID painting_id("@__painting__");

              if (!rb_block_given_p()) rb_raise(rb_eArgError, "No block given for Window#paint");
          
              VALUE rc = Qnil;
              wxWindow *ptr = self;
              VALUE rb_win = SWIG_RubyInstanceFor(ptr);
              // see if within an evt_paint block - see classes/window.rb
              // if so, supply a PaintDC to the block
              if ( rb_ivar_defined(rb_win, painting_id()) == Qtrue ) 
              {
                wxPaintDC dc(ptr);
                VALUE dcVal = SWIG_NewPointerObj((void *) &dc,SWIGTYPE_p_wxPaintDC, 0);
                rc = rb_yield(dcVal);
              }
              else // supply a ClientDC
              {
                wxClientDC dc(ptr);
                VALUE dcVal = SWIG_NewPointerObj((void *) &dc,SWIGTYPE_p_wxClientDC, 0);
                rc = rb_yield(dcVal);
              }
          
              return rc;
            }

            // similar to the paint() method but now for buffered painting
            // we do not check __painting__ here, instead we do that in pure Ruby
            VALUE paint_buffered()
            {
              if (!rb_block_given_p()) rb_raise(rb_eArgError, "No block given for Window#paint_buffered");
          
              return do_paint_buffered(self);
            }
          
            // Return a window handle as a platform-specific ruby integer
            VALUE get_handle()
            {
              wxWindow *win = self;
              int64_t handle = (int64_t)win->GetHandle();
              return LL2NUM(handle);
            }
          
            // Attach a wx Object to an existing Windows handle (MSW only)
            VALUE associate_handle(int64_t handle)
            {
              WXWidget wx_handle = (WXWidget)handle;
              $self->AssociateHandle(wx_handle);
              return Qnil;
            }
          __HEREDOC
          spec.override_events 'wxWindow', 'EVT_ACTIVATE' => ['EVT_ACTIVATE', 0, 'wxActivateEvent']
        when 'wxNonOwnedWindow'
          spec.no_proxy('wxNonOwnedWindow')
        when 'wxControl'
          # add these to the generated interface to be parsed by SWIG
          # the wxWidgets docs are flawed in this respect that several reimplemented
          # virtual methods are not documented at the reimplementing class as such
          # that would cause them missing from the interface which would cause a problem
          # for a SWIG director redirecting to the Ruby class as the SWIG wrappers
          # redirect explicitly to the implementation at the same class level as the wrapper
          # for upcalls
          spec.extend_interface('wxControl',
                                'virtual bool ShouldInheritColours() const override',
                                'virtual void DoUpdateWindowUI(wxUpdateUIEvent& event) override')
        end
        # helper for all Window modules
        spec.add_header_code <<~__HEREDOC
          static WxRuby_ID __wxrb_on_internal_idle_id("on_internal_idle");
          __HEREDOC
        # update generated code for all windows
        spec.post_processors << :update_window
      end

      def process(gendoc: false)
        defmod = super
        if spec.module_name == 'wxWindow'
          # special processing to ignore the non-static versions of methods FromDIP,ToDIP,FromPhys,ToPhys
          # as SWIG cannot handle identically named static & non-static methods
          # will handle that in pure Ruby
          %w[FromDIP ToDIP FromPhys ToPhys].each do |mtd|
            if (item = defmod.find("wxWindow::#{mtd}"))
              item.all.each { |ovl| ovl.ignore(true, ignore_doc: false) unless ovl.is_static }
            end
          end
        end
        defmod
      end

    end # class Window

  end # class Director

  module SwigRunner
    class Processor

      # Special post-processor for Window and derivatives.
      # This provides extra safe guarding for the event processing path in wxRuby.
      # The processor inserts code in the 'OnInternalIdle' methods of the director class which check
      # for existence of any Ruby implementation of this method ('on_internal_idle')
      # in the absence of which a direct call to the wxWidget implementation is made. If there
      # does exist a Ruby ('override') implementation the method continues and calls the Ruby
      # method implementation.
      # Additionally the inserted code first off checks if the window is actually (still)
      # able to handle events by calling wxRuby_FindTracking() since in wxRuby it seems in rare occasions
      # possible the event handler instance gets garbage collected AFTER the event processing
      # path has started in which case the C++ and Ruby object are unlinked and any attempts to
      # access the (originally) associated Ruby object will have bad results (this is especially
      # true for dialogs which are not cleaned up by wxWidgets but rather garbage collected by Ruby).
      class UpdateWindow < Processor

        def run
          at_director_method = false
          director_wx_class = nil
          director_method_line = 0

          prev_line = nil

          update_source(at_end: ->(){ prev_line }) do |line|
            if at_director_method
              director_method_line += 1   # update line counter
              if director_method_line == 2 && line.strip.empty?   # are we at the right spot?
                code = <<~__CODE     # insert the code update
                // added by wxRuby3 Processor.update_window
                // if Ruby object not registered anymore or no Ruby defined method override
                // reroute directly to C++ method
                if (wxRuby_FindTracking(this) == Qnil || wxRuby_IsNativeMethod(swig_get_self(), __wxrb_on_internal_idle_id()))
                  this->#{director_wx_class}::OnInternalIdle();
                else
                __CODE
                line << "\n  " << code.split("\n").join("\n  ")
                at_director_method = false  # end of update
              end
            elsif /void\s+SwigDirector_(\w+)::OnInternalIdle\(.*\)\s+{/ =~ line
              director_wx_class = $1
              at_director_method = true   # we're at a director method to be updated
              director_method_line = 0    # keep track of the method lines
            end

            result = prev_line
            prev_line = line
            result
          end
        end

      end # class UpdateWindow

    end
  end

end # module WXRuby3
