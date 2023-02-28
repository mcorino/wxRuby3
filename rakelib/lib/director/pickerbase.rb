###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './window'

module WXRuby3

  class Director

    class PickerBase < Window

      def setup
        super
        spec.ignore 'wxPickerBase::CreateBase'
      end
    end # class PickerBase

  end # class Director

end # module WXRuby3
