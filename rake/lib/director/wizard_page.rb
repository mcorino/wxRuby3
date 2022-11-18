#--------------------------------------------------------------------
# @file    wizard_page.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

require_relative './window'

module WXRuby3

  class Director

    class WizardPage < Window

      def setup
        super
        if spec.module_name == 'wxWizardPage'
          if Config.instance.wx_version > '3.1.5'
            spec.ignore 'wxWizardPage::wxWizardPage(wxWizard * ,const wxBitmapBundle &)'
          else
            spec.ignore 'wxWizardPage::wxWizardPage(wxWizard * ,const wxBitmap &)'
          end
        elsif spec.module_name == 'wxWizardPageSimple'
          spec.ignore 'wxWizardPageSimple::Chain(wxWizardPageSimple *, wxWizardPageSimple *)'
          # overrides not documented in XML docs
          spec.extend_interface 'wxWizardPageSimple',
                                'virtual wxWizardPage * GetNext() const',
                                'virtual wxWizardPage * GetPrev() const'
        end
        spec.do_not_generate(:variables, :enums, :defines, :functions)
        # handled; can be suppressed
        spec.suppress_warning(473,
                              "#{spec.module_name}::GetNext",
                              "#{spec.module_name}::GetPrev")
      end
    end # class WizardPage

  end # class Director

end # module WXRuby3
