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
    @media = Wx::MediaCtrl.new(frame_win)
  end

  def cleanup
    @media.destroy
    super
  end

  attr_reader :media

  def test_uri
    # just checking if Ruby URI is properly mapped
    uri = URI("file://#{File.join(__dir__, 'media/beep_lo.wav')}")
    assert_true(media.load(uri))
    # it doesn't seem the mediactrl returns false if the resource is not a media file
    # as long as it is an existing file (it seems Windows/MacOS even return true if the resource is non-existent)
    uri = URI("file://#{File.join(__dir__, 'art/test_art/image/wxruby.png')}")
    assert_true(media.load(uri))
  end

end

end
