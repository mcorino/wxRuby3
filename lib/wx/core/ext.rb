# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

module Wx

  class << self

    private

    class Key
      def initialize(mod, sym)
        @mod = mod
        @sym = sym
      end
      attr_reader :mod, :sym

      def eql?(other)
        self.class === other && mod == other.mod && sym == other.sym
      end

      def hash
        "#{mod}#{sym}".hash
      end
    end

    class Value
      def initialize(code, block)
        @code = code
        @block = block
      end

      def value
        @block ? @block.call : Kernel.eval(@code || 'nil')
      end

      def to_s
        @code || ''
      end
    end

    def delayed_constants
      @delayed_constants ||= ::Hash.new
    end

    public

    def add_delayed_constant(mod, sym, code='', &block)
      delayed_constants[Key.new(mod,sym)] = Value.new(code, block)
    end

    def delayed_constants_for(mod)
      delayed_constants.select { |k,v| k.mod == mod }
    end

    def load_delayed_constants
      delayed_constants.each_pair { |key, val| key.mod.const_set(key.sym, val.value) }
      delayed_constants.clear # cleanup
    end

    def check_delayed_constant(mod, sym)
      if delayed_constants.has_key?(Key.new(mod, sym))
        raise "Delayed constant #{mod.name}::#{sym} cannot be referenced before the Wx::App has started."
      end
    end
  end

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
# Constant extension loader for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands
