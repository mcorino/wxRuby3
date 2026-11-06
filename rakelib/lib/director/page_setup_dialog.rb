# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './dialog'

module WXRuby3

  class Director

    class PageSetupDialog < Director::Dialog

      def setup
        super
        # make PageSetupDialog GC-safe
        spec.add_header_code <<~__HEREDOC
          static void wxRuby_delete_wxPageSetupDialog(void *self) 
          {
              wxPageSetupDialog *arg1 = (wxPageSetupDialog *)self;
              SWIG_RubyRemoveTracking(arg1);
              delete arg1;
          }

          static void GC_free_wxPageSetupDialog(void* object)
          {
            wxRuby_RegisterDeferredObjectDestroy(object, wxRuby_delete_wxPageSetupDialog);
          }
          __HEREDOC
        # wxPageSetupDialog is not actually a dialog, just a platform independent wrapper derived from wxObject,
        # so it is not caught by the generic wxWindow post-processor but still needs a deferred destroy as
        # destroying it will also destroy the wrapped actual dialog.
        spec.add_swig_code '%feature("freefunc") wxPageSetupDialog "GC_free_wxPageSetupDialog";'
        spec.ignore 'wxPageSetupDialog::GetPageSetupData'
        spec.add_extend_code 'wxPageSetupDialog', <<~__HEREDOC
          wxPageSetupDialogData* GetPageSetupData()
          { return new wxPageSetupDialogData(self->GetPageSetupData()); }
          void SetPageSetupData(const wxPageSetupDialogData& psdd)
          { self->GetPageSetupData() = psdd; }
          __HEREDOC
        spec.new_object 'wxPageSetupDialog::GetPageSetupData'
      end
    end # class PageSetupDialog

  end # class Director

end # module WXRuby3
