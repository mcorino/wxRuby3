###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class Window < Director

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
                        "#{itm}::MakeModal",
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
                        "#{itm}::GetValidator") unless /\.h\Z/ =~ itm
        end

        case spec.module_name
        when 'wxWindow' # only for actual wxWindow class
          # // Any of these following kind of objects become owned by the window
          # // when passed into Wx, and so will be deleted automatically; using
          # // DISOWN resets their %freefunc to avoid deleting the object twice
          spec.disown 'wxCaret* caret', 'wxSizer* sizer', 'wxToolTip* tip', 'wxDropTarget* target'
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
            'wxWindow::GetSize(int *,int *) const',
            'wxWindow::GetPosition(int *,int *) const',
            'wxWindow::GetScreenPosition(int *,int *) const',
            'wxWindow::FindWindow',
            'wxWindow::GetTextExtent(const wxString &,int *,int *,int *,int *,const wxFont *)',
            'wxWindow::SendIdleEvents',
            'wxWindow::ClientToScreen(int*,int*)' # no need; prefer the wxPoint version
          ]
          spec.set_only_for('wxUSE_ACCESSIBILITY', 'wxWindow::SetAccessible')
          spec.set_only_for('wxUSE_HOTKEY', %w[wxWindow::RegisterHotKey wxWindow::UnregisterHotKey])
          spec.rename_for_ruby('SetDimensions' => 'wxWindow::SetSize(int, int, int, int, int)')
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
            __HEREDOC
          spec.add_extend_code 'wxWindow', <<~__HEREDOC
            // passes a DC for drawing on Window into a passed ruby block, and
            // ensure that the DC is correctly deleted when drawing is
            // completed. This is important to avoid entering an endless loop of
            // paint events. The DC will be a PaintDC if used within a evt_paint handler
            // (recommended) or else a ClientDC.
            VALUE paint()
            {  
              if ( ! rb_block_given_p() )
              rb_raise(rb_eArgError, "No block given for Window#paint");
          
              wxWindow *ptr = self;
              VALUE rb_win = SWIG_RubyInstanceFor(ptr);
              // see if within an evt_paint block - see classes/window.rb
              // if so, supply a PaintDC to the block
              if ( rb_ivar_defined(rb_win, rb_intern("@__painting__") ) == Qtrue ) 
              {
                wxPaintDC dc(ptr);
                VALUE dcVal = SWIG_NewPointerObj((void *) &dc,SWIGTYPE_p_wxPaintDC, 0);
                rb_yield(dcVal);
                SWIG_RubyRemoveTracking((void *) &dc);
                DATA_PTR(dcVal) = NULL;
              }
              else // supply a ClientDC
              {
                wxClientDC dc(ptr);
                VALUE dcVal = SWIG_NewPointerObj((void *) &dc,SWIGTYPE_p_wxClientDC, 0);
                rb_yield(dcVal);
                SWIG_RubyRemoveTracking((void *) &dc);
                DATA_PTR(dcVal) = NULL;
              }
          
              return Qnil;
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
      end
    end # class Window

  end # class Director

end # module WXRuby3
