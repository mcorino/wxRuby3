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
