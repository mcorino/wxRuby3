# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 rake bin support
###

require_relative './lib/config'

module WXRuby3

  module Bin

    class << self
      def wxruby
        <<~_SH_TXT
          #!#{WXRuby3.config.windows? ? '/bin/' : (`which env`).strip+' '}#{RB_CONFIG['ruby_install_name']}
          #---------------------------------
          # This file is generated
          #---------------------------------
          module WxRuby
            ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
          end
          require 'wx/wxruby/base'
          WxRuby.run
          _SH_TXT
      end

      def wxruby_bat
        <<~_BAT_TXT
          @echo off
          if not "%~f0" == "~f0" goto WinNT
          #{RB_CONFIG['ruby_install_name']} -Sx "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
          goto endofruby
          :WinNT
          if not exist "%~d0%~p0#{RB_CONFIG['ruby_install_name']}" goto rubyfrompath
          if exist "%~d0%~p0#{RB_CONFIG['ruby_install_name']}" "%~d0%~p0#{RB_CONFIG['ruby_install_name']}" -x "%~f0" %*
          goto endofruby
          :rubyfrompath
          #{RB_CONFIG['ruby_install_name']} -x "%~f0" %*
          goto endofruby
          #!/bin/#{RB_CONFIG['ruby_install_name']}
          #
          module WxRuby
            ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
          end
          require 'wx/wxruby/base'
          WxRuby.run
          __END__
          :endofruby
          _BAT_TXT
      end

      def binaries
        %w{wxruby}
      end
    end

  end

end
