# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx

  module STC

    class StyledTextCtrl

      # Overload to provide Enumerator without block
      wx_each_line = instance_method :each_line
      define_method :each_line do |&block|
        if block
          wx_each_line.bind(self).call(&block)
        else
          ::Enumerator.new { |y| wx_each_line.bind(self).call { |ln, lnr| y << [ln, lnr] } }
        end
      end

    end

  end

end
