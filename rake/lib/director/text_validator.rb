###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event_handler'

module WXRuby3

  class Director

    class TextValidator < EvtHandler

      def setup
        super
        # to correctly translate customized inheritance to actual class names
        spec.rename_class('wxValidator', 'wxRubyValidator')
        spec.add_header_code <<~__HEREDOC
            // Make sure C++ compiler knows we mean wxValidator here
            #define wxRubyValidator wxValidator
        __HEREDOC
        spec.override_inheritance_chain('wxTextValidator', {'wxRubyValidator' => 'wxValidator'}, 'wxEvtHandler', 'wxObject')
        spec.no_proxy 'wxTextValidator::Clone'
        spec.new_object 'wxTextValidator::Clone'
        # handle clone mapping
        spec.map 'wxObject *' => 'Wx::TextValidator' do
          map_out code: <<~__CODE
            $result = SWIG_NewPointerObj(SWIG_as_voidptr($1), SWIGTYPE_p_wxTextValidator, SWIG_POINTER_OWN |  0 );
            __CODE
        end
        # not provided in Ruby
        spec.ignore %w[wxTextValidator::TransferFromWindow wxTextValidator::TransferToWindow]
        # bit flags
        spec.make_enum_untyped 'wxTextValidatorStyle'
      end
    end # class TextValidator

  end # class Director

end # module WXRuby3
