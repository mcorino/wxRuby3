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
        spec.ignore('wxToolTip::SetMaxWidth') unless Config.instance.features_set?('__WXMSW__')
        super
      end
    end # class ToolTip

  end # class Director

end # module WXRuby3
