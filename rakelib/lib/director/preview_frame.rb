###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './frame'

module WXRuby3

  class Director

    class PreviewFrame < Frame

      def setup
        super
        spec.rename_for_ruby('init' => 'wxPreviewFrame::Initialize')
        # We do not wrap the (undocumented) wxPrintPreviewBase so map this to wxPrintPreview what
        # in all cases will be the actual base being used.
        spec.ignore 'wxPreviewFrame::wxPreviewFrame(wxPrintPreviewBase *, wxWindow *,const wxString &,const wxPoint &,const wxSize &,long,const wxString &)'
        spec.extend_interface('wxPreviewFrame',
            'wxPreviewFrame(wxPrintPreview *preview, wxWindow *parent, const wxString &title="Print Preview", const wxPoint &pos=wxDefaultPosition, const wxSize &size=wxDefaultSize, long style=wxDEFAULT_FRAME_STYLE, const wxString &name=wxFrameNameStr)')
        # non-functional map for doc gen
        spec.map 'wxPrintPreviewBase *' => 'Wx::PrintPreview', swig: false do
          map_in
        end
        spec.disown 'wxPrintPreview *preview' # leave ownership to PreviewFrame
        # Not really useful in Ruby as there no accessors to set a custom
        # canvas or control bar.
        # In case one would need a customized preview pane one would probably be
        # better of creating from scratch in Ruby.
        spec.ignore %w[wxPreviewFrame::CreateCanvas wxPreviewFrame::CreateControlBar]
        spec.ignore 'wxPreviewFrame::OnCloseWindow' # not useful for public use
        spec.do_not_generate(:variables, :defines, :enums, :functions) # with PrintAbortDialog
      end
    end # class PreviewFrame

  end # class Director

end # module WXRuby3
