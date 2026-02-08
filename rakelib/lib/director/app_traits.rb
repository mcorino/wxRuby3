# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class AppTraits < Director

      def setup
        super
        spec.items << 'wxStandardPaths'
        spec.gc_as_untracked 'wxAppTraits'
        # stack based global; tracking unwanted
        spec.gc_as_untracked 'wxStandardPaths'
        spec.no_proxy 'wxAppTraits', 'wxStandardPaths'
        spec.make_abstract 'wxAppTraits'

        # we do not want SWIG to see the pure virt methods of wxAppTraits
        # so we ignore all and redefine only those we really want (non virtual)
        spec.ignore %w[
          wxAppTraits::CreateConfig
          wxAppTraits::CreateEventLoop
          wxAppTraits::CreateFontMapper
          wxAppTraits::CreateLogTarget
          wxAppTraits::CreateMessageOutput
          wxAppTraits::CreateRenderer
          wxAppTraits::HasStderr
        ]
        # these next we will redefine so keep the docs
        spec.ignore %w[
          wxAppTraits::GetDesktopEnvironment
          wxAppTraits::GetStandardPaths
          wxAppTraits::GetToolkitVersion
          wxAppTraits::IsUsingUniversalWidgets
          wxAppTraits::ShowAssertDialog
          wxAppTraits::SafeMessageBox
        ], ignore_doc: false
        spec.ignore('wxAppTraits::GetAssertStackTrace', ignore_doc: 'USE_STACKWALKER')
        # redefine
        spec.extend_interface 'wxAppTraits',
                              'wxString GetDesktopEnvironment() const',
                              'wxStandardPaths& GetStandardPaths()',
                              'wxPortId GetToolkitVersion(int *major=NULL, int *minor=NULL, int *micro=NULL) const',
                              'bool IsUsingUniversalWidgets() const',
                              'bool ShowAssertDialog(const wxString& msg)',
                              'bool SafeMessageBox(const wxString &text, const wxString &title)'
        if Config.instance.features_set?('USE_STACKWALKER')
          spec.extend_interface 'wxAppTraits', 'wxString GetAssertStackTrace()'
        end
        spec.map_apply 'int * OUTPUT' => ['int *major', 'int *minor', 'int *micro']

        spec.ignore_unless('WXMSW',
                           'wxStandardPaths::DontIgnoreAppSubDir',
                           'wxStandardPaths::IgnoreAppSubDir',
                           'wxStandardPaths::IgnoreAppBuildSubDirs',
                           'wxStandardPaths::MSWGetShellDir')
        spec.ignore_unless('WXGTK',
                           'wxStandardPaths::SetInstallPrefix',
                           'wxStandardPaths::GetInstallPrefix')
      end
    end

  end

end
