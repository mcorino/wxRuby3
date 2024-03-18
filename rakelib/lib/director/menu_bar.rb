# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class MenuBar < Window

      def setup
        super
        spec.no_proxy('wxMenuBar::FindItem',
                'wxMenuBar::Remove',
                'wxMenuBar::Replace')
        spec.ignore('wxMenuBar::wxMenuBar(size_t,wxMenu *[],const wxString[],long)',
                'wxMenuBar::GetLabelTop',
                'wxMenuBar::SetLabelTop',
                'wxMenuBar::Refresh')
        # for FindItem
        spec.map 'wxMenu **' => 'Wx::Menu' do
          map_in ignore: true, temp: 'wxMenu *tmp', code: '$1 = &tmp;'
          map_argout code: <<~__CODE
            void *ptr = tmp$argnum;
            $result = SWIG_Ruby_AppendOutput($result, SWIG_NewPointerObj(ptr, SWIGTYPE_p_wxMenu, 0));
            __CODE
        end
      end
    end # class MenuBar

  end # class Director

end # module WXRuby3
