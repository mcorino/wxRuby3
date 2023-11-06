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
    # it doesn't seem the mediactrl returns a very consistent result whether the resource is not a media file
    # or if it is a non-existing file so only check whether it is a boolean return.
    uri = URI("file://#{File.join(__dir__, 'media/beep_lo.wav')}")
    assert_boolean(media.load(uri))
    uri = URI("file://#{File.join(__dir__, 'art/test_art/image/wxruby.png')}")
    assert_boolean(media.load(uri))
  end

end

end
