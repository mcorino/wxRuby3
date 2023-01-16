# Global constant compatibility helper for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands


module WxGlobalConstants

  class << self
    def search_nested(mod, sym)
      # check any nested modules and/or (enum) classes
      const_val = nil
      mod.constants.each do |c|
        case cv = mod.const_get(c)
        when ::Class
          if cv < Wx::Enum
            # the only thing of interest in Enum classes are the enum values
            const_val = cv[sym]
          else
            # prevent const_missing being triggered here since that may lead to unexpected results
            const_val = cv.const_get(sym) if cv.constants.include?(sym)
            const_val = search_nested(cv, sym) unless const_val

          end
        when ::Module
          const_val = cv.const_get(sym) rescue nil
        end
        break if const_val
      end
      const_val
    end
  end

  def self.included(mod)
    # provides backwards compatibility by looking up
    # nested constants as if everything is globally
    # scoped
    def mod.const_missing(sym)
      # check for delayed constants
      Wx.check_delayed_constant(self, sym)
      # check any nested modules and/or (enum) classes
      WxGlobalConstants.search_nested(self, sym) || super
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
