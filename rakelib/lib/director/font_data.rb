# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class FontData < Director

      def setup
        super
        spec.gc_as_untracked 'wxFontData'
        # add copy ctor missing from XML docs
        spec.extend_interface 'wxFontData',
                              'wxFontData(const wxFontData & other)'
        spec.add_swig_code <<~__HEREDOC
          %constant int wxFONTRESTRICT_NONE = wxFONTRESTRICT_NONE;
          %constant int wxFONTRESTRICT_SCALABLE = wxFONTRESTRICT_SCALABLE;
          %constant int wxFONTRESTRICT_FIXEDPITCH = wxFONTRESTRICT_FIXEDPITCH;
          __HEREDOC
      end
    end # class FontData

  end # class Director

end # module WXRuby3
