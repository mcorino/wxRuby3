# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

require_relative './lib/wxapp_runner'

class TestArtProvider < Test::Unit::TestCase

  class MyArtProvider < Wx::ArtProvider

    class << self
      def is_called?
        !!@called
      end
      def set_called(f = true)
        @called = f
      end
    end

    def create_bitmap(id, client, size)
      if id == Wx::ArtProvider.get_message_box_icon_id(Wx::ICON_INFORMATION)
        MyArtProvider.set_called
        Wx::Bitmap(:sample3)
      else
        MyArtProvider.set_called(false)
        super
      end
    end

  end

  def test_custom_provider
    assert_not_nil(Wx::ArtProvider.get_message_box_icon(Wx::ICON_INFORMATION))
    GC.start
    assert(!MyArtProvider.is_called?)
    GC.start
    assert_nothing_raised { Wx::ArtProvider.push(MyArtProvider.new) }
    GC.start
    assert_not_nil(Wx::ArtProvider.get_message_box_icon(Wx::ICON_INFORMATION))
    GC.start
    assert(MyArtProvider.is_called?)
    GC.start
    assert_not_nil(Wx::ArtProvider.get_message_box_icon(Wx::ICON_ERROR))
    GC.start
    assert(!MyArtProvider.is_called?)
    GC.start
    assert_nothing_raised { Wx::ArtProvider.pop }
    GC.start
    assert_not_nil(Wx::ArtProvider.get_message_box_icon(Wx::ICON_INFORMATION))
    GC.start
    assert(!MyArtProvider.is_called?)
    GC.start
  end

end
