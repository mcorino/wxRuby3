# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx

  module HTML

    class HtmlWindow

      # Need to override HtmlWindow.add_filter to provide cashing
      # for the added custom html filters to prevent premature GC
      class << self
        def html_filters
          @html_filters ||= []
        end
        private :html_filters

        wx_add_filter = instance_method(:add_filter)
        wx_redefine_method(:add_filter) do |filter|
          html_filters << filter
          wx_add_filter.bind(self).call(filter)
        end
      end

    end

  end

end
