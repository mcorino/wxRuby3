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
        spec.map 'wxPrintPreviewBase *' => 'Wx::PrintPreview' do
          # Once a PrintPreview is associated with a PreviewFrame, it is deleted
          # automatically by wxWidgets - so must avoid calling its destructor
          # from Ruby when it is GC'd by disowning the input.
          map_in code: <<~__CODE
            int res$argnum = SWIG_ConvertPtr($input, SWIG_as_voidptrptr(&$1), SWIGTYPE_p_wxPrintPreviewBase, SWIG_POINTER_DISOWN |  0 );
            if (!SWIG_IsOK(res$argnum)) {
              SWIG_exception_fail(SWIG_ArgError(res$argnum), Ruby_Format_TypeError( "", "wxPrintPreview *","wxPreviewFrame", $argnum, $input));
            }
            __CODE
        end
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
