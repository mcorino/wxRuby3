# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

# test seems to deadlock for WXGTK
if Wx.has_feature?(:USE_MEDIACTRL)

require 'uri'

class MediaCtrlTests < WxRuby::Test::GUITests

  def setup
    super
    @media_loaded = false
    @media = Wx::MediaCtrl.new(frame_win)
    frame_win.evt_media_loaded(@media) {|_| @media_loaded = true }
  end

  def teardown
    @media.destroy
    super
  end

  attr_reader :media
  attr_accessor :media_loaded

  def test_uri
    self.media_loaded = false
    uri = URI("file://#{File.join(__dir__, 'media/beep_lo.wav')}")
    assert_true(media.load(uri))
    yield_and_wait_for_test(5000) { self.media_loaded }
    assert_true(self.media_loaded) unless is_msw?
    unless is_macos? || is_msw?
      self.media_loaded = false
      uri = URI("file://#{File.join(__dir__, 'art/test_art/image/wxruby.png')}")
      assert_true(media.load(uri))
      yield_and_wait_for_test(5000) { self.media_loaded }
      assert_true(self.media_loaded)
    end
  end

end

end
