###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

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
            wxFrame::CreateStatusBar
            wxFrame::CreateToolBar
            wxFrame::SetMenuBar
            wxFrame::GetMenuBar
            wxFrame::SetStatusBar
            wxFrame::GetStatusBar
            wxFrame::SetToolBar
            wxFrame::GetToolBar]
          spec.ignore %w[
            wxFrame::OnCreateStatusBar wxFrame::OnCreateToolBar]
          spec.set_only_for(%w[__WXMSW__ wxUSE_TASKBARBUTTON], 'wxFrame::MSWGetTaskBarButton')
          # this reimplemented window base method need to be properly wrapped but
          # is missing from the XML docs
          spec.extend_interface('wxFrame', 'virtual void OnInternalIdle()')
          spec.disown 'wxMenuBar *'
          spec.map 'int n, int * widths' do
            map_in from: {type: 'Array<Integer>', index: 1},
                   temp: 'int size, int i, int *arr', code: <<~__CODE
              size = RARRAY_LEN($input);
              arr = new int[size];
              for(i = 0; i < size; i++)
              {
                arr[i] = NUM2INT(rb_ary_entry($input,i));
              }
              $1 = size;
              $2 = arr;
              __CODE
            map_freearg code: 'delete $2;'
          end
          # handled; can be suppressed
          spec.suppress_warning(473,
                                'wxFrame::CreateStatusBar',
                                'wxFrame::CreateToolBar',
                                'wxFrame::GetMenuBar',
                                'wxFrame::GetStatusBar',
                                'wxFrame::GetToolBar')
        else # 'wxMiniFrame', 'wxMDIFrame', 'wxAuiMDIParentFrame'
          spec.items.each do |cls|
            spec.no_proxy %W[
              #{cls}::CreateStatusBar
              #{cls}::CreateToolBar
              #{cls}::SetMenuBar
              #{cls}::GetMenuBar
              #{cls}::SetStatusBar
              #{cls}::GetStatusBar
              #{cls}::SetToolBar
              #{cls}::GetToolBar
              ]
          end
        end
      end
    end # class Frame

  end # class Director

end # module WXRuby3
