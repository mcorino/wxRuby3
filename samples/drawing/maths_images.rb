#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2009 wxRuby development team
# Adapted for wxRuby3
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../sampler' if $0 == __FILE__
require 'wx'
include Wx
include Math

# This sample was originally written by Alex Fenton as an answer to Ruby
# Quiz #191, which challenged entrants to create an application which
# could draw images based on mathematical functions:
#
# http://rubyquiz.strd6.com/quizzes/191/
#
# To use the application, enter functions which take input values of x
# and y from 0 to 1, and return intensities of red, green and blue. If a
# bad function is entered, a cross is displayed; hover over this to get
# a hint on the problem.
#
# The sample demonstrates some uses of the Wx::Image class, a
# platform-independent representation of an image which can be
# manipulated (for example, resizing) and written to files in various
# formats. It also shows how an image's rgb data can be written directly, by
# using Array#pack.

# A canvas that draws and displays a mathematically generated image
class MathsDrawing < Window
  # The functions which return the colour components at each pixel
  attr_writer :red, :green, :blue
  # The time taken to render, whether re-rendering is needed, and the
  # source image
  attr_reader :render_time, :done, :img
  
  def initialize(parent)
    super(parent)
    # Create a dummy image 
    @default_image = Image.new(1, 1)
    @default_image.rgb_data = [255, 255, 255].pack('CCC')
    @img = @default_image

    @red   = lambda { | x, y | 1 }
    @green = lambda { | x, y | 1 }
    @blue  = lambda { | x, y | 1 }

    @done = true

    evt_size :on_size
    evt_paint :on_paint
    evt_idle :on_idle
  end

  # Paint the image on the screen. The actual image rendering is done in
  # idle time, so that the GUI is responsive whilst redrawing - eg, when
  # resized. Painting is done by quickly rescaling the cached image.
  def on_paint
    paint do | dc |
      draw_img = @img.scale(client_size.width, client_size.height)
      dc.draw_bitmap(draw_img.convert_to_bitmap, 0, 0, true)
    end
  end

  # Regenerate the image if needed, then do a refresh
  def on_idle
    if not @done
      @img = make_image
      refresh
    end
    @done = true
  end

  # Note to regenerate the image if the canvas has been resized
  def on_size(event)
    @done = false
    event.skip
  end

  # Call this to force a re-render - eg if the functions have changed
  def redraw
    @done = false
  end

  # Actually make the image
  def make_image
    size_x, size_y = client_size.width, client_size.height
    if size_x < 1 or size_y < 1
      return @default_image
    end

    start_time = Time.now
    # The string holding raw rgb data
    data = ''
    x_factor = size_x.to_f
    y_factor = size_y.to_f

    # Input values from the range 0 to 1, with origin in the bottom left
    (size_y - 1).downto(0) do | y |
      the_y = y.to_f / y_factor
      0.upto(size_x - 1) do | x |
        the_x = x.to_f / x_factor
        red   = @red.call(the_x, the_y) * 255
        green = @green.call(the_x, the_y) * 255
        blue  = @blue.call(the_x, the_y) * 255
        data << [red, green, blue].pack("CCC")
      end
    end
    img = Image.new(size_x, size_y)
    img.rgb_data = data
    @render_time = Time.now - start_time
    img
  end
end

# A helper dialog for saving the image to a file
class SaveImageDialog < FileDialog
  # The image file formats on offer
  TYPES = [ [ "PNG file (*.png)|*.png", Wx::BITMAP_TYPE_PNG ],
            [ "TIF file (*.tif)|*.tif", Wx::BITMAP_TYPE_TIF ],
            [ "BMP file (*.bmp)|*.bmp", Wx::BITMAP_TYPE_BMP ] ]
  
  WILDCARD = TYPES.map { | type | type.first }.join("|")
  
  def initialize(parent)
    super(parent, :wildcard => WILDCARD,
                  :message => 'Save Image',
                  :style => FD_SAVE|FD_OVERWRITE_PROMPT)
  end

  # Returns the Wx identifier for the selected image type. 
  def image_type
    TYPES[filter_index].last
  end
end

