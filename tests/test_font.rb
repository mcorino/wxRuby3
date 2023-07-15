
require_relative './lib/wxapp_runner'

class FontTests < Test::Unit::TestCase

  def get_test_fonts
    [
      Wx::Font.new(Wx::NORMAL_FONT),
      Wx::Font.new(Wx::SMALL_FONT),
      Wx::Font.new(Wx::ITALIC_FONT),
      Wx::Font.new(Wx::SWISS_FONT),
      Wx::Font.new(5, Wx::FontFamily::FONTFAMILY_TELETYPE, Wx::FontStyle::FONTSTYLE_NORMAL, Wx::FontWeight::FONTWEIGHT_NORMAL)
    ]
  end

  def test_size
    sz_klass = Struct.new(:specified, # Size in points specified in the ctor.
                          :expected)  # Expected GetPointSize() return value,
                                      # -1 here means "same as wxNORMAL_FONT".
    sizes = [
      sz_klass.new(9,9),
      sz_klass.new(10, 10),
      sz_klass.new(11, 11),
      sz_klass.new(-1, -1),
      sz_klass.new(70, -1),
      sz_klass.new(90, 90),
    ]
    
    size_default = Wx::Font.new(Wx::FontInfo.new).get_point_size

    sizes.each do |size|
        # Note: use the old-style wxFont ctor as wxFontInfo doesn't implement
        # any compatibility hacks.
        font = Wx::Font.new(size.specified,
                            Wx::FONTFAMILY_DEFAULT,
                            Wx::FONTSTYLE_NORMAL,
                            Wx::FONTWEIGHT_NORMAL)

        expected = size.expected
        expected = size_default if expected == -1

        puts "specified = #{size.specified}, expected =  #{size.expected}" unless is_ci_build?
        assert_equal(expected, font.get_point_size)
    end

    # Note that the compatibility hacks only apply to the old ctors, the newer
    # one, taking wxFontInfo, doesn't support them.
    assert_equal(70, Wx::Font.new(Wx::FontInfo.new(70)).get_point_size)
    assert_equal(90, Wx::Font.new(Wx::FontInfo.new(90)).get_point_size)

    # assert_equal fractional point sizes as well.
    font = Wx::Font.new(Wx::FontInfo.new(12.25))
    assert_equal(12.25,  font.get_fractional_point_size)
    assert_equal(12, font.get_point_size)

    font = Wx::NORMAL_FONT
    font.set_fractional_point_size(9.5)
    assert_equal(9.5, font.get_fractional_point_size)
    assert_equal(10, font.get_point_size)
  end

  def test_weight
    font = Wx::Font.new
    font.set_numeric_weight(123)

    assert_equal(123, font.get_numeric_weight) unless Wx::PLATFORM == 'WXOSX'

    assert_equal(Wx::FontWeight::FONTWEIGHT_THIN,  font.get_weight)

    font.set_numeric_weight(Wx::FontWeight::FONTWEIGHT_SEMIBOLD)
    assert_equal(Wx::FontWeight::FONTWEIGHT_SEMIBOLD, font.get_numeric_weight)
    assert_equal(Wx::FontWeight::FONTWEIGHT_SEMIBOLD, font.get_weight)
  end

  def test_get_set

    get_test_fonts.each_with_index do |test, n|

      assert(test.ok?)

      # test Get/SetFaceName()
      assert( !test.set_face_name("a dummy face name") )
      assert( !test.ok? )

      # if the call to set_face_name() below fails on your system/port,
      # consider adding another branch to this if
      known_good_face_name = if Wx::PLATFORM == 'WXMSW' || Wx::PLATFORM == 'WXOSX'
                               "Arial"
                             else
                               "Monospace"
                             end

      puts("Testing font ##{n}") unless is_ci_build?

      puts("setting face name to #{known_good_face_name}") unless is_ci_build?
      assert( test.set_face_name(known_good_face_name) )
      assert( test.ok? )


      # test get/set_family()

      test.set_family(Wx::FontFamily::FONTFAMILY_ROMAN )
      assert( test.ok? )

      # note that there is always the possibility that get_family() returns
      # Wx::FONTFAMILY_DEFAULT (meaning "unknown" in this case) so that we
      # consider it as a valid return value
      family = test.get_family
      if family != Wx::FONTFAMILY_DEFAULT
        assert_equal(Wx::FONTFAMILY_ROMAN, family )
      end


      # test get/set_point_size()

      test.set_point_size(30)
      assert( test.ok? )
      assert_equal( 30, test.get_point_size )


      # test get/set_pixel_size()

      test.set_pixel_size(Wx::Size.new(0,30))
      assert( test.ok? )
      assert( test.get_pixel_size.get_height <= 30 )
        # NOTE: the match found by set_pixel_size() may be not 100% precise it
        #       only grants that a font smaller than the required height will
        #       be selected


      # test get/set_style()

      test.set_style(Wx::FONTSTYLE_SLANT)
      assert( test.ok? )
      # on wxMSW Wx::FONTSTYLE_SLANT==Wx::FONTSTYLE_ITALIC, so accept the latter
      # as a valid value too.
      if ( test.get_style != Wx::FONTSTYLE_SLANT )
        assert( Wx::PLATFORM == 'WXMSW' && Wx::FONTSTYLE_ITALIC == test.get_style )
      end

      # test get/set_underlined()

      test.set_underlined(true)
      assert( test.ok? )
      assert( test.get_underlined )

      fontBase = test.get_base_font
      assert( fontBase.ok? )
      assert( !fontBase.get_underlined )
      assert( !fontBase.get_strikethrough )
      assert_equal( Wx::FONTWEIGHT_NORMAL, fontBase.get_weight )
      assert_equal( Wx::FONTSTYLE_NORMAL, fontBase.get_style )

      # test get/set_strikethrough()

      test.set_strikethrough(true)
      assert( test.ok? )
      assert( test.get_strikethrough )


      # test get/set_weight()

      test.set_weight(Wx::FONTWEIGHT_BOLD)
      assert( test.ok? )
      assert_equal( Wx::FONTWEIGHT_BOLD, test.get_weight )
    end

  end

  unless Wx::PLATFORM == 'WXOSX'
    def test_native_font_info
      get_test_fonts.each_with_index do |test, n|
          nid = test.get_native_font_info_desc
          assert( !nid.empty? )
          # documented to be never empty

          temp = Wx::Font.new
          assert( temp.set_native_font_info(nid) )
          assert( temp.ok? )

          puts("Testing font ##{n}") unless is_ci_build?
          puts("original font user description: #{test.get_native_font_info_user_desc}") unless is_ci_build?
          puts("the other font description: #{temp.get_native_font_info_user_desc}") unless is_ci_build?

          assert_equal( temp, test )
      end

      # test that clearly invalid font info strings do not work
      font = Wx::Font.new
      assert( !font.set_native_font_info('') )

      # pango_font_description_from_string() used by Wx::Font in wxGTK and wxX11
      # never returns an error at all so this assertion fails there -- and as it
      # doesn't seem to be possible to do anything about it maybe we should
      # change wxMSW and other ports to also accept any strings?
      unless %w[WXGTK WXX11 WXQT].include?(Wx::PLATFORM)
      assert( !font.set_native_font_info("bloordyblop") )
      end

      font.set_underlined(true)
      font.set_strikethrough(true)
      assert(font == Wx::Font.new(font))
      assert(font == Wx::Font.new(font.get_native_font_info_desc))
      assert(Wx::Font.new(font.get_native_font_info_desc).get_underlined)
      assert(Wx::Font.new(font.get_native_font_info_desc).get_strikethrough)
      font.set_underlined(false)
      assert(font == Wx::Font.new(font))
      assert(font == Wx::Font.new(font.get_native_font_info_desc))
      assert(!Wx::Font.new(font.get_native_font_info_desc).get_underlined)
      font.set_underlined(true)
      font.set_strikethrough(false)
      assert(font == Wx::Font.new(font))
      assert(font == Wx::Font.new(font.get_native_font_info_desc))
      assert(Wx::Font.new(font.get_native_font_info_desc).get_underlined)
      assert(!Wx::Font.new(font.get_native_font_info_desc).get_strikethrough)
    end
  end

  def test_find_or_create
    [10.5, Wx::Size.new(0, 32)].each do |pt_sz|
      info = Wx::FontInfo.new(pt_sz)

      font1 = Wx::Font.find_or_create_font(info)
      assert(font1)
      assert(font1.ok?)

      puts "Font from font list: #{font1.get_native_font_info_user_desc}" unless is_ci_build?

      if pt_sz.is_a?(Wx::Size)
        assert(pt_sz.y >= font1.get_pixel_size.y)
      else
        assert_equal(pt_sz, font1.get_fractional_point_size) unless is_ci_build?
      end

      # font 2 should be font1 from the font list "cache"
      font2 = Wx::TheFontList.find_or_create_font(info)
      assert_equal(font1, font2)
    end
  end

end
