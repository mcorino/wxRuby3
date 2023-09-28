# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class RichTextPrinting < Director

      def setup
        spec.items << 'wxRichTextPrintout'
        super
        spec.no_proxy 'wxRichTextPrinting'
        spec.override_inheritance_chain('wxRichTextPrintout', {'wxPrintout' => 'wxPrinter'}, 'wxObject')
        spec.map_apply 'int * OUTPUT' => 'int *' # for wxRichTextPrintout::GetPageInfo
        # make sure to return by value
        spec.map 'wxRichTextHeaderFooterData &' => 'Wx::RTC::RichTextHeaderFooterData' do
          map_out code: <<~__CODE
            vresult = SWIG_NewPointerObj((new wxRichTextHeaderFooterData(*result)), SWIGTYPE_p_wxRichTextHeaderFooterData, SWIG_POINTER_OWN |  0 );
            __CODE
        end
        # make wxRichTextPrinting GC-safe
        spec.ignore 'wxRichTextPrinting::GetPageSetupData',
                    'wxRichTextPrinting::GetPrintData'
        spec.add_extend_code 'wxRichTextPrinting', <<~__HEREDOC
          wxPrintData* GetPrintData()
          { return new wxPrintData(*self->GetPrintData()); }
          wxPageSetupDialogData* GetPageSetupData()
          { return new wxPageSetupDialogData(*self->GetPageSetupData()); }
          __HEREDOC
        spec.new_object 'wxRichTextPrinting::GetPageSetupData',
                        'wxRichTextPrinting::GetPrintData'
        spec.map 'const wxRect&' => 'Wx::Rect' do
          map_out code: 'vresult = SWIG_NewPointerObj(SWIG_as_voidptr(new wxRect(*result)), SWIGTYPE_p_wxRect, SWIG_POINTER_OWN |  0 );'
        end
        spec.do_not_generate(:variables, :defines, :enums, :functions)
      end
    end # class RichTextPrinting

  end # class Director

end # module WXRuby3
