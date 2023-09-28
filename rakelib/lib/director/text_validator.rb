# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event_handler'

module WXRuby3

  class Director

    class TextValidator < EvtHandler

      def setup
        super
        # need a custom implementation to handle event handler proc cleanup
        spec.add_header_code <<~__HEREDOC
          class WXRubyTextValidator : public wxTextValidator
          {
          public:
            WXRubyTextValidator(const wxTextValidator& v) 
              : wxTextValidator(v) {}
            WXRubyTextValidator(long style=wxFILTER_NONE) 
              : wxTextValidator(style) {}
            virtual ~WXRubyTextValidator() 
            {
              wxRuby_ReleaseEvtHandlerProcs(this);
            }               
          };
        __HEREDOC
        spec.use_class_implementation 'wxTextValidator', 'WXRubyTextValidator'
        # ignore copy ctor doc
        spec.regard 'wxTextValidator::wxTextValidator(const wxTextValidator&)', regard_doc: false
        # ignore this ctor
        spec.ignore 'wxTextValidator::wxTextValidator(long, wxString*)'
        # add alternative
        spec.extend_interface 'wxTextValidator', 'wxTextValidator(long style=wxFILTER_NONE)'
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
