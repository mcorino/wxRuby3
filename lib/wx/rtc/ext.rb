# Constant extension loader for Wx::RTC
# Copyright (c) M.J.N. Corino, The Netherlands

module Wx::RTC
  if !defined?(::WxGlobalConstants)
    def self.const_missing(sym)
      Wx.check_delayed_constant(self, sym)
      super
    end
  end
end

Dir.glob(File.join(File.dirname(__FILE__), 'ext', '*.rb')) do | fpath |
  require_relative './ext/' + File.basename(fpath)
end
