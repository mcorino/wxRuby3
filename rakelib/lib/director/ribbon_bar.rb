# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class RibbonBar < Window

      def setup
        super
        # for SetArtProvider (only in RibbonBar)
        spec.disown 'wxRibbonArtProvider *art'
        if Config.instance.wx_version_check('3.3.4') >= 0
          spec.regard 'wxRibbonBar::TriggerKey::keyCode',
                      'wxRibbonBar::TriggerKey::modifiers'
          spec.map 'const std::vector< wxRibbonBar::TriggerKey > &' => 'Array<Wx::RBN::RibbonBar::TriggerKey>' do
            map_out code: <<~__CODE
                $result = rb_ary_new();
                for (const wxRibbonBar::TriggerKey& tkey : *$1)
                {
                  VALUE r_tkey = SWIG_NewPointerObj(new wxRibbonBar::TriggerKey(tkey), SWIGTYPE_p_wxRibbonBar__TriggerKey, SWIG_POINTER_OWN);
                  rb_ary_push($result, r_tkey);
                }
              __CODE
          end
        end
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class RibbonBar

  end # class Director

end # module WXRuby3
