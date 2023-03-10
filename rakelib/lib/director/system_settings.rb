###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class SystemSettings < Director

      def setup
        spec.gc_never
        spec.make_abstract 'wxSystemSettings'
        spec.disable_proxies
        spec.require_app 'wxSystemSettings::GetColour',
                         'wxSystemSettings::GetFont',
                         'wxSystemSettings::GetMetric',
                         'wxSystemSettings::HasFeature',
                         'wxSystemSettings::GetScreenType'
        spec.ignore 'wxSystemSettings::GetAppearance'
        spec.add_extend_code <<~__HEREDOC
          static wxString GetAppearanceName()
          {
            return wxSystemSettings::GetAppearance().GetName();
          }
          static bool IsAppearanceDark()
          {
            return wxSystemSettings::GetAppearance().IsDark();
          }
          static bool IsAppearanceUsingDarkBackground()
          {
            return wxSystemSettings::GetAppearance().IsUsingDarkBackground();
          }
          __HEREDOC
        %w[wxSystemColour wxSystemFont wxSystemMetric].each do |type|
          spec.map type => type.sub(/\Awx/, 'Wx::') do
            map_in code: "$1 = (#{type})NUM2INT($input);"
            map_out code: " $result = INT2NUM((int)$1);"
          end
        end
      end
    end # class SystemSettings

  end # class Director

end # module WXRuby3
