# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxframe_runner'

# test seems to deadlock for WXGTK
if Wx.has_feature?(:USE_MEDIACTRL) && Wx::PLATFORM != 'WXGTK'

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
    uri = URI('/path/to/somewhere/media.type')
    # can't check for true/false since the return value doesn't seem particularly
    # reliable for non-existing media resources
    assert_boolean(media.load(uri))
  end

end

end
