###
# wxRuby3 rake bin support
# Copyright (c) M.J.N. Corino, The Netherlands
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

      def binaries
        %w{wxruby}
      end
    end

  end

end
