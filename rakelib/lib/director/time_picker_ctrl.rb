###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
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
