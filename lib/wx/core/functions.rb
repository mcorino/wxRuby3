# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Tweaks to the global module functions

module Wx
  class << self
    # Allow this to be called with keyword parameters, and avoid
    # segfaults on OS X with bad params
    wx_about_box = self.instance_method(:about_box)
    define_method(:about_box) do | info, parent=nil |
      case info
      when Wx::AboutDialogInfo
        ab_info = info
      when Hash
        ab_info = Wx::AboutDialogInfo.new
        ab_info.name    = info[:name] || 'wxRuby application'
        ab_info.version = info[:version] if info[:version]
        
        ab_info.description = info[:description] || ''
        ab_info.copyright   = info[:copyright] || ''
        ab_info.licence     = info[:licence] || ''
        ab_info.developers  = info[:developers] || []
        ab_info.doc_writers = info[:doc_writers] || []
        ab_info.artists     = info[:artists] || []
        ab_info.translators = info[:translators] || []
        if info.key?(:website)
          ab_info.set_web_site(*info[:website])
        end
        if info.key?(:icon)
          ab_info.icon = info[:icon]
        end

      else
        Kernel.raise ArgumentError,
                     "Can't use #{info.inspect} for AboutDialogInfo"
      end
      wx_about_box.bind(self).call(ab_info, parent)
    end
  end
end
