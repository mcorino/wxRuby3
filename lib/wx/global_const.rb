# Global constant compatibility helper for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

module WxGlobalConstants

  def self.included(mod)
    # provides backwards compatibility by looking up
    # nested constants as if everything is globally
    # scoped
    def mod.const_missing(sym)
      # check for delayed constants
      Wx.check_delayed_constant(self, sym)
      # check any nested enum modules
      csym = self.constants.detect do |c|
        (sm = self.const_get(c)).class == ::Module && sm.const_defined?(sym)
      end
      if csym
        return self.const_get(csym).const_get(sym)
      elsif self != ::Wx # check the global Wx module (if we're not it)
        ::Wx.const_get(sym)
      else
        super
      end
    end
  end

end
