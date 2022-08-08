#--------------------------------------------------------------------
# @file    windows.rb
# @author  Martin Corino
#
# @brief   wxRuby3 buildtools configuration
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  module Config

    # Common settings for compiling on Microsoft Windows with either g++
    # (MingW) or Microsoft Visual C++
    module Windows

      private

      def init_windows_platform
        # Because on Windows wx-config is not available, the path to the
        # compiled wxWidgets library has to be specified using an environment
        # variable
        @wx_path = ENV['WXWIN']
        if not @wx_path or @wx_path.empty?
          raise "Location of wxWidgets library must be specified " +
                "with WXWIN environment variable"
        end

        @wx_xml_path = ENV['WXXML'] || ''


        # wxRuby must be linked against these system libraries; these are turned
        # into linker flags in the relevant compiler rakefile
        @windows_sys_libs = %w| gdi32 gdiplus winspool comdlg32
                               shell32 ole32 oleaut32 uuid
                               odbc32 odbccp32 comctl32
                               rpcrt4 winmm |
      end
    end

  end

end
