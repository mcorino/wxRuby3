###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class Icon < Director

      include Typemap::IOStreams

      def setup
        spec.items << 'wxIconBundle'
        spec.gc_as_untracked 'wxIcon'
        spec.gc_as_untracked 'wxIconBundle'
        spec.disable_proxies
        spec.require_app 'wxIcon', 'wxIconBundle'
        # disable as there is no way to distinguish char*/[] from wxString in Ruby
        # and anyway there is no real benefit compared to loading XPM by filename
        spec.ignore('wxIcon::wxIcon(const char *const *)', 'wxIcon::wxIcon(const char[],int,int)')
        # xml specs incorrectly list this method for MWS while it does not exist anymore
        spec.ignore('wxIcon::ConvertToDisabled')
        unless Config.platform == :mingw
          spec.override_inheritance_chain('wxIcon', %w[wxBitmap wxGDIObject wxObject])
          spec.ignore 'wxIconBundle::wxIconBundle(const wxString &, WXHINSTANCE)'
        end
        super
      end
    end # class Icon

  end # class Director

end # module WXRuby3
