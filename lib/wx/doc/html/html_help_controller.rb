# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  module HTML

    class HelpController

      # Returns the latest frame size and position settings and whether a new frame is drawn with each invocation.
      # @return [Array(Wx::Frame,Wx::Size,Wx::Point,Boolean)] latest frame settings
      def get_frame_parameters; end

    end

  end

end
