###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class HelpController < Director

      def setup
        super
        spec.items << 'wxHelpControllerBase'
        spec.fold_bases(spec.module_name => 'wxHelpControllerBase')
        spec.rename_for_ruby('Init' => "#{spec.module_name}::Initialize")
        # ignore these (pure virtual) decls
        spec.ignore %w[
          wxHelpControllerBase::DisplayBlock
          wxHelpControllerBase::DisplaySection
          wxHelpControllerBase::LoadFile
          wxHelpControllerBase::Quit
          ]
        # and add them as the implemented overrides they are
        spec.extend_interface spec.module_name,
                              'virtual bool DisplayBlock(long blockNo)',
                              'virtual bool DisplaySection(int sectionNo)',
                              'virtual bool LoadFile(const wxString &file=wxEmptyString)',
                              'virtual bool Quit()'
        if spec.module_name == 'wxHtmlHelpController'
          spec.ignore 'wxHtmlHelpController::CreateHelpFrame'
          spec.suppress_warning(473,
                                'wxHtmlHelpController::GetFrameParameters',
                                'wxHtmlHelpController::GetParentWindow')
        end
      end
    end # class HelpController

  end # class Director

end # module WXRuby3