# A Panel for displaying the image and controls to manipulate it
class MathsPanel < Panel
  # Set functions to some nice initial values
  RED_INITIAL   = "cos(x)"
  GREEN_INITIAL = "cos(y ** x)"
  BLUE_INITIAL  = "(x ** 4) + ( y ** 3 ) - (4.5 * x ** 2 ) + ( y * 2)"

  # Symbols to show correct and incorrect functions
  TICK  = "\xE2\x9C\x94"
  CROSS = "\xE2\x9C\x98"

  attr_reader :drawing

  def initialize(parent)
    super(parent)
    self.sizer = VBoxSizer.new
    # The canvas
    @drawing = MathsDrawing.new(self) 
    sizer.add @drawing, 1, GROW

    sizer.add Wx::StaticLine.new(self)
    
    # The text controls for entering functions
    grid_sz = FlexGridSizer.new(3, 8, 8)
    grid_sz.add_growable_col(1, 1)

    grid_sz.add StaticText.new(self, :label => "Red")
    @red_tx = TextCtrl.new(self, :value => RED_INITIAL)
    grid_sz.add @red_tx, 0, GROW
    @red_err = StaticText.new(self, :label => TICK)
    grid_sz.add @red_err, 0, ALIGN_CENTRE

    grid_sz.add StaticText.new(self, :label => "Green")
    @green_tx = TextCtrl.new(self, :value => GREEN_INITIAL)
    grid_sz.add @green_tx, 0, GROW
    @green_err = StaticText.new(self, :label => TICK)
    grid_sz.add @green_err, 0, ALIGN_CENTRE

    grid_sz.add StaticText.new(self, :label => "Blue")
    @blue_tx = TextCtrl.new(self, :value => BLUE_INITIAL)
    grid_sz.add @blue_tx, 0, GROW
    @blue_err = StaticText.new(self, :label => TICK)
    grid_sz.add @blue_err, 0, ALIGN_CENTRE

    # Buttons to save and render
    grid_sz.add 0, 0
    butt_sz = HBoxSizer.new
    render_bt = Button.new(self, :label => "Render")
    butt_sz.add render_bt, 0, Wx::RIGHT, 8
    evt_button render_bt, :on_render

    save_bt = Button.new(self, :label => "Save Image")
    butt_sz.add save_bt, 0, Wx::RIGHT, 8
    evt_button save_bt, :on_save

    # Disable the buttons whilst redrawing
    evt_update_ui(render_bt) { | evt | evt.enable(@drawing.done) }
    evt_update_ui(save_bt) { | evt | evt.enable(@drawing.done) }
    grid_sz.add butt_sz

    # Add the controls sizer to the whole thing
    sizer.add grid_sz, 0, GROW|ALL, 10

    on_render
  end
  
  # Update the functions that generate the image, then re-render it
  def on_render
    @drawing.red   = make_a_function(@red_tx.value, @red_err)
    @drawing.green = make_a_function(@green_tx.value, @green_err)
    @drawing.blue  = make_a_function(@blue_tx.value, @blue_err)
    @drawing.redraw
  end

  # Display a dialog to save the image to a file
  def on_save
    SaveImageDialog(parent) do |dlg|
      if dlg.show_modal == ID_OK
        @drawing.img.save_file(dlg.path, dlg.image_type)
      end
    end
  end

  # A function which doesn't do anything
  NULL_FUNC = lambda { | x, y | 1 }

  # Takes a string source +source+, returns a lambda. If the string
  # source isn't valid, flag this in the GUI static text +error_outlet+
  def make_a_function(source, error_outlet)
    return NULL_FUNC if source.empty?
    func = nil
    begin
      # Create the function and test it, to check for wrong names
      func = eval "lambda { | x, y | #{source} }"
      func.call(0, 0)
    rescue Exception => e
      error_outlet.label = CROSS
      error_outlet.tool_tip = e.class.name + ":\n" +
                              e.message.sub(/^\(eval\):\d+: /, '')        
      return NULL_FUNC
    end
    
    # Things are good, note this and return the function
    error_outlet.label = TICK
    error_outlet.tool_tip = ''
    func
  end
end

class MathsFrame < Frame
  def initialize
    super(nil, :title => 'Maths drawing', 
               :size => [400, 500], 
               :pos => [50, 50])
    sb = create_status_bar(1)
    evt_update_ui sb, :on_update_status
    @panel = MathsPanel.new(self)
  end

  def on_update_status
    if @panel.drawing.done
      pixels = @panel.drawing.client_size
      msg = "[#{pixels.width} x #{pixels.height}] drawing completed in " +
            "#{@panel.drawing.render_time}s"
      status_bar.status_text = msg
    end
  end
end

module MathImagesSample

  include WxRuby::Sample

  def self.describe
    Description.new(
      file: __FILE__,
      summary: 'wxRuby math images example.',
      description: <<~__TXT
        wxRuby example demonstrating drawing using math functions.
        This sample was originally written by Alex Fenton as an answer to Ruby
        Quiz #191, which challenged entrants to create an application which
        could draw images based on mathematical functions:
        
        http://rubyquiz.strd6.com/quizzes/191/
        
        To use the application, enter functions which take input values of x
        and y from 0 to 1, and return intensities of red, green and blue. If a
        bad function is entered, a cross is displayed; hover over this to get
        a hint on the problem.
        
        The sample demonstrates some uses of the Wx::Image class, a
        platform-independent representation of an image which can be
        manipulated (for example, resizing) and written to files in various
        formats. It also shows how an image's rgb data can be written directly, by
        using Array#pack.
        __TXT
    )
  end

  def self.run
    execute(__FILE__)
  end

  if $0 == __FILE__
    Wx::App.run do
      frame = MathsFrame.new
      frame.show
    end
  end

end
