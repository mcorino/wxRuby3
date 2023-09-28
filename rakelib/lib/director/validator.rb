# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event_handler'

module WXRuby3

  class Director

    class Validator < EvtHandler

      def setup
        super
        # make Ruby director and wrappers use custom implementation
        spec.use_class_implementation('wxValidator', 'wxRubyValidator')
        # provide custom wxRuby derivative of validator
        spec.add_header_code <<~__HEREDOC
          class wxRubyValidator : public wxValidator
          {
          public:
            wxRubyValidator () : wxValidator () {}
            virtual ~wxRubyValidator ()
            {
              wxRuby_ReleaseEvtHandlerProcs(this);
            }               

            // these two methods are noops in wxRuby (since we do not support C++ data transfer there) 
            // but we want them to always return true to prevent wxWidgets from complaining 
            bool TransferFromWindow () override { return true; }
            bool TransferToWindow () override { return true; }
          };
          __HEREDOC
        # will be provided as a pure Ruby method
        spec.ignore 'wxValidator::Clone'
        # not provided in Ruby
        spec.ignore %w[wxValidator::TransferFromWindow wxValidator::TransferToWindow]
      end
    end # class Validator

  end # class Director

end # module WXRuby3
