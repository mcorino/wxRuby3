#--------------------------------------------------------------------
# @file    window.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class Window < Director

      def initialize
        super
      end

      def setup(spec)
        # for all wxWindow derived classes (not wxFrame and descendants)
        spec.add_swig_begin_code <<~__HEREDOC
          SWIG_WXWINDOW_NO_USELESS_VIRTUALS(wxWindow);
        __HEREDOC
        # only for actual wxWindow class
        if spec.module_name == 'wxWindow'
          spec.add_swig_begin_code <<~__HEREDOC
          
            // Any of these following kind of objects become owned by the window
            // when passed into Wx, and so will be deleted automatically; using
            // DISOWN resets their %freefunc to avoid deleting the object twice
            %apply SWIGTYPE *DISOWN {wxCaret* caret};
            %apply SWIGTYPE *DISOWN {wxSizer* sizer};
            %apply SWIGTYPE *DISOWN {wxToolTip* tip};
            %apply SWIGTYPE *DISOWN {wxDropTarget* target};
            
            %apply int * INOUT { int * x_INOUT, int * y_INOUT }
            
            // Typemap for GetChildren - casts wxObjects to correct ruby wrappers
            %typemap(out) wxWindowList& {
              $result = rb_ary_new();
            
              wxWindowList::compatibility_iterator node = $1->GetFirst();
              while (node)
              {
                wxObject *obj = node->GetData();
                rb_ary_push($result, wxRuby_WrapWxObjectInRuby(obj));
                node = node->GetNext();
              }
            }
          __HEREDOC
          spec.ignore [
            "wxWindow::GetAccessible",
            "wxWindow::PopEventHandler",
            "wxWindow::SetConstraints",
            "wxWindow::GetHandle",
            "wxWindow::GetSize(int *,int *) const",
            "wxWindow::GetPosition(int *,int *) const",
            "wxWindow::GetScreenPosition(int *,int *) const",
            "wxWindow::FindWindow"
          ]
          spec.rename('SetDimensions' => 'wxWindow::SetSize(int  x , int  y , int  width , int  height , int sizeFlags = wxSIZE_AUTO)')
          spec.swig_import %w{
            include/wxDC.h
            include/wxWindowDC.h
            include/wxPaintDC.h
            include/wxClientDC.h
          }
        end
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
            long handle = (long)win->GetHandle();
          return LONG2NUM(handle);
          }
        
          // Attach a wx Object to an existing Windows handle (MSW only)
          VALUE associate_handle(long handle)
          {
            WXWidget wx_handle = (WXWidget)handle;
            $self->AssociateHandle(wx_handle);
            return Qnil;
          }
        __HEREDOC
        super
      end
    end # class Window

  end # class Director

end # module WXRuby3
