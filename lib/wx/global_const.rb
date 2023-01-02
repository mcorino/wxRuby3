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
      # check any nested modules
      const_val = nil
      self.constants
          .select { |c| self.const_get(c).class == ::Module }
          .detect do |c|
        sm =  self.const_get(c)
        begin
          const_val = sm.const_get(sym)
          true
        rescue NameError
          false
        end
      end
      const_val || super
    end
  end

end

# also take care of things when the Wx module itself is included somewhere
module Wx
  def self.included(mod)
    def mod.const_missing(sym)
      begin
        return ::Wx.const_get(sym)
      rescue NameError
      end
      super
    end
  end
end
