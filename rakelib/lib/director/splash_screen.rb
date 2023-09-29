# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './frame'

module WXRuby3

  class Director

    class SplashScreen < Frame

      def setup
        super
        spec.map 'wxSplashScreenWindow*' => 'Wx::Window' do
          map_out code: '$result = wxRuby_WrapWxObjectInRuby($1);'
        end
      end
    end # class SplashScreen

  end # class Director

end # module WXRuby3
