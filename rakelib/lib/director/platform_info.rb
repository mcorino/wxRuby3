###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class PlatformInfo < Director

      def setup
        super
        spec.gc_as_untracked
        spec.make_abstract('wxPlatformInfo')
        spec.ignore 'wxPlatformInfo::wxPlatformInfo',
                    'wxPlatformInfo::operator==',
                    'wxPlatformInfo::GetArchitecture',
                    'wxPlatformInfo::GetArchName',
                    'wxPlatformInfo::SetArchitecture',
                    'wxPlatformInfo::SetBitness',
                    'wxPlatformInfo::SetEndianness',
                    'wxPlatformInfo::SetOSVersion',
                    'wxPlatformInfo::SetOperatingSystemId',
                    'wxPlatformInfo::SetPortId',
                    'wxPlatformInfo::SetToolkitVersion',
                    'wxPlatformInfo::SetOperatingSystemDescription',
                    'wxPlatformInfo::SetDesktopEnvironment',
                    'wxPlatformInfo::SetLinuxDistributionInfo',
                    'wxPlatformInfo::GetBitness(const wxString &)',
                    'wxPlatformInfo::GetArch(const wxString &)',
                    'wxPlatformInfo::GetEndianness(const wxString &)',
                    'wxPlatformInfo::GetOperatingSystemId(const wxString &)',
                    'wxPlatformInfo::GetPortId(const wxString &)',
                    'wxPlatformInfo::GetArchName(wxArchitecture)',
                    'wxPlatformInfo::GetBitnessName(wxBitness)',
                    'wxPlatformInfo::GetEndiannessName(wxEndianness)',
                    'wxPlatformInfo::GetOperatingSystemFamilyName(wxOperatingSystemId)',
                    'wxPlatformInfo::GetPortIdName(wxPortId, bool)',
                    'wxPlatformInfo::GetPortIdShortName(wxPortId, bool)',
                    'wxPlatformInfo::GetOperatingSystemIdName(wxOperatingSystemId)',
                    'wxArchitecture'
        spec.rename_for_ruby 'instance' => 'wxPlatformInfo::Get'
      end
    end # class PlatformInfo

  end # class Director

end # module WXRuby3
