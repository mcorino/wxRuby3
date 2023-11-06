# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

class PGChoicesTests < WxRuby::Test::GUITests

  def test_enum_labels
    texts = %w[Red Blue Green Yellow Black White]
    choices = Wx::PG::PGChoices.new(texts)
    choices.each_label { |lbl| assert_equal(texts.shift, lbl) }
  end

  def test_enum_entries
    texts = %w[Flag1 Flag2 Flag3 Flag4]
    choices = Wx::PG::PGChoices.new
    texts.each_with_index do |s, i|
      choices.add(s, 1 << i)
    end
    choices.each_entry.each_with_index do |entry, ix|
      assert_equal(1 << ix, entry.value)
      assert_equal(texts[ix], entry.get_text)
    end
  end

end
