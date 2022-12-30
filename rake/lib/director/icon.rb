#--------------------------------------------------------------------
# @file    icon.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class Icon < Director

      def setup
        spec.disable_proxies
        # disable as there is no way to distinguish char*/[] from wxString in Ruby
        # and anyway there is no real benefit compared to loading XPM by filename
        spec.ignore('wxIcon::wxIcon(const char *const *)', 'wxIcon::wxIcon(const char[],int,int)')
        # xml specs incorrectly list this method for MWS while it does not exist anymore
        spec.ignore('wxIcon::ConvertToDisabled')
        unless Config.platform == :mingw
          spec.override_inheritance_chain('wxIcon', %w[wxBitmap wxGDIObject wxObject])
        end
        super
      end
    end # class Icon

  end # class Director

end # module WXRuby3
