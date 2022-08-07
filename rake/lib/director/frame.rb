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

      def initialize
        super
      end

      def setup(spec)
        super
        # only for wxFrame class itself
        if spec.module_name == 'wxFrame'
          spec.no_proxy [
            'wxFrame::CreateStatusBar',
            'wxFrame::CreateToolBar',
            'wxFrame::GetMenuBar',
            'wxFrame::GetStatusBar',
            'wxFrame::GetToolBar',
          ]
          spec.ignore [
            'wxFrame::OnCreateStatusBar',
            'wxFrame::OnCreateToolBar'
          ]
          spec.set_only_for('wxmsw', 'wxFrame::MSWGetTaskBarButton')
          spec.add_swig_begin_code <<~__HEREDOC
            %apply SWIGTYPE *DISOWN { wxMenuBar * }
            
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
        end
      end
    end # class Frame

  end # class Director

end # module WXRuby3
