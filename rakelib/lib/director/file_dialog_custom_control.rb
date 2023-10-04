# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event_handler'

module WXRuby3

  class Director

    class FileDialogCustomControl < EvtHandler

      def setup
        spec.items.concat %w[wxFileDialogButton wxFileDialogCheckBox wxFileDialogRadioButton wxFileDialogChoice wxFileDialogTextCtrl wxFileDialogStaticText]
        super
        spec.gc_as_object
        spec.make_abstract %w[wxFileDialogCustomControl wxFileDialogButton wxFileDialogCheckBox wxFileDialogRadioButton wxFileDialogChoice wxFileDialogTextCtrl wxFileDialogStaticText]
        spec.no_proxy %w[wxFileDialogCustomControl wxFileDialogButton wxFileDialogCheckBox wxFileDialogRadioButton wxFileDialogChoice wxFileDialogTextCtrl wxFileDialogStaticText]
      end
    end # class FileDialogCustomControl

  end # class Director

end # module WXRuby3
