# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class ToolTip < Director

      def setup
        spec.ignore_unless('WXMSW', 'wxToolTip::SetMaxWidth')
        super
      end
    end # class ToolTip

  end # class Director

end # module WXRuby3
