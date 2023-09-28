# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class Control < Window

      def setup
        super
        spec.ignore 'wxControl::GetLabelText(const wxString &)'
      end
    end # class Control

  end # class Director

end # module WXRuby3
