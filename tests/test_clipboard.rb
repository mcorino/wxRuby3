
require_relative './lib/wxapp_runner'

class TestTextData < Test::Unit::TestCase
  # Using an in-built class
  def test_text_data
    td = Wx::TextDataObject.new('WXRUBY')
    assert_equal("WXRUBY", td.text)

    Wx::Clipboard.open do | clip |
      assert clip.opened?
      clip.clear
      assert !clip.supported?(Wx::DF_BITMAP)
      clip.place td
      assert clip.supported?(Wx::DF_TEXT)
      assert !clip.supported?(Wx::DF_BITMAP)
    end

    td_2 = Wx::TextDataObject.new
    Wx::Clipboard.open do | clip |
      clip.fetch td_2
    end
    assert_equal("WXRUBY", td_2.text)

    Wx::Clipboard.open do | clip |
      clip.clear
    end

    td_3 = Wx::TextDataObject.new
    Wx::Clipboard.open do | clip |
      clip.fetch td_3
    end
    assert_equal("", td_3.get_data_here)
  end
end

class TestBitmapData < Test::Unit::TestCase
  def test_bitmap_data
    bmp = Wx::Bitmap.new(File.join(__dir__, '../samples/minimal/mondrian.png'))
    height = bmp.height
    width  = bmp.width
    assert bmp.ok?, "Bitmap is OK"

    d_obj = Wx::BitmapDataObject.new(bmp)
    d_obj.bitmap = bmp

    assert d_obj.bitmap.ok?, "DataObject's bitmap is OK"
    Wx::Clipboard.open do | clip |
      clip.clear
      clip.place d_obj
      assert clip.supported? Wx::DF_BITMAP
    end

    d_obj_2 = Wx::BitmapDataObject.new
    Wx::Clipboard.open do | clip |
      assert clip.supported? Wx::DF_BITMAP
      clip.fetch d_obj_2
    end

    out_bmp = d_obj_2.bitmap
    assert out_bmp.ok?, "Fetched out bitmap"
    assert_equal height, out_bmp.height
    assert_equal width, out_bmp.width
  end
end

class TestDataObjectComposite < Test::Unit::TestCase
  MY_INT_ARRAY_FORMAT = Wx::DataFormat.new('application/int_array_format')

  class MySimpleIntArrayObject < Wx::DataObjectSimpleBase
    def initialize(arr = nil)
      super(MY_INT_ARRAY_FORMAT)
      self.array = arr
    end

    def array
      @arr
    end

    def array=(arr)
      @arr = (arr || []).collect { |e| e.to_i }
    end

    # The default will do in this case but otherwise something like this:
    # def _get_data_size
    #   @arr ? @arr.pack('i*').bytesize : 0
    # end

    def _get_data
      @arr ? @arr.pack('i*') : nil
    end

    def _set_data(data)
      @arr = data ? data.unpack('i*') : []
      true
    end
  end

  def test_data_object_composite
    d_obj = Wx::DataObjectComposite.new
    d_txt = Wx::TextDataObject.new
    d_obj.add( d_txt )
    bmp = Wx::Bitmap.new(File.join(__dir__, '../samples/minimal/mondrian.png'))

    d_obj.add( Wx::BitmapDataObject.new )
    if Wx::PLATFORM == 'WXMSW'
      assert_equal( 1, d_txt.get_format_count(Wx::DataObject::Direction::Get) )
      assert_equal( 2, d_obj.get_format_count(Wx::DataObject::Direction::Get) )
    else
      assert_equal( 2, d_txt.get_format_count(Wx::DataObject::Direction::Get) )
      assert_equal( 3, d_obj.get_format_count(Wx::DataObject::Direction::Get) )
    end
    d_txt = nil

    GC.start

    d_bmp = Wx::BitmapDataObject.new(bmp)
    Wx::Clipboard.open do | clip |
      clip.clear
      clip.place d_bmp
    end

    GC.start

    Wx::Clipboard.open do | clip |
      assert !clip.supported?( Wx::DF_TEXT )
      assert clip.supported?( Wx::DF_BITMAP )

      clip.fetch d_obj
    end

    GC.start

    if Wx::PLATFORM == 'WXMSW'
      assert_equal d_obj.received_format.get_type, Wx::DF_DIB.get_type
      d_bmp = d_obj.get_object(Wx::DF_DIB)
    else
      assert_equal d_obj.received_format.get_type, Wx::DF_BITMAP.get_type
      d_bmp = d_obj.get_object(Wx::DF_BITMAP)
    end
    bmp_out = d_bmp.bitmap
    assert bmp_out.ok?, "Read out bitmap OK"
    assert_equal bmp.width, bmp_out.width
    assert_equal bmp.height, bmp_out.height

    d_txt = Wx::TextDataObject.new('THE TEXT')
    Wx::Clipboard.open do | clip |
      clip.clear
      clip.place d_txt
    end

    GC.start

    d_obj_2 = Wx::DataObjectComposite.new
    d_txt = Wx::TextDataObject.new
    d_obj_2.add d_txt
    d_obj_2.add Wx::BitmapDataObject.new

    Wx::Clipboard.open do | clip |
      assert clip.supported?( Wx::DF_TEXT )
      assert clip.supported?( Wx::DF_UNICODETEXT )
      assert !clip.supported?( Wx::DF_BITMAP )

      clip.fetch d_obj_2
    end

    GC.start

    assert_equal d_obj_2.received_format.get_type, d_txt.get_preferred_format(Wx::DataObject::Direction::Set).get_type
    if Wx::PLATFORM == 'WXMSW'
      d_txt = d_obj_2.get_object(Wx::DF_UNICODETEXT)
    else
      d_txt = d_obj_2.get_object(Wx::DF_TEXT)
    end
    assert_equal d_txt.text, 'THE TEXT'

    GC.start

    d_obj_2 = Wx::DataObjectComposite.new
    d_obj_2.add Wx::TextDataObject.new
    d_obj_2.add MySimpleIntArrayObject.new([1,2,3,4,5])
    assert_equal( 2, d_obj_2.get_format_count(Wx::DataObject::Direction::Get) )

    Wx::Clipboard.open do | clip |
      clip.clear
      clip.place d_obj_2
    end

    GC.start

    d_iarr = MySimpleIntArrayObject.new
    Wx::Clipboard.open do | clip |
      assert clip.supported?(MY_INT_ARRAY_FORMAT)
      clip.fetch d_iarr
    end

    assert_equal([1,2,3,4,5], d_iarr.array)
  end
