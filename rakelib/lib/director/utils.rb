# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
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
          ]
        # ignore these enum(erator)s
        spec.ignore %w[
          wxSignal
          wxKillError
          wxKillFlags
          wxShutdownFlags
          @.wxEXEC_ASYNC
          @.wxEXEC_SYNC
          @.wxEXEC_SHOW_CONSOLE
          @.wxEXEC_MAKE_GROUP_LEADER
          @.wxEXEC_NODISABLE
          @.wxEXEC_NOEVENTS
          @.wxEXEC_HIDE_CONSOLE
          @.wxEXEC_BLOCK
        ]
        spec.ignore 'wxPostDelete'  unless Config.instance.wx_version >= '3.3.0'
        spec.ignore 'wxGetEmailAddress(char *,int)',
                    'wxGetUserId(char *,int)',
                    'wxGetUserName(char *,int)'
        spec.map 'wxMemorySize' => 'Integer' do
          map_out code: <<~__CODE
            $result = LL2NUM(wxLongLongNative($1).GetValue());
            __CODE
        end
        # we want only the functions that are not ignored
        spec.do_not_generate(:classes, :typedefs, :variables, :defines)
        super
      end
    end # class Utils

  end # class Director

end # module WXRuby3
