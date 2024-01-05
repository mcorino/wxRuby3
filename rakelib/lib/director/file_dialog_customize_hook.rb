# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class FileDialogCustomizeHook < Director

      def setup
        super
        spec.items << 'wxFileDialogCustomize'
        spec.gc_as_marked 'wxFileDialogCustomizeHook' # not tracked but cached in Ruby
        spec.gc_as_untracked 'wxFileDialogCustomize'
        spec.make_abstract 'wxFileDialogCustomize'
      end
    end # class FileDialogCustomizeHook

  end # class Director

end # module WXRuby3
