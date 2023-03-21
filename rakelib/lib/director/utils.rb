###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class Utils < Director

      def setup
        spec.items.replace %w[utils.h]
        spec.ignore %w[
          wxGetenv
          wxGetEnv
          wxSetEnv
          wxUnsetEnv
          wxGetEnvMap
          wxSecureZeroMemory
          wxGetBatteryState
          wxGetPowerType
          wxGetDisplayName
          wxSetDisplayName
          wxGetDiskSpace
          wxLoadUserResource
          wxPostDelete
          wxQsort
          wxGetOsVersion
          wxGetLinuxDistributionInfo
          wxExecute
          wxGetProcessId
          wxKill
          wxShell
          wxMicroSleep
          wxMilliSleep
          wxSleep
          wxUsleep
          wxNow
          wxDecToHex
          wxHexToDec
          wxStripMenuCodes
          ]
        spec.ignore 'wxGetEmailAddress(char *,int)',
                    'wxGetUserId(char *,int)',
                    'wxGetUserName(char *,int)'
        # we want only the functions that are not ignored
        spec.do_not_generate(:classes, :typedefs, :variables, :enums, :defines)
        super
      end
    end # class Utils

  end # class Director

end # module WXRuby3
