# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
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
