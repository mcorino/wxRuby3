# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:


module Wx

  # This class provides a convenient means of passing multiple parameters to {Wx::TextCtrl#enable_proof_check}.
  #
  # By default, i.e. when calling #enable_proof_check without any parameters, Wx::TextProofOptions.default proof options
  # are used, which enable spelling (but not grammar) checks for the current language.
  #
  # However it is also possible to customize the options:
  #   ```ruby
  #   textctrl.enable_proof_check(Wx::TextProofOptions.default.language("fr").grammar_check)
  #   ````
  #
  # or disable all checks entirely:
  #   ```ruby
  #   textctrl.enable_proof_check(Wx::TextProofOptions.disable)
  #   ````
  #
  # This class is only available if `Wx.has_feature?(:USE_SPELLCHECK)` returns true.
  class TextProofOptions
    def initialize(schk=false, gchk=false, lang='')end

    # @param [Boolean] f
    def spell_check(f = true) end

    # @param [Boolean] f
    def grammar_check(f = true) end

    # @param [String] lang
    def language(lang) end
    alias :language= :language

    # @return [Boolean]
    def is_spell_check_enabled; end
    alias :spell_check_enabled? :is_spell_check_enabled

    # @return [Boolean]
    def is_grammar_check_enabled; end
    alias :grammar_check_enabled? :is_grammar_check_enabled

    # @return [String]
    def get_lang; end

    # Return the object corresponding to the default options: current
    # language, spell checking enabled, grammar checking disabled.
    # @return [Wx::TextProofOptions]
    def self.default; end

    # Return the object with all checks disabled.
    # @return [Wx::TextProofOptions]
    def self.disable; end
  end

  class TextCtrl

    # Appends the string representation of `obj` to the text value of the control.
    # Calls #to_s to get the string representation of `obj`.
    # @param [Object] obj
    # @return [self]
    def <<(obj) end

    # Yield each line to the given block.
    # Returns an Enumerator if no block given.
    # @yieldparam [String] line the line yielded
    # @yieldparam [Integer] line_nr the line nr
    # @return [Object,Enumerator] last result of block or Enumerator if no block given.
    def each_line; end

    # @overload enable_proof_check(text_proof_options = Wx::TextProofOptions.default)
    #   Enable or disable native spell checking on this text control if it is available on the current platform.
    #   Currently this is supported in WXMSW (when running under Windows 8 or later), WXGTK when using GTK 3 and wxOSX.
    #   In addition, WXMSW requires that the text control has the Wx::TE_RICH2 style set, while WXOSX requires that the
    #   control has the Wx::TE_MULTILINE style.
    #   When using WXGTK, this method only works if gspell library was available during the wxWidgets library build.
    #   @param [Wx::TextProofOptions] text_proof_options A Wx::TextProofOptions object specifying the desired behaviour of the proof checker (e.g. language to use, spell check, grammar check, etc.) and whether the proof checks should be enabled at all. By default, spelling checks for the current language are enabled. Passing Wx::TextProofOptions.disable disables all the checks.
    #   @return [Boolean] true if proof checking has been successfully enabled or disabled, false otherwise (usually because the corresponding functionality is not available under the current platform or for this type of text control).
    # @overload enable_proof_check(spell_checking, grammar_checking, language)
    #   Enable or disable native spell checking on this text control if it is available on the current platform.
    #   Currently this is supported in WXMSW (when running under Windows 8 or later), WXGTK when using GTK 3 and wxOSX.
    #   In addition, WXMSW requires that the text control has the Wx::TE_RICH2 style set, while WXOSX requires that the
    #   control has the Wx::TE_MULTILINE style.
    #   When using WXGTK, this method only works if gspell library was available during the wxWidgets library build.
    #   @param [Boolean] spell_checking_options
    #   @param [Boolean] grammar_checking
    #   @param [String] language
    #   @return [Boolean] true if proof checking has been successfully enabled or disabled, false otherwise (usually because the corresponding functionality is not available under the current platform or for this type of text control).
    def enable_proof_check(*opts) end

    # Returns the current text proofing options.
    # Only available if `Wx.has_feature?(:USE_SPELLCHECK)` returns true.
    # @return [Wx::TextProofOptions]
    def get_proof_check_options; end

  end

end
