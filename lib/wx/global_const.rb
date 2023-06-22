# Global constant compatibility helper for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

module WxGlobalConstants

  class << self
    def search_nested(mod, sym, path = [])
      # check any nested modules and/or (enum) classes
      const_val = nil
      org_verbose = $VERBOSE
      begin
        $VERBOSE = nil
        mod.constants.each do |c|
          case cv = mod.const_get(c)
          when ::Class
            if cv < Wx::Enum
              # the only thing of interest in Enum classes are the enum values
              const_val = cv[sym]
            elsif cv.name.start_with?('Wx::') # only search Wx namespace
              # prevent const_missing being triggered here since that may lead to unexpected results
              const_val = cv.const_get(sym) if cv.constants.include?(sym)
              const_val = search_nested(cv, sym, path+[mod]) unless const_val || path.include?(cv)
            end
          when ::Module
            if cv.name.start_with?('Wx::') # only search Wx namespace
              const_val = cv.const_get(sym)  if cv.constants.include?(sym)
              const_val = search_nested(cv, sym, path+[mod]) unless const_val || path.include?(cv)
            end
          end unless mod == cv # watch out for infinite recursion
          break if const_val
        end
      ensure
        $VERBOSE = org_verbose
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

module WxEnumConstants

  class << self
    def search_nested(mod, sym)
      # check any nested enum classes
      const_val = nil
      mod.constants.each do |c|
        if ::Class === (cv = mod.const_get(c)) && cv < Wx::Enum
          # the only thing of interest in Enum classes are the enum values
          const_val = cv[sym]
        end
        break if const_val
      end
      const_val
    end
  end

  def self.included(mod)
    # provides lookup for unscoped enum values
    def mod.const_missing(sym)
      # check any nested enum classes
      WxEnumConstants.search_nested(self, sym) || super
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
