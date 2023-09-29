# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

class MultilineProofCheckTests < WxRuby::Test::GUITests

  def setup
    super
    @text = Wx::TextCtrl.new(frame_win, name: 'Text', style: Wx::TE_MULTILINE|Wx::TE_RICH|Wx::TE_RICH2)
  end

  def cleanup
    @text.destroy
    super
  end

  attr_reader :text
  alias :text_entry :text

  if Wx.has_feature?(:USE_SPELLCHECK)

    def test_spell_check

      assert_true(text.enable_proof_check(Wx::TextProofOptions.default))
      Wx.get_app.yield
      proof_opts = text.get_proof_check_options
      assert_instance_of(Wx::TextProofOptions, proof_opts)
      assert_true(proof_opts.is_spell_check_enabled) unless Wx::PLATFORM == 'WXGTK'
      assert_false(proof_opts.is_grammar_check_enabled)
      if Wx::PLATFORM != 'WXMSW' || Wx::WXWIDGETS_VERSION >= '3.3'
        assert_true(text.enable_proof_check(Wx::TextProofOptions.disable))
      else
        assert_false(text.enable_proof_check(Wx::TextProofOptions.disable)) # incorrect return value for WXMSW
      end
      Wx.get_app.yield
      proof_opts = text.get_proof_check_options
      assert_instance_of(Wx::TextProofOptions, proof_opts)
      assert_false(proof_opts.is_spell_check_enabled) unless Wx::PLATFORM == 'WXGTK'
      assert_false(proof_opts.is_grammar_check_enabled)
      assert_true(text.enable_proof_check(Wx::TextProofOptions.default.grammar_check(true)))
      Wx.get_app.yield
      proof_opts = text.get_proof_check_options
      assert_true(proof_opts.is_spell_check_enabled) unless Wx::PLATFORM == 'WXGTK'
      assert_true(proof_opts.is_grammar_check_enabled) if Wx::PLATFORM == 'WXOSX'

    end

  end

end
