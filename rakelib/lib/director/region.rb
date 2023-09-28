# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Region < Director

      include Typemap::PointsList

      def setup
        super
        spec.require_app 'wxRegion'
        spec.disable_proxies
        spec.gc_as_untracked
        spec.ignore 'wxNullRegion' # does not exist in code
        spec.map_apply 'int n, wxPoint points[]' => [ 'size_t, const wxPoint *']
      end
    end # class Region

  end # class Director

end # module WXRuby3
