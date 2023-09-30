# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class AuiMDIChildFrame < Window

      def setup
        super
        spec.no_proxy 'wxAuiMDIChildFrame::Layout'
        # incorrectly documented non-existent virtual method
        # (does exist as non-virtual method in TopLevelWindow with return by value)
        spec.ignore 'wxAuiMDIChildFrame::GetIcon'
        # prevent a lot of unnecessary proxies
        spec.no_proxy %w[
          wxAuiMDIChildFrame::Activate
          wxAuiMDIChildFrame::SetTitle
          wxAuiMDIChildFrame::GetTitle
          wxAuiMDIChildFrame::SetIcons
          wxAuiMDIChildFrame::GetIcons
          wxAuiMDIChildFrame::SetIcon
          wxAuiMDIChildFrame::SetMenuBar
          wxAuiMDIChildFrame::GetMenuBar
          wxAuiMDIChildFrame::GetStatusBar
          wxAuiMDIChildFrame::GetToolBar
          wxAuiMDIChildFrame::Maximize
          wxAuiMDIChildFrame::Restore
          wxAuiMDIChildFrame::Iconize
          wxAuiMDIChildFrame::IsMaximized
          wxAuiMDIChildFrame::IsIconized
          wxAuiMDIChildFrame::ShowFullScreen
          wxAuiMDIChildFrame::IsFullScreen
          ]
        # just rely on the Window implementation
        spec.ignore 'wxAuiMDIChildFrame::IsTopLevel'
        spec.suppress_warning(473,
                              'wxAuiMDIChildFrame::CreateStatusBar',
                              'wxAuiMDIChildFrame::CreateToolBar')
        # for SetStatusWidths
        spec.map 'int n, int widths_field[]' do
          map_in from: {type: 'Array<Integer>', index: 1},
                 temp: 'int size, std::unique_ptr<int[]> arr', code: <<~__CODE
              size = RARRAY_LEN($input);
              arr.reset(new int[size]);
              for(int i = 0; i < size; i++)
              {
                arr.get()[i] = NUM2INT(rb_ary_entry($input,i));
              }
              $1 = size;
              $2 = arr.get();
              __CODE
          map_directorin code: <<~__CODE
            $input = rb_ary_new();
            for (int i = 0; i < $1; i++)
            {
              rb_ary_push($input, INT2NUM($2[i]));
            }
            __CODE
        end
      end
    end # class AuiMDIChildFrame

  end # class Director

end # module WXRuby3
