# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './frame'

module WXRuby3

  class Director

    class PreviewFrame < Frame

      def setup
        super
        # we need access to the wxPrintPreview maintained in the frame
        # for GC marking so define a derived class for that.
        spec.add_header_code <<~__HEREDOC
          class WxRubyPreviewFrame : public wxPreviewFrame
          {
          public:
            WxRubyPreviewFrame(wxPrintPreviewBase *preview,
                               wxWindow *parent,
                               const wxString& title = wxGetTranslation(wxASCII_STR("Print Preview")),
                               const wxPoint& pos = wxDefaultPosition,
                               const wxSize& size = wxDefaultSize,
                               long style = wxDEFAULT_FRAME_STYLE | wxFRAME_FLOAT_ON_PARENT,
                               const wxString& name = wxASCII_STR(wxFrameNameStr))
              : wxPreviewFrame(preview, parent, title, pos, size, style, name)
            {}
            virtual ~WxRubyPreviewFrame() {}

            const wxPrintPreview* get_print_preview() const 
            {
              return dynamic_cast<const wxPrintPreview*> (this->m_printPreview); 
            }
          };

          static void GC_mark_wxPreviewFrame(void *ptr)
          {
            if ( GC_IsWindowDeleted(ptr) )
              return;
        
            // Do standard marking routines as for all wxWindows
            GC_mark_wxWindow(ptr);

            WxRubyPreviewFrame* preview_frame = dynamic_cast<WxRubyPreviewFrame*>((wxPreviewFrame*)ptr);
            if (preview_frame)
            {
              const void* ptr = (const void*)preview_frame->get_print_preview();
              rb_gc_mark(SWIG_RubyInstanceFor(const_cast<void*> (ptr)));              
            }
          }
        __HEREDOC
        spec.use_class_implementation 'wxPreviewFrame', 'WxRubyPreviewFrame'
        spec.add_swig_code '%markfunc wxPreviewFrame "GC_mark_wxPreviewFrame";'
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