end

class TestDataObject < Test::Unit::TestCase
  MY_CUSTOM_FORMAT = Wx::DataFormat.new('text/custom_format')
  MY_CUSTOM_TEXT = Wx::DataFormat.new('text/custom_text')

  class MySimpleDataObject < Wx::DataObjectSimpleBase
    def initialize
      super(MY_CUSTOM_TEXT)
      @data = ''
    end

    def _get_data_size
      @data.bytesize
    end

    def _get_data
      @data
    end

    def _set_data(data)
      @data = data ? data : ''
      true
    end
  end

  class MyBasicDataObject < Wx::DataObject
    attr_reader :my_data

    def initialize(the_data = '')
      super()
      # expect data in the preferred format initially
      @my_data = the_data
      @format = MY_CUSTOM_FORMAT.get_type
    end

    def get_as_text
      if @my_data.nil? || @my_data.empty? || @format == Wx::DataFormatId::DF_TEXT
        @my_data
      else
        @my_data.gsub(/<[^>]+>/, '') # not f(ul|oo)lproof, I know
      end
    end

    def get_formatted
      if @my_data.nil? || @my_data.empty? || @format != Wx::DataFormatId::DF_TEXT
        @my_data
      else
        "<b>#{@my_data}</b>"
      end
    end
    private :get_formatted

    # List all the formats that we support. By default, the first is
    # treated as the 'preferred' format; this can be overridden by
    # providing a get_preferred format.
    def get_all_formats(direction)
      [ MY_CUSTOM_FORMAT, Wx::DF_TEXT  ]
    end

    # Do setting the data
    def set_data(format, the_data)
      case format.get_type
      when MY_CUSTOM_FORMAT.get_type, Wx::DataFormatId::DF_TEXT
        @my_data = the_data
        @format = format.get_type
        true
      else
        false
      end
    end

    def get_data_size(format)
      case format.get_type
      when Wx::DataFormatId::DF_TEXT
        get_as_text.to_s.bytesize
      when MY_CUSTOM_FORMAT.get_type
        get_formatted.to_s.bytesize
      else
        0
      end
    end

    # Do getting the data
    def get_data_here(format)
      case format.get_type
      when Wx::DataFormatId::DF_TEXT
        get_as_text
      when MY_CUSTOM_FORMAT.get_type
        get_formatted
      else
        nil
      end
    end
  end

  def test_simple_data_obj
    d_obj = MySimpleDataObject.new
    d_obj.set_data('Simple Data')
    assert_equal( 1, d_obj.get_format_count )
    assert_equal('Simple Data', d_obj.get_data_here )

    Wx::Clipboard.open do | clip |
      clip.place d_obj
    end

    d_obj2 = MySimpleDataObject.new
    Wx::Clipboard.open do | clip |
      assert clip.supported?( d_obj2.get_format )
      clip.fetch d_obj2
    end
    assert_equal('Simple Data', d_obj2.get_data_here )
  end

  def test_data_obj
    d_obj = MyBasicDataObject.new
    d_obj.set_data(Wx::DF_TEXT, 'HELLO')
    assert_equal( 2, d_obj.get_format_count(Wx::DataObject::Direction::Get) )
    assert_equal('HELLO', d_obj.get_data_here(Wx::DF_TEXT) )
    assert_equal('<b>HELLO</b>', d_obj.get_data_here(MY_CUSTOM_FORMAT) )

    Wx::Clipboard.open do | clip |
      clip.place d_obj
    end

    d_obj_2 = MyBasicDataObject.new
    Wx::Clipboard.open do | clip |
      assert clip.supported?( Wx::DF_TEXT )
      assert clip.supported?( MY_CUSTOM_FORMAT )
      clip.fetch d_obj_2
    end
    assert_equal('<b>HELLO</b>', d_obj_2.get_data_here(MY_CUSTOM_FORMAT) )

    assert_equal('HELLO', d_obj_2.get_data_here(Wx::DF_TEXT) )
  end
end
