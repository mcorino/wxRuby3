# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class AnyButton < Window

      def setup
        super
        if Config.instance.wx_port == :wxqt
          # pure abstract so use wxRuby specific impl class
          spec.add_header_code <<~__HEREDOC
            class wxRubyAnyButton : public wxAnyButton
            {
            public:
              wxRubyAnyButton() : wxAnyButton() {}

              int QtGetEventType() const wxOVERRIDE { return -1; }
            };
            __HEREDOC
          spec.use_class_implementation('wxAnyButton', 'wxRubyAnyButton')
        end
      end
    end # class AnyButton

  end # class Director

end # module WXRuby3
