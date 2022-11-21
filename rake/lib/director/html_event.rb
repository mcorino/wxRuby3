#--------------------------------------------------------------------
# @file    html_event.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './event'

module WXRuby3

  class Director

    class HtmlEvent < Event

      def setup
        super
        spec.ignore_bases(spec.module_name => %w[wxCommandEvent]) # needed to suppress imports
        spec.swig_import('swig/classes/include/wxObject.h', 'swig/classes/include/wxEvent.h', append_to_base_imports: true) # provide base definitions
        spec.override_base(spec.module_name, 'wxCommandEvent') # re-establish correct base
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class HtmlEvent

  end # class Director

end # module WXRuby3
