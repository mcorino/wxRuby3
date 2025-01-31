# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

class PGChoicesTests < WxRuby::Test::GUITests

  def test_enum_labels
    texts = %w[Red Blue Green Yellow Black White]
    choices = Wx::PG::PGChoices.new(texts)
    GC.start
    choices.each_label do |lbl|
      assert_equal(texts.shift, lbl)
      GC.start
    end
  end

  def test_enum_entries
    texts = %w[Flag1 Flag2 Flag3 Flag4]
    choices = Wx::PG::PGChoices.new
    GC.start
    texts.each_with_index do |s, i|
      choices.add(s, 1 << i)
    end
    choices.each_entry.each_with_index do |entry, ix|
      GC.start
      assert_equal(1 << ix, entry.value)
      GC.start
      assert_equal(texts[ix], entry.get_text)
      GC.start
    end
  end

end
