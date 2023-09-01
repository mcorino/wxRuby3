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
          spec.ignore %w[
            wxFrame::OnCreateStatusBar wxFrame::OnCreateToolBar]
          unless Config.instance.features_set?(*%w[__WXMSW__ wxUSE_TASKBARBUTTON])
            spec.ignore('wxFrame::MSWGetTaskBarButton')
          end
          # this reimplemented window base method need to be properly wrapped but
          # is missing from the XML docs
          spec.extend_interface('wxFrame', 'virtual void OnInternalIdle()')
          spec.disown 'wxMenuBar *'
          spec.map 'int n, int * widths' do
            map_in from: {type: 'Array<Integer>', index: 1},
                   temp: 'int size, int i, std::unique_ptr<int[]> arr', code: <<~__CODE
              size = RARRAY_LEN($input);
              arr.reset(new int[size]);
              for(i = 0; i < size; i++)
              {
                arr.get()[i] = NUM2INT(rb_ary_entry($input,i));
              }
              $1 = size;
              $2 = arr.get();
              __CODE
          end
          # handled; can be suppressed
          spec.suppress_warning(473,
                                'wxFrame::CreateStatusBar',
                                'wxFrame::CreateToolBar',
                                'wxFrame::GetMenuBar',
                                'wxFrame::GetStatusBar',
                                'wxFrame::GetToolBar')
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
