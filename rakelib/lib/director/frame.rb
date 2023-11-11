# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
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
          spec.ignore %w[
            wxFrame::OnCreateStatusBar wxFrame::OnCreateToolBar]
          spec.ignore_unless(%w[WXMSW USE_TASKBARBUTTON], 'wxFrame::MSWGetTaskBarButton')
          # this reimplemented window base method need to be properly wrapped but
          # is missing from the XML docs
          spec.extend_interface('wxFrame', 'virtual void OnInternalIdle()')
          spec.disown 'wxMenuBar *'
          # handled; can be suppressed
          spec.suppress_warning(473,
                                'wxFrame::CreateStatusBar',
                                'wxFrame::CreateToolBar',
                                'wxFrame::GetMenuBar',
                                'wxFrame::GetStatusBar',
                                'wxFrame::GetToolBar')
        end
        # for SetStatusWidths
        spec.map 'int n, int * widths_field' do
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

      def process(gendoc: false)
        defmod = super
        spec.items.each do |citem|
          def_item = defmod.find_item(citem)
          if Extractor::ClassDef === def_item && (citem == 'wxFrame' || spec.is_derived_from?(def_item, 'wxFrame'))
            spec.no_proxy %W[
              #{spec.class_name(citem)}::CreateStatusBar
              #{spec.class_name(citem)}::CreateToolBar
              #{spec.class_name(citem)}::SetMenuBar
              #{spec.class_name(citem)}::GetMenuBar
              #{spec.class_name(citem)}::SetStatusBar
              #{spec.class_name(citem)}::GetStatusBar
              #{spec.class_name(citem)}::SetToolBar
              #{spec.class_name(citem)}::GetToolBar
              ]
          end
        end
        defmod
      end
      
    end # class Frame

  end # class Director

end # module WXRuby3
