###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event_handler'

module WXRuby3

  class Director

    class NumericPropertyValidator < EvtHandler

      def setup
        super
        # need a custom implementation to handle event handler proc cleanup
        spec.add_header_code <<~__HEREDOC
          class WXRubyNumericPropertyValidator : public wxNumericPropertyValidator
          {
          public:
            WXRubyNumericPropertyValidator(NumericType numericType, int base=10) 
              : wxNumericPropertyValidator(numericType, base) {}
            virtual ~WXRubyNumericPropertyValidator() 
            {
              wxRuby_ReleaseEvtHandlerProcs(this);
            }               
          };
        __HEREDOC
        spec.use_class_implementation 'wxNumericPropertyValidator', 'WXRubyNumericPropertyValidator'
        spec.no_proxy 'wxNumericPropertyValidator::Clone'
        spec.do_not_generate :variables, :defines, :enums, :functions
      end

    end # class NumericPropertyValidator

  end # class Director

end # module WXRuby3
