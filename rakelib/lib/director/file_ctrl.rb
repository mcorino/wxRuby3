# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class FileCtrl < Window

      def setup
        super
        # for GetFileNames and GetPaths
        spec.map 'wxArrayString &filenames', 'wxArrayString &paths', as: 'Array<String>' do
          map_in ignore: true, temp: 'wxArrayString tmp', code: '$1 = &tmp;'
          map_argout code: <<~__HEREDOC
            $result = rb_ary_new();
            for (size_t i=0; i<tmp$argnum.Count() ;++i)
            {
              rb_ary_push($result, WXSTR_TO_RSTR(tmp$argnum.Item(i)));
            }
            __HEREDOC
        end
      end
    end # class FileCtrl

  end # class Director

end # module WXRuby3
