# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class TimePickerCtrl < Window

      include Typemap::DateTime

      def setup
        super
        spec.map_apply 'int * OUTPUT' => ['int *hour', 'int *min', 'int *sec']
      end
    end # class TimePickerCtrl

  end # class Director

end # module WXRuby3
