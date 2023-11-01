# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Accessible < Director

      def setup
        super
        spec.make_abstract 'wxAccessible'
        spec.map 'wxAccessible**' => 'Wx::Accessible' do
          map_in ignore: true, temp: 'wxAccessible* tmp', code: '$1 = &tmp;'
          map_argout code: <<~__HEREDOC
            if (tmp$argnum)
            {
              $result = SWIG_Ruby_AppendOutput($result, SWIG_NewPointerObj(SWIG_as_voidptr(tmp$argnum), SWIGTYPE_p_wxAccessible,  0));
            }
            __HEREDOC

        end
        spec.map 'wxString *' => 'String' do
          map_in ignore: true, temp: 'wxString tmp', code: '$1 = &tmp;'
          map_argout code: '$result = SWIG_Ruby_AppendOutput($result, WXSTR_TO_RSTR(tmp$argnum));'
        end
        spec.map 'wxAccRole *' => 'Wx::AccRole' do
          map_in ignore: true, temp: 'wxAccRole tmp', code: '$1 = &tmp;'
          map_argout code: <<~__HEREDOC
            $result = SWIG_Ruby_AppendOutput($result, wxRuby_GetEnumValueObject("AccRole", static_cast<int>(tmp$argnum)));
            __HEREDOC
        end
        spec.map_apply 'int * OUTPUT' => ['int * childCount', 'int * childId', 'int * toId']
        spec.map_apply 'long * OUTPUT' => 'long * state'
      end

    end

  end

end

