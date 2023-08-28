###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
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
