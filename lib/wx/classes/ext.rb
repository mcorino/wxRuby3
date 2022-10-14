# Constant extension loader for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands

module Wx

  class << self

    private

    def delayed_constants
      @delayed_constants ||= {}
    end

    public

    def add_delayed_constant(sym, &block)
      delayed_constants[sym] = block
    end

    def load_delayed_constants
      delayed_constants.each_pair { |sym, blk| Wx.const_set(sym, blk.call) }
    end
  end

  def Wx.const_missing(sym)
    if delayed_constants.has_key?(sym)
      raise "Delayed constant Wx::#{sym} cannot referenced before the Wx::App has started."
    else
      super
    end
  end

end

Dir.glob(File.join(File.dirname(__FILE__), 'ext', '*.rb')) do | fpath |
  require_relative './ext/' + File.basename(fpath)
end
