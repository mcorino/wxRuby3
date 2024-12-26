# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

module Wx

  if Wx.has_feature?(:USE_SPELLCHECK)
    class TextProofOptions
      def initialize(schk=false, gchk=false, lang='')
        @spellcheck = schk
        @grammarcheck = gchk
        @language = lang
      end

      def spell_check(f = true)
        @spellcheck = f
        self
      end

      def grammar_check(f = true)
        @grammarcheck = f
        self
      end

      def language(lang)
        @language = lang.to_s
        self
      end
      alias :language= :language

      def is_spell_check_enabled
        @spellcheck
      end
      alias :spell_check_enabled? :is_spell_check_enabled

      def is_grammar_check_enabled
        @grammarcheck
      end
      alias :grammar_check_enabled? :is_grammar_check_enabled

      def get_lang
        @language
      end

      def self.default
        self.new.spell_check
      end

      def self.disable
        self.new
      end
    end
  end

  class TextCtrl
    wx_op_append = instance_method :<<
    wx_redefine_method :<< do |o|
      wx_op_append.bind(self).call(o.to_s)
      self
    end

    # Overload to provide Enumerator without block
    wx_each_line = instance_method :each_line
    wx_redefine_method :each_line do |&block|
      if block
        wx_each_line.bind(self).call(&block)
      else
        ::Enumerator.new { |y| wx_each_line.bind(self).call { |ln| y << ln } }
      end
    end

    if Wx.has_feature?(:USE_SPELLCHECK)

      protected :do_enable_proof_check
      protected :do_get_proof_check_options

      def enable_proof_check(*opts)
        if opts.size>1
          do_enable_proof_check(*opts)
        elsif opts.empty? || (opts.size == 1 && opts.first.is_a?(Wx::TextProofOptions))
          opts = opts.shift || Wx::TextProofOptions.default
          do_enable_proof_check(opts.is_spell_check_enabled, opts.is_grammar_check_enabled, opts.get_lang)
        else
          Kernel.raise ArgumentError.new("Expected Wx::TextProofOptions or (bool, bool, string)")
        end
      end

      def get_proof_check_options
        Wx::TextProofOptions.new(*do_get_proof_check_options)
      end

    end
  end

end
