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
        spec.items.concat %w[
          wxFileDialogCustomize wxFileDialogCustomControl wxFileDialogButton wxFileDialogCheckBox
          wxFileDialogChoice wxFileDialogRadioButton wxFileDialogStaticText wxFileDialogTextCtrl]
        spec.gc_as_marked 'wxFileDialogCustomizeHook' # not tracked but cached in Ruby
        spec.gc_as_untracked %w[
          wxFileDialogCustomize wxFileDialogCustomControl wxFileDialogButton wxFileDialogCheckBox
          wxFileDialogChoice wxFileDialogRadioButton wxFileDialogStaticText wxFileDialogTextCtrl]
        spec.make_abstract 'wxFileDialogCustomize'
        %w[wxFileDialogCustomControl wxFileDialogButton wxFileDialogCheckBox
           wxFileDialogChoice wxFileDialogRadioButton wxFileDialogStaticText
           wxFileDialogTextCtrl].each do |cn|
          spec.make_abstract(cn)
          spec.no_proxy(cn)
        end
        spec.map_apply 'int n, const wxString* choices' => 'size_t n, const wxString *strings'
      end
    end # class FileDialogCustomizeHook

  end # class Director

end # module WXRuby3
