#--------------------------------------------------------------------
# @file    frame.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './top_level_window'

module WXRuby3

  class Director

    class Frame < TopLevelWindow

      def setup
        super
        # only for wxFrame class itself
        case spec.module_name
        when 'wxFrame'
          spec.no_proxy %w[
            wxFrame::CreateStatusBar wxFrame::CreateToolBar wxFrame::GetMenuBar wxFrame::GetStatusBar wxFrame::GetToolBar]
          spec.ignore %w[
            wxFrame::OnCreateStatusBar wxFrame::OnCreateToolBar]
          spec.set_only_for(%w[__WXMSW__ wxUSE_TASKBARBUTTON], 'wxFrame::MSWGetTaskBarButton')
          # this reimplemented window base method need to be properly wrapped but
          # is missing from the XML docs
          spec.extend_interface('wxFrame', 'virtual void OnInternalIdle()')
          spec.disown 'wxMenuBar *'
          spec.add_swig_code <<~__HEREDOC
            %typemap(in,numinputs=1) (int n, int * widths) (int size, int i, int *arr){
            
              size = RARRAY_LEN($input);
              arr = new int[size];
            
              for(i = 0; i < size; i++)
              {
                arr[i] = NUM2INT(rb_ary_entry($input,i));
              }
            
              $1 = size;
              $2 = arr;
            }
            
            %typemap(freearg) (int n, int * widths) {
              delete $2;
            }
          __HEREDOC
          # handled; can be suppressed
          spec.suppress_warning(473,
                                'wxFrame::CreateStatusBar',
                                'wxFrame::CreateToolBar',
                                'wxFrame::GetMenuBar',
                                'wxFrame::GetStatusBar',
                                'wxFrame::GetToolBar')
        when 'wxMiniFrame'
          spec.no_proxy %w[
            wxMiniFrame::CreateStatusBar wxMiniFrame::CreateToolBar wxMiniFrame::GetMenuBar wxMiniFrame::GetStatusBar wxMiniFrame::GetToolBar]
        end
      end
    end # class Frame

  end # class Director

end # module WXRuby3
