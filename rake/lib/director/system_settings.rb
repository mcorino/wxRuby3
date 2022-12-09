#--------------------------------------------------------------------
# @file    system_settings.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class SystemSettings < Director

      def setup
        spec.gc_as_object
        spec.ignore 'wxSystemSettings::GetAppearance'
        %w[wxSystemColour wxSystemFont wxSystemMetric].each do |type|
          spec.map type do
            map_type type.sub(/\Awx/, 'Wx::')
            map_in code: "$1 = (#{type})NUM2INT($input);"
            map_out code: " $result = INT2NUM((int)$1);"
          end
        end
      end
    end # class SystemSettings

  end # class Director

end # module WXRuby3
