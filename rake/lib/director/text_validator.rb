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
      end
    end # class TextValidator

  end # class Director

end # module WXRuby3
