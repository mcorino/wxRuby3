# Copyright (c) 2023 M.J.N. Corino = self.next_id The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) Robert Roebling

require 'wx'

module Drawing

  DRAWING_DC_SUPPORTS_ALPHA = %w[WXGTK WXOSX].include?(Wx::PLATFORM)

  module ID
    include Wx::IDHelper

    # menu items
    File_Quit = Wx::ID_EXIT
    File_About = Wx::ID_ABOUT

    MenuShow_First = self.next_id(Wx::ID_HIGHEST)
    File_ShowDefault = MenuShow_First
    File_ShowText = self.next_id
    File_ShowLines = self.next_id
    File_ShowBrushes = self.next_id
    File_ShowPolygons = self.next_id
    File_ShowMask = self.next_id
    File_ShowMaskStretch = self.next_id
    File_ShowOps = self.next_id
    File_ShowRegions = self.next_id
    File_ShowCircles = self.next_id
    File_ShowSplines = self.next_id
    File_ShowAlpha = self.next_id
    File_ShowGraphics = self.next_id
    File_ShowSystemColours = self.next_id
    File_ShowDatabaseColours = self.next_id
    File_ShowGradients = self.next_id
    MenuShow_Last = File_ShowGradients

    if Wx.has_feature?(:USE_GRAPHICS_CONTEXT)
      File_DC = self.next_id
      File_GC_Default = self.next_id
      if Wx.has_feature?(:USE_CAIRO)
        File_GC_Cairo = self.next_id
      end # USE_CAIRO
      if Wx::PLATFORM == 'WXMSW'
        if Wx.has_feature?(:USE_GRAPHICS_GDIPLUS)
          File_GC_GDIPlus = self.next_id
        end
        if Wx.has_feature?(:USE_GRAPHICS_DIRECT2D)
          File_GC_Direct2D = self.next_id
        end
      end # WXMSW
    end # USE_GRAPHICS_CONTEXT
    File_BBox = self.next_id
    File_Clip = self.next_id
    File_Buffer = self.next_id
    if Wx.has_feature?(:USE_GRAPHICS_CONTEXT)
      File_AntiAliasing = self.next_id
    end
    File_Copy = self.next_id
    File_Save = self.next_id

    MenuOption_First = self.next_id

    MapMode_Text = MenuOption_First
    MapMode_Lometric = self.next_id
    MapMode_Twips = self.next_id
    MapMode_Points = self.next_id
    MapMode_Metric = self.next_id

    UserScale_StretchHoriz = self.next_id
    UserScale_ShrinkHoriz = self.next_id
    UserScale_StretchVertic = self.next_id
    UserScale_ShrinkVertic = self.next_id
    UserScale_Restore = self.next_id

    AxisMirror_Horiz = self.next_id
    AxisMirror_Vertic = self.next_id

    LogicalOrigin_MoveDown = self.next_id
    LogicalOrigin_MoveUp = self.next_id
    LogicalOrigin_MoveLeft = self.next_id
    LogicalOrigin_MoveRight = self.next_id
    LogicalOrigin_Set = self.next_id
    LogicalOrigin_Restore = self.next_id

    TransformMatrix_Set = self.next_id
    TransformMatrix_Reset = self.next_id

    Colour_TextForeground = self.next_id
    Colour_TextBackground = self.next_id
    Colour_Background = self.next_id
    Colour_BackgroundMode = self.next_id
    Colour_TextureBackground = self.next_id

    MenuOption_Last = Colour_TextureBackground
  end

  class MyCanvas < Wx::ScrolledWindow

    class DrawMode < Wx::Enum
      Draw_Normal = self.new(0)
      Draw_Stretch = self.new(1)
    end

    def initialize(parent)
      super(parent, Wx::ID_ANY, style: Wx::HSCROLL | Wx::VSCROLL)

      @owner = parent
      @show = ID::File_ShowDefault
      @smile_bmp = Wx.Bitmap(:smile)
      @std_icon = Wx::ArtProvider.get_icon(Wx::ART_INFORMATION)
      @clip = false
      @rubberBand = false
      if Wx.has_feature?(:USE_GRAPHICS_CONTEXT)
        @renderer = nil
        @useAntiAliasing = true
      end
      @useBuffer = false
      @showBBox = false
      @sizeDIP = Wx::Size.new
      @currentpoint = Wx::Point.new
      @anchorpoint = Wx::Point.new
      @overlay = Wx::Overlay.new
      
      evt_paint :on_paint
      evt_motion :on_mouse_move
      evt_left_down :on_mouse_down
      evt_left_up :on_mouse_up
    end

    def on_paint(_event)
      if @useBuffer
        Wx::BufferedPaintDC.draw_on(self) { |bpdc| draw(bpdc) }
      else
        self.paint { |pdc| draw(pdc) }
      end
    end

    def on_mouse_move(event)
      if Wx.has_feature?(:USE_STATUSBAR)
        Wx::ClientDC.draw_on(self) do |dc|
          prepare_dc(dc)
          @owner.prepare_dc(dc)
  
          pos = dc.device_to_logical(event.position)
          dipPos = dc.to_dip(pos)
          str = "Mouse position: #{pos.x},#{pos.y}"
          str << " DIP position: #{dipPos.x},#{dipPos.y}" if  pos != dipPos
          @owner.set_status_text(str)
        end
  
        if @rubberBand
          @currentpoint = calc_unscrolled_position(event.position)
          newrect = Wx::Rect.new(@anchorpoint, @currentpoint)

          Wx::ClientDC.draw_on(self) do |dc|
            prepare_dc(dc)

            Wx::DCOverlay.draw_on(@overlay, dc) { |overlaydc| overlaydc.clear }

            if Wx::PLATFORM == 'WXMAC'
              dc.set_pen(Wx::GREY_PEN )
              dc.set_brush(Wx::Brush.new(Wx::Colour.new(192,192,192,64)))
            else
              dc.set_pen(Wx::Pen.new(Wx::LIGHT_GREY, 2))
              dc.set_brush(Wx::TRANSPARENT_BRUSH)
            end
            dc.draw_rectangle(newrect)
          end
        end
      end # USE_STATUSBAR
    end

    def on_mouse_down(event)
      @anchorpoint = calc_unscrolled_position(event.position)
      @currentpoint = @anchorpoint
      @rubberBand = true
      capture_mouse
    end

    def on_mouse_up(event)
      if @rubberBand
        release_mouse
        Wx::ClientDC.draw_on(self) do |dc|
          prepare_dc(dc)
          Wx::DCOverlay.draw_on(@overlay, dc) { |overlaydc| overlaydc.clear }
        end
        @overlay.reset
        @rubberBand = false

        endpoint = calc_unscrolled_position(event.position)

        # Don't pop up the message box if nothing was actually selected.
        if endpoint != @anchorpoint
          Wx.log_message('Selected rectangle from (%d, %d) to (%d, %d)',
                         @anchorpoint.x, @anchorpoint.y,
                         endpoint.x, endpoint.y)
        end
      end
    end

    def to_show(show)
      @show = show
      refresh
    end

    def get_page
      @show
    end

    # set or remove the clipping region
    def clip(clip)
      @clip = clip
      refresh
    end

    if Wx.has_feature?(:USE_GRAPHICS_CONTEXT)

      def has_renderer
        !!@renderer
      end

      def use_graphic_renderer(renderer)
        @renderer = renderer
        if renderer
          major, minor, micro = renderer.get_version
          str = 'Graphics renderer: %s %i.%i.%i' % [renderer.get_name, major, minor, micro]
          @owner.set_status_text(str, 1)
        else
          @owner.set_status_text('', 1)
        end
    
        refresh
      end

      def is_default_renderer
        return false unless @renderer
        @renderer == Wx::GraphicsRenderer.get_default_renderer
      end

      def get_renderer
        @renderer
      end

      def enable_anti_aliasing(use)
        @use_anti_aliasing = use
        refresh
      end

    end # USE_GRAPHICS_CONTEXT

    def use_buffer(use)
      @useBuffer = use
      refresh
    end

    def show_bounding_box(show)
      @showBBox = show
      refresh
    end

    def get_dip_drawing_size
      @sizeDIP
    end

    if Wx.has_feature?(:USE_GRAPHICS_CONTEXT)
      def draw(pdc)
        if @renderer
          context = @renderer.create_context(pdc)

          context.set_antialias_mode(@useAntiAliasing ? Wx::ANTIALIAS_DEFAULT : Wx::ANTIALIAS_NONE)

          Wx::GCDC.draw_on do |gdc|
            gdc.set_background(Wx::Brush.new(get_background_colour))
            gdc.set_graphics_context(context)
            # Adjust scrolled contents for screen drawing operations only.
            if pdc.is_a?(Wx::BufferedPaintDC) || pdc.is_a?(Wx::PaintDC)
              prepare_dc(gdc)
            end

            @owner.prepare_dc(gdc)

            do_draw(gdc)
          end
        else
          # Adjust scrolled contents for screen drawing operations only.
          if pdc.is_a?(Wx::BufferedPaintDC) || pdc.is_a?(Wx::PaintDC)
            prepare_dc(pdc)
          end

          @owner.prepare_dc(pdc)

          do_draw(pdc)
        end
      end
    else
      def draw(pdc)
        # Adjust scrolled contents for screen drawing operations only.
        if pdc.is_a?(Wx::BufferedPaintDC) || pdc.is_a?(Wx::PaintDC)
          prepare_dc(pdc)
        end

        @owner.prepare_dc(pdc)

        do_draw(pdc)
      end
    end

    protected

    def do_draw(dc)
      dc.set_background_mode(@owner.backgroundMode)
      dc.set_background(@owner.backgroundBrush) if @owner.backgroundBrush.ok?
      dc.set_text_foreground(@owner.colourForeground) if @owner.colourForeground.ok?
      dc.set_text_background(@owner.colourBackground) if @owner.colourBackground.ok?
  
      if @owner.textureBackground
        unless @owner.backgroundBrush.ok?
          dc.set_background(Wx::Brush.new(Wx::Colour.new(0, 128, 0)))
        end
      end
  
      if @clip
        dc.set_clipping_region([dc.from_dip(100), dc.from_dip(100)],
                               [dc.from_dip(100), dc.from_dip(100)])
      end
  
      dc.clear
  
      if @owner.textureBackground
        dc.set_pen(Wx::MEDIUM_GREY_PEN)
        200.times { |i| dc.draw_line(0, dc.from_dip(i*10), dc.from_dip(i*10), 0) }
      end

      case @show
      when ID::File_ShowDefault
        draw_default(dc)

      when ID::File_ShowCircles
        draw_circles(dc)

      when ID::File_ShowSplines
        draw_splines(dc)

      when ID::File_ShowRegions
        draw_regions(dc)

      when ID::File_ShowText
        draw_text(dc)

      when ID::File_ShowLines
        draw_test_lines(0, 100, 0, dc)
        draw_test_lines(0, 320, 1, dc)
        draw_test_lines(0, 540, 2, dc)
        draw_test_lines(0, 760, 6, dc)
        draw_cross_hair(0, 0, 400, 90, dc)

      when ID::File_ShowBrushes
        draw_test_brushes(dc)

      when ID::File_ShowPolygons
        draw_test_poly(dc)

      when ID::File_ShowMask
        draw_images(dc, DrawMode::Draw_Normal)

      when ID::File_ShowMaskStretch
        draw_images(dc, DrawMode::Draw_Stretch)

      when ID::File_ShowOps
        draw_with_logical_ops(dc)

      when ID::File_ShowAlpha
        draw_alpha(dc)

      when ID::File_ShowGraphics
        draw_graphics(dc.get_graphics_context) if dc.is_a?(Wx::GCDC)

      when ID::File_ShowGradients
        draw_gradients(dc)

      when ID::File_ShowSystemColours
        draw_system_colours(dc)

      end
  
      # For drawing with raw Wx::GraphicsContext
      # there is no bounding box to obtain.
      if @showBBox && !(Wx.has_feature?(:USE_GRAPHICS_CONTEXT) && @show == ID::File_ShowGraphics)
        dc.set_pen(Wx::Pen.new(Wx::Colour.new(0, 128, 0), 1, Wx::PENSTYLE_DOT))
        dc.set_brush(Wx::TRANSPARENT_BRUSH)
        dc.draw_rectangle(dc.min_x, dc.min_y, dc.max_x-dc.min_x+1, dc.max_y-dc.min_y+1)
      end
  
      # Adjust drawing area dimensions only if screen drawing is invoked.
      if dc.is_a?(Wx::BufferedPaintDC) || dc.is_a?(Wx::PaintDC)
          x0, y0 = dc.get_device_origin
          @sizeDIP.x = dc.to_dip(dc.logical_to_device_x(dc.max_x) - x0) + 1
          @sizeDIP.y = dc.to_dip(dc.logical_to_device_y(dc.max_y) - y0) + 1
      end
    end

    def draw_test_lines(x, y, width, dc)
      dc.set_pen(Wx::Pen.new( Wx::BLACK, width))
      dc.set_brush(Wx::WHITE_BRUSH)
      dc.draw_text("Testing lines of width #{width}", dc.from_dip(x + 10), dc.from_dip(y - 10))
      dc.draw_rectangle(dc.from_dip(x + 10), dc.from_dip(y + 10), dc.from_dip(100), dc.from_dip(190))
  
      dc.draw_text("Solid/dot/short dash/long dash/dot dash", dc.from_dip(x + 150), dc.from_dip(y + 10))
      dc.set_pen( Wx::Pen.new( Wx::BLACK, width ) )
      dc.draw_line(dc.from_dip(x + 20), dc.from_dip(y + 20), dc.from_dip(100), dc.from_dip(y + 20))
      dc.set_pen( Wx::Pen.new( Wx::BLACK, width, Wx::PENSTYLE_DOT) )
      dc.draw_line(dc.from_dip(x + 20), dc.from_dip(y + 30), dc.from_dip(100), dc.from_dip(y + 30))
      dc.set_pen( Wx::Pen.new( Wx::BLACK, width, Wx::PENSTYLE_SHORT_DASH) )
      dc.draw_line(dc.from_dip(x + 20), dc.from_dip(y + 40), dc.from_dip(100), dc.from_dip(y + 40))
      dc.set_pen( Wx::Pen.new( Wx::BLACK, width, Wx::PENSTYLE_LONG_DASH) )
      dc.draw_line(dc.from_dip(x + 20), dc.from_dip(y + 50), dc.from_dip(100), dc.from_dip(y + 50))
      dc.set_pen( Wx::Pen.new( Wx::BLACK, width, Wx::PENSTYLE_DOT_DASH) )
      dc.draw_line(dc.from_dip(x + 20), dc.from_dip(y + 60), dc.from_dip(100), dc.from_dip(y + 60))
  
      dc.draw_text("Hatches", dc.from_dip(x + 150), dc.from_dip(y + 70))
      dc.set_pen( Wx::Pen.new( Wx::BLACK, width, Wx::PENSTYLE_BDIAGONAL_HATCH) )
      dc.draw_line(dc.from_dip(x + 20), dc.from_dip(y + 70), dc.from_dip(100), dc.from_dip(y + 70))
      dc.set_pen( Wx::Pen.new( Wx::BLACK, width, Wx::PENSTYLE_CROSSDIAG_HATCH) )
      dc.draw_line(dc.from_dip(x + 20), dc.from_dip(y + 80), dc.from_dip(100), dc.from_dip(y + 80))
      dc.set_pen( Wx::Pen.new( Wx::BLACK, width, Wx::PENSTYLE_FDIAGONAL_HATCH) )
      dc.draw_line(dc.from_dip(x + 20), dc.from_dip(y + 90), dc.from_dip(100), dc.from_dip(y + 90))
      dc.set_pen( Wx::Pen.new( Wx::BLACK, width, Wx::PENSTYLE_CROSS_HATCH) )
      dc.draw_line(dc.from_dip(x + 20), dc.from_dip(y + 100), dc.from_dip(100), dc.from_dip(y + 100))
      dc.set_pen( Wx::Pen.new( Wx::BLACK, width, Wx::PENSTYLE_HORIZONTAL_HATCH) )
      dc.draw_line(dc.from_dip(x + 20), dc.from_dip(y + 110), dc.from_dip(100), dc.from_dip(y + 110))
      dc.set_pen( Wx::Pen.new( Wx::BLACK, width, Wx::PENSTYLE_VERTICAL_HATCH) )
      dc.draw_line(dc.from_dip(x + 20), dc.from_dip(y + 120), dc.from_dip(100), dc.from_dip(y + 120))
  
      dc.draw_text("User dash", dc.from_dip(x + 150), dc.from_dip(y + 140))
      ud = Wx::Pen.new( Wx::BLACK, width, Wx::PENSTYLE_USER_DASH )
      dash1 = [
        8,  # Long dash  <---------+
        2,  # Short gap            |
        3,  # Short dash           |
        2,  # Short gap            |
        3,  # Short dash           |
        2]  # Short gap and repeat +
      ud.set_dashes(dash1)
      dc.set_pen( ud )
      dc.draw_line(dc.from_dip(x + 20), dc.from_dip(y + 140), dc.from_dip(100), dc.from_dip(y + 140))
      dash1[0] = 5  # Make first dash shorter
      ud.set_dashes( dash1 )
      dc.set_pen( ud )
      dc.draw_line(dc.from_dip(x + 20), dc.from_dip(y + 150), dc.from_dip(100), dc.from_dip(y + 150))
      dash1[2] = 5  # Make second dash longer
      ud.set_dashes( dash1 )
      dc.set_pen( ud )
      dc.draw_line(dc.from_dip(x + 20), dc.from_dip(y + 160), dc.from_dip(100), dc.from_dip(y + 160))
      dash1[4] = 5  # Make third dash longer
      ud.set_dashes( dash1 )
      dc.set_pen( ud )
      dc.draw_line(dc.from_dip(x + 20), dc.from_dip(y + 170), dc.from_dip(100), dc.from_dip(y + 170))
  
      penWithCap = Wx::Pen.new(Wx::BLACK, width)
      dc.set_pen(penWithCap)
      dc.draw_text("Default cap", dc.from_dip(x + 270), dc.from_dip(y + 40))
      dc.draw_line(dc.from_dip(x + 200), dc.from_dip(y + 50), dc.from_dip(x + 250), dc.from_dip(y + 50))
  
      penWithCap.set_cap(Wx::CAP_BUTT)
      dc.set_pen(penWithCap)
      dc.draw_text("Butt ", dc.from_dip(x + 270), dc.from_dip(y + 60))
      dc.draw_line(dc.from_dip(x + 200), dc.from_dip(y + 70), dc.from_dip(x + 250), dc.from_dip(y + 70))
  
      penWithCap.set_cap(Wx::CAP_ROUND)
      dc.set_pen(penWithCap)
      dc.draw_text("Round cap", dc.from_dip(x + 270), dc.from_dip(y + 80))
      dc.draw_line(dc.from_dip(x + 200), dc.from_dip(y + 90), dc.from_dip(x + 250), dc.from_dip(y + 90))
  
      penWithCap.set_cap(Wx::CAP_PROJECTING)
      dc.set_pen(penWithCap)
      dc.draw_text("Projecting cap", dc.from_dip(x + 270), dc.from_dip(y + 100))
      dc.draw_line(dc.from_dip(x + 200), dc.from_dip(y + 110), dc.from_dip(x + 250), dc.from_dip(y + 110))
    end

    def draw_cross_hair(x, y, width, height, dc)
      dc.draw_text("Cross hair", dc.from_dip(x + 10), dc.from_dip(y + 10))
      dc.set_clipping_region(dc.from_dip(x), dc.from_dip(y), dc.from_dip(width), dc.from_dip(height))
      dc.set_pen(Wx::Pen.new(Wx::BLUE, 2))
      dc.cross_hair(dc.from_dip(x + width / 2), dc.from_dip(y + height / 2))
      dc.destroy_clipping_region
    end

    def draw_test_poly(dc)
      brushHatch = Wx::Brush.new(Wx::RED, Wx::BRUSHSTYLE_FDIAGONAL_HATCH)
      dc.set_brush(brushHatch)
  
      star = [
        dc.from_dip(Wx::Point.new(100, 60)),
        dc.from_dip(Wx::Point.new(60, 150)),
        dc.from_dip(Wx::Point.new(160, 100)),
        dc.from_dip(Wx::Point.new(40, 100)),
        dc.from_dip(Wx::Point.new(140, 150))]
  
      dc.draw_text("You should see two (irregular) stars below, the left one hatched",
                   dc.from_dip(10), dc.from_dip(10))
      dc.draw_text("except for the central region and the right one entirely hatched",
                   dc.from_dip(10), dc.from_dip(30))
      dc.draw_text("The third star only has a hatched outline", dc.from_dip(10), dc.from_dip(50))
  
      dc.draw_polygon(star, 0, dc.from_dip(30))
      dc.draw_polygon(star, dc.from_dip(160), dc.from_dip(30), Wx::WINDING_RULE)
  
      brushHatchGreen = Wx::Brush.new(Wx::GREEN, Wx::BRUSHSTYLE_FDIAGONAL_HATCH)
      dc.set_brush(brushHatchGreen)
      star2 = [
        [dc.from_dip(Wx::Point.new(0, 100)),
         dc.from_dip(Wx::Point.new(-59, -81)),
         dc.from_dip(Wx::Point.new(95, 31)),
         dc.from_dip(Wx::Point.new(-95, 31)),
         dc.from_dip(Wx::Point.new(59, -81))],
        [dc.from_dip(Wx::Point.new(0, 80)),
         dc.from_dip(Wx::Point.new(-47, -64)),
         dc.from_dip(Wx::Point.new(76, 24)),
         dc.from_dip(Wx::Point.new(-76, 24)),
         dc.from_dip(Wx::Point.new(47, -64))]]

      dc.draw_poly_polygon(star2, dc.from_dip(450), dc.from_dip(150))
    end

    def draw_test_brushes(dc)
      _WIDTH = dc.from_dip(200)
      _HEIGHT = dc.from_dip(80)
  
      x = dc.from_dip(10)
      y = dc.from_dip(10)
      o = dc.from_dip(10)
  
      dc.set_brush(Wx::GREEN_BRUSH)
      dc.draw_rectangle(x, y, _WIDTH, _HEIGHT)
      dc.draw_text("Solid green", x + o, y + o)
  
      y += _HEIGHT
      dc.set_brush(Wx::Brush.new(Wx::RED, Wx::BRUSHSTYLE_CROSSDIAG_HATCH))
      dc.draw_rectangle(x, y, _WIDTH, _HEIGHT)
      dc.draw_text("Diagonally hatched red", x + o, y + o)
  
      y += _HEIGHT
      dc.set_brush(Wx::Brush.new(Wx::BLUE, Wx::BRUSHSTYLE_CROSS_HATCH))
      dc.draw_rectangle(x, y, _WIDTH, _HEIGHT)
      dc.draw_text("Cross hatched blue", x + o, y + o)
  
      y += _HEIGHT
      dc.set_brush(Wx::Brush.new(Wx::CYAN, Wx::BRUSHSTYLE_VERTICAL_HATCH))
      dc.draw_rectangle(x, y, _WIDTH, _HEIGHT)
      dc.draw_text("Vertically hatched cyan", x + o, y + o)
  
      y += _HEIGHT
      dc.set_brush(Wx::Brush.new(Wx::BLACK, Wx::BRUSHSTYLE_HORIZONTAL_HATCH))
      dc.draw_rectangle(x, y, _WIDTH, _HEIGHT)
      dc.draw_text("Horizontally hatched black", x + o, y + o)
  
      y += _HEIGHT
      dc.set_brush(Wx::Brush.new(Wx.get_app.images[:bmpMask]))
      dc.draw_rectangle(x, y, _WIDTH, _HEIGHT)
      dc.draw_text("Stipple mono", x + o, y + o)
  
      y += _HEIGHT
      dc.set_brush(Wx::Brush.new(Wx.get_app.images[:bmpNoMask]))
      dc.draw_rectangle(x, y, _WIDTH, _HEIGHT)
      dc.draw_text("Stipple colour", x + o, y + o)
    end

    def draw_text(dc)
      # set underlined font for testing
      dc.set_font(Wx::FontInfo.new(12).family(Wx::FONTFAMILY_MODERN).underlined)
      dc.draw_text("This is text", dc.from_dip(110), dc.from_dip(10) )
      dc.draw_rotated_text("That is text", dc.from_dip(20), dc.from_dip(10), -45)

      # use wxSWISS_FONT and not wxNORMAL_FONT as the latter can't be rotated
      # under MSW (it is not TrueType)
      dc.set_font(Wx::SWISS_FONT)

      dc.set_background_mode(Wx::BRUSHSTYLE_TRANSPARENT)

      (-180..180).step(30) do |n|
        text = "     #{n} rotated text"
        dc.draw_rotated_text(text , dc.from_dip(400), dc.from_dip(400), n)
      end

      dc.set_font(Wx::FontInfo.new(18).family(Wx::FONTFAMILY_SWISS))

      dc.draw_text("This is Swiss 18pt text.", dc.from_dip(110), dc.from_dip(40))

      length, height, descent = dc.get_text_extent("This is Swiss 18pt text.")
      text = "Dimensions are length #{length}, height #{height}, descent #{descent}"
      dc.draw_text(text, dc.from_dip(110), dc.from_dip(80))

      text = "CharHeight() returns: #{dc.get_char_height}"
      dc.draw_text(text, dc.from_dip(110), dc.from_dip(120))

      dc.draw_rectangle(dc.from_dip(100), dc.from_dip(40), dc.from_dip(4), dc.from_dip(height))

      # test the logical function effect
      y = dc.from_dip(150)
      dc.set_logical_function(Wx::INVERT)
      # text drawing should ignore logical function
      dc.draw_text("There should be a text below", dc.from_dip(110), y)
      dc.draw_rectangle(dc.from_dip(110), y, dc.from_dip(100), height)

      y += height
      dc.draw_text("Visible text", dc.from_dip(110), y)
      dc.draw_rectangle(dc.from_dip(110), y, dc.from_dip(100), height)
      dc.draw_text("Visible text", dc.from_dip(110), y)
      dc.draw_rectangle(dc.from_dip(110), y, dc.from_dip(100), height)
      dc.set_logical_function(Wx::COPY)

      y += height
      dc.draw_rectangle(dc.from_dip(110), y, dc.from_dip(100), height)
      dc.draw_text("Another visible text", dc.from_dip(110), y)

      y += height
      dc.draw_text("And\nmore\ntext on\nmultiple\nlines", dc.from_dip(110), y)
      y += 5*height

      dc.set_text_foreground(Wx::BLUE)
      dc.draw_rotated_text("Rotated text\ncan have\nmultiple lines\nas well", dc.from_dip(110), y, 15)

      y += 7*height
      dc.set_font(Wx::FontInfo.new(12).family(Wx::FONTFAMILY_TELETYPE))
      dc.set_text_foreground(Wx::Colour.new(150, 75, 0))
      dc.draw_text("And some text with tab characters:\n123456789012345678901234567890\n\taa\tbbb\tcccc", dc.from_dip(10), y)
    end

    RASTER_OPERATIONS = [
         ["Wx::AND",          Wx::AND           ],
         ["Wx::AND_INVERT",   Wx::AND_INVERT    ],
         ["Wx::AND_REVERSE",  Wx::AND_REVERSE   ],
         ["Wx::CLEAR",        Wx::CLEAR         ],
         ["Wx::COPY",         Wx::COPY          ],
         ["Wx::EQUIV",        Wx::EQUIV         ],
         ["Wx::INVERT",       Wx::INVERT        ],
         ["Wx::NAND",         Wx::NAND          ],
         ["Wx::NO_OP",        Wx::NO_OP         ],
         ["Wx::OR",           Wx::OR            ],
         ["Wx::OR_INVERT",    Wx::OR_INVERT     ],
         ["Wx::OR_REVERSE",   Wx::OR_REVERSE    ],
         ["Wx::SET",          Wx::SET           ],
         ["Wx::SRC_INVERT",   Wx::SRC_INVERT    ],
         ["Wx::XOR",          Wx::XOR           ],
      ]
    
    def draw_images(dc, mode)
      dc.draw_text("original image", 0, 0)
      dc.draw_bitmap(Wx.get_app.images[:bmpNoMask], 0, dc.from_dip(20), false)
      dc.draw_text("with colour mask", 0, dc.from_dip(100))
      dc.draw_bitmap(Wx.get_app.images[:bmpWithColMask], 0, dc.from_dip(120), true)
      dc.draw_text("the mask image", 0, dc.from_dip(200))
      dc.draw_bitmap(Wx.get_app.images[:bmpMask], 0, dc.from_dip(220), false)
      dc.draw_text("masked image", 0, dc.from_dip(300))
      dc.draw_bitmap(Wx.get_app.images[:bmpWithMask], 0, dc.from_dip(320), true)
  
      cx = Wx.get_app.images[:bmpWithColMask].width
      cy = Wx.get_app.images[:bmpWithColMask].height
  
      Wx::MemoryDC.draw_on do |memDC|
        RASTER_OPERATIONS.each_with_index do |pair, n|
          x = dc.from_dip(120) + dc.from_dip(150)*(n%4)
          y = dc.from_dip(20)  + dc.from_dip(100)*(n/4)

          name, rop = pair

          dc.draw_text(name, x, y - dc.from_dip(20))
          memDC.select_object(Wx.get_app.images[:bmpWithColMask])
          if mode == DrawMode::Draw_Stretch
              dc.stretch_blit(x, y, cx, cy, memDC, 0, 0, cx/2, cy/2,
                              rop, true)
          else
              dc.blit(x, y, cx, cy, memDC, 0, 0, rop, true)
          end
        end
      end
    end

    def draw_with_logical_ops(dc)
      w = dc.from_dip(60)
      h = dc.from_dip(60)
  
      # reuse the text colour here
      dc.set_pen(Wx::Pen.new(@owner.colourForeground))
      dc.set_brush(Wx::TRANSPARENT_BRUSH)

      RASTER_OPERATIONS.each_with_index do |pair, n|
        x = dc.from_dip(20) + dc.from_dip(150)*(n%4)
        y = dc.from_dip(20) + dc.from_dip(100)*(n/4)

        name, rop = pair

        dc.draw_text(name, x, y - dc.from_dip(20))
        dc.set_logical_function(rop)
        dc.draw_rectangle(x, y, w, h)
        dc.draw_line(x, y, x + w, y + h)
        dc.draw_line(x + w, y, x, y + h)
      end
  
      # now some filled rectangles
      dc.set_brush(Wx::Brush.new(@owner.colourForeground))

      RASTER_OPERATIONS.each_with_index do |pair, n|
        x = dc.from_dip(20) + dc.from_dip(150)*(n%4)
        y = dc.from_dip(500) + dc.from_dip(100)*(n/4)

        name, rop = pair

        dc.draw_text(name, x, y - dc.from_dip(20))
        dc.set_logical_function(rop)
        dc.draw_rectangle(x, y, w, h)
      end
    end

    def draw_alpha(dc)
      if DRAWING_DC_SUPPORTS_ALPHA || Wx.has_feature?(:USE_GRAPHICS_CONTEXT)
        margin = dc.from_dip(20)
        width = dc.from_dip(180)
        radius = dc.from_dip(30)
    
        dc.set_pen(Wx::Pen.new(Wx::Colour.new(128, 0, 0 ), 12))
        dc.set_brush(Wx::RED_BRUSH)
    
        r = Wx::Rect.new(margin, margin + width * 2 / 3, width, width)
    
        dc.draw_rounded_rectangle(r.x, r.y, r.width, r.width, radius) 
    
        dc.set_pen(Wx::Pen.new(Wx::Colour.new( 0, 0, 128 ), 12))
        dc.set_brush(Wx::Brush.new(Wx::Colour.new(0, 0, 255, 192)))
    
        r.offset!(width * 4 / 5, -width * 2 / 3)
    
        dc.draw_rounded_rectangle(r.x, r.y, r.width, r.width, radius)
    
        dc.set_pen(Wx::Pen.new(Wx::Colour.new( 128, 128, 0 ), 12))
        dc.set_brush(Wx::Brush.new(Wx::Colour.new( 192, 192, 0, 192)))
    
        r.offset!(width * 4 / 5, width / 2)
    
        dc.draw_rounded_rectangle(r.x, r.y, r.width, r.width, radius)
    
        dc.set_pen(Wx::TRANSPARENT_PEN)
        dc.set_brush(Wx::Brush.new(Wx::Colour.new(255,255,128,128) ))
        dc.draw_rounded_rectangle( 0 , margin + width / 2 , width * 3 , dc.from_dip(100) , radius) 
    
        dc.set_text_background(Wx::Colour.new(160, 192, 160, 160))
        dc.set_text_foreground(Wx::Colour.new(255, 128, 128, 128))
        dc.set_font(Wx::FontInfo.new(40).family(Wx::FONTFAMILY_SWISS).italic)
        dc.draw_text("Hello!", dc.from_dip(120), dc.from_dip(80))
      end
    end

    def draw_graphics(gc)
      if Wx.has_feature?(:USE_GRAPHICS_CONTEXT)
        _BASE = gc.from_dip(80).to_f
        _BASE2 = _BASE / 2
        _BASE4 = _BASE / 4
    
        font = Wx::SystemSettings.get_font(Wx::SYS_DEFAULT_GUI_FONT)
        gc.set_font(font,Wx::BLACK)
    
        # make a path that contains a circle and some lines, centered at 0,0
        path = gc.create_path 
        path.add_circle( 0, 0, _BASE2 )
        path.move_to_point(0, -_BASE2)
        path.add_line_to_point(0, _BASE2)
        path.move_to_point(-_BASE2, 0)
        path.add_line_to_point(_BASE2, 0)
        path.close_subpath
        path.add_rectangle(-_BASE4, -_BASE4/2, _BASE2, _BASE4)
    
        # Now use that path to demonstrate various capabilities of the graphics context
        gc.push_state # save current translation/scale/other state
        gc.translate(gc.from_dip(60), gc.from_dip(75)) # reposition the context origin
    
        gc.set_pen(Wx::Pen.new("navy"))
        gc.set_brush(Wx::Brush.new(:pink))
    
        3.times do |i|
          case i
          when 0
            label = "StrokePath"
          when 1
            label = "FillPath"
          when 2
            label = "DrawPath"
          end
          w, h, _, _ = gc.get_text_extent(label)
          gc.draw_text(label, -w/2, -_BASE2 - h - gc.from_dip(4))
          case i
          when 0
            gc.stroke_path(path)
          when 1
            gc.fill_path(path)
          when 2
            gc.draw_path(path)
          end
          gc.translate(2*_BASE, 0)
        end
    
        gc.pop_state # restore saved state
        gc.push_state # save it again
        gc.translate(gc.from_dip(60), gc.from_dip(200)) # offset to the lower part of the window
    
        gc.draw_text("Scale", 0, -_BASE2)
        gc.translate(0, gc.from_dip(20))
    
        gc.set_brush(Wx::Brush.new(Wx::Colour.new(178,  34,  34, 128)))# 128 == half transparent
        8.times do
            gc.scale(1.08, 1.08) # increase scale by 8%
            gc.translate(gc.from_dip(5), gc.from_dip(5))
            gc.draw_path(path)
        end
    
        gc.pop_state # restore saved state
        gc.push_state # save it again
        gc.translate(gc.from_dip(400), gc.from_dip(200))
    
        gc.draw_text("Rotate", 0, -_BASE2)
    
        # Move the origin over to the next location
        gc.translate(0, gc.from_dip(75))
    
        # draw our path again, rotating it about the central point,
        # and changing colors as we go
        (0...360).step(30) do |angle|
          gc.push_state # save this new current state so we can
          #  pop back to it at the end of the loop
          val = Wx::Image::HSVValue.new(angle / 360.0, 1.0, 1.0).to_rgb
          gc.set_brush(Wx::Brush.new(Wx::Colour.new(val.red, val.green, val.blue, 64)))
          gc.set_pen(Wx::Pen.new(Wx::Colour.new(val.red, val.green, val.blue, 128)))

          # use translate to artfully reposition each drawn path
          gc.translate(1.5 * _BASE2 * Math.cos(Wx.deg_to_rad(angle)),
                       1.5 * _BASE2 * Math.sin(Wx.deg_to_rad(angle)))

          # use Rotate to rotate the path
          gc.rotate(Wx.deg_to_rad(angle))

          # now draw it
          gc.draw_path(path)
          gc.pop_state
        end
        gc.pop_state
    
        gc.push_state
        gc.translate(gc.from_dip(60), gc.from_dip(400))
        label_text = 'Scaled smiley inside a square'
        gc.draw_text(label_text, 0, 0)
        # Center a bitmap horizontally
        textWidth, _, _, _ =  gc.get_text_extent(label_text)
        rectSize = gc.from_dip(100)
        x0 = (textWidth - rectSize) / 2
        gc.draw_rectangle(x0, _BASE2, rectSize, rectSize)
        gc.draw_bitmap(@smile_bmp, x0, _BASE2, rectSize, rectSize)
        gc.pop_state
    
        # Draw graphics bitmap and its sub-bitmap
        gc.push_state
        gc.translate(gc.from_dip(300), gc.from_dip(400))
        gc.draw_text('Smiley as a graphics bitmap', 0, 0)
    
        gbmp1 = gc.create_bitmap(@smile_bmp)
        gc.draw_bitmap(gbmp1, 0, _BASE2, gc.from_dip(50), gc.from_dip(50))
        bmpw = @smile_bmp.width
        bmph = @smile_bmp.height
        gbmp2 = gc.create_sub_bitmap(gbmp1, 0, bmph/5, bmpw/2, bmph/2)
        gc.draw_bitmap(gbmp2, gc.from_dip(80), _BASE2, gc.from_dip(50), gc.from_dip(50)*(bmph/2)/(bmpw/2))
        gc.pop_state
      end
    end

    def draw_regions(dc)
      dc.draw_text("You should see a red rect partly covered by a cyan one "+
                  "on the left", dc.from_dip(10), dc.from_dip(5))
      dc.draw_text("and 5 smileys from which 4 are partially clipped on the right",
                  dc.from_dip(10), dc.from_dip(5) + dc.get_char_height)
      dc.draw_text("The second copy should be identical but right part of it "+
                  "should be offset by 10 pixels.",
                  dc.from_dip(10), dc.from_dip(5) + 2*dc.get_char_height)
  
      draw_regions_helper(dc, dc.from_dip(10), true)
      draw_regions_helper(dc, dc.from_dip(350), false)
    end

    def draw_circles(dc)
      x = dc.from_dip(100)
      y = dc.from_dip(100)
      r = dc.from_dip(20)
  
      dc.set_pen(Wx::RED_PEN)
      dc.set_brush(Wx::GREEN_BRUSH)
  
      dc.draw_text("Some circles", 0, y)
      dc.draw_circle(x, y, r)
      dc.draw_circle(x + 2*r, y, r)
      dc.draw_circle(x + 4*r, y, r)
  
      y += 2*r
      dc.draw_text("And ellipses", 0, y)
      dc.draw_ellipse(x - r, y, 2*r, r)
      dc.draw_ellipse(x + r, y, 2*r, r)
      dc.draw_ellipse(x + 3*r, y, 2*r, r)
  
      y += 2*r
      dc.draw_text("And arcs", 0, y)
      dc.draw_arc(x - r, y, x + r, y, x, y)
      dc.draw_arc(x + 4*r, y, x + 2*r, y, x + 3*r, y)
      dc.draw_arc(x + 5*r, y, x + 5*r, y, x + 6*r, y)
  
      y += 2*r
      dc.draw_elliptic_arc(x - r, y, 2*r, r, 0, 90)
      dc.draw_elliptic_arc(x + r, y, 2*r, r, 90, 180)
      dc.draw_elliptic_arc(x + 3*r, y, 2*r, r, 180, 270)
      dc.draw_elliptic_arc(x + 5*r, y, 2*r, r, 270, 360)
  
      # same as above, just transparent brush
  
      dc.set_pen(Wx::RED_PEN)
      dc.set_brush(Wx::TRANSPARENT_BRUSH)
  
      y += 2*r
      dc.draw_text("Some circles", 0, y)
      dc.draw_circle(x, y, r)
      dc.draw_circle(x + 2*r, y, r)
      dc.draw_circle(x + 4*r, y, r)
  
      y += 2*r
      dc.draw_text("And ellipses", 0, y)
      dc.draw_ellipse(x - r, y, 2*r, r)
      dc.draw_ellipse(x + r, y, 2*r, r)
      dc.draw_ellipse(x + 3*r, y, 2*r, r)
  
      y += 2*r
      dc.draw_text("And arcs", 0, y)
      dc.draw_arc(x - r, y, x + r, y, x, y)
      dc.draw_arc(x + 4*r, y, x + 2*r, y, x + 3*r, y)
      dc.draw_arc(x + 5*r, y, x + 5*r, y, x + 6*r, y)
  
      y += 2*r
      dc.draw_elliptic_arc(x - r, y, 2*r, r, 0, 90)
      dc.draw_elliptic_arc(x + r, y, 2*r, r, 90, 180)
      dc.draw_elliptic_arc(x + 3*r, y, 2*r, r, 180, 270)
      dc.draw_elliptic_arc(x + 5*r, y, 2*r, r, 270, 360)
    end

    def draw_splines(dc)
      if Wx.has_feature?(:USE_SPLINES)
        dc.draw_text("Some splines", dc.from_dip(10), dc.from_dip(5))
    
        # values are hardcoded rather than randomly generated
        # so the output can be compared between native
        # implementations on platforms with different random
        # generators
    
        _R = dc.from_dip(300)
        center = Wx::Point.new(_R + dc.from_dip(20), _R + dc.from_dip(20))
        angles = [ 0, 10, 33, 77, 13, 145, 90 ]
        radii = [ 100 , 59, 85, 33, 90 ]
        numPoints = 200
        pts = ::Array.new(numPoints, nil)
        # wxPoint pts[numPoints]
    
        # background spline calculation
        radius_pos = 0
        angle_pos = 0
        angle = 0
        numPoints.times do |i|
          angle += angles[ angle_pos ]
          r = _R * radii[ radius_pos ] / 100
          pts[i] = [center.x + (r * Math.cos((angle * Math::PI)/180)).to_i,
                    center.y + (r * Math.sin((angle * Math::PI)/180)).to_i]
          angle_pos += 1
          angle_pos = 0  if angle_pos >= angles.size
          radius_pos += 1
          radius_pos = 0 if radius_pos >= radii.size 
        end
    
        # background spline drawing
        dc.set_pen(Wx::RED_PEN)
        dc.draw_spline(pts)
    
        # less detailed spline calculation
        letters = ::Array.new(4) { ::Array.new(5) }
        # w
        letters[0][0] = Wx::Point.new( 0,1) #  O           O
        letters[0][1] = Wx::Point.new( 1,3) #   *         *
        letters[0][2] = Wx::Point.new( 2,2) #    *   O   *
        letters[0][3] = Wx::Point.new( 3,3) #     * * * *
        letters[0][4] = Wx::Point.new( 4,1) #      O   O
        # x1
        letters[1][0] = Wx::Point.new( 5,1) #  O*O
        letters[1][1] = Wx::Point.new( 6,1) #     *
        letters[1][2] = Wx::Point.new( 7,2) #      O
        letters[1][3] = Wx::Point.new( 8,3) #       *
        letters[1][4] = Wx::Point.new( 9,3) #        O*O
        # x2
        letters[2][0] = Wx::Point.new( 5,3) #        O*O
        letters[2][1] = Wx::Point.new( 6,3) #       *
        letters[2][2] = Wx::Point.new( 7,2) #      O
        letters[2][3] = Wx::Point.new( 8,1) #     *
        letters[2][4] = Wx::Point.new( 9,1) #  O*O
        # W
        letters[3][0] = Wx::Point.new(10,0) #  O           O
        letters[3][1] = Wx::Point.new(11,3) #   *         *
        letters[3][2] = Wx::Point.new(12,1) #    *   O   *
        letters[3][3] = Wx::Point.new(13,3) #     * * * *
        letters[3][4] = Wx::Point.new(14,0) #      O   O

        dx = 2 * _R / letters[3][4].x
        h = [ (-_R/2), 0, _R/4, _R/2 ]

        letters.each_with_index do |row, m|
          row.each_with_index do |pt, n|
            pt.x = center.x - _R + (pt.x * dx)
            pt.y = center.y + h[pt.y]
          end

          dc.set_pen(Wx::Pen.new(Wx::BLUE, 1, Wx::PENSTYLE_DOT))
          dc.draw_lines(letters[m])
          dc.set_pen(Wx::Pen.new(Wx::BLACK, 4))
          dc.draw_spline(letters[m])
        end
    
      else
        dc.draw_text('Splines not supported.', 10, 5)
      end
    end

    def draw_default(dc)
      # Draw circle centered at the origin, then flood fill it with a different
      # color. Done with a Wx::MemoryDC because Blit (used by generic
      # Wx.do_flood_fill) from a window that is being painted gives unpredictable
      # results on WXGTK
      img = Wx::Image.new(dc.from_dip(21), dc.from_dip(21), false)
      img.clear(1)
      bmp = img.to_bitmap
      Wx::MemoryDC.draw_on(bmp) do |mdc|
        mdc.set_brush(dc.get_brush)
        mdc.set_pen(dc.get_pen)
        mdc.draw_circle(dc.from_dip(10), dc.from_dip(10), dc.from_dip(10))
        c = Wx::Colour.new
        if mdc.get_pixel(dc.from_dip(11), dc.from_dip(11), c)
          mdc.set_brush(Wx::Brush.new(Wx::Colour.new(128, 128, 0)))
          mdc.flood_fill(dc.from_dip(11), dc.from_dip(11), c, Wx::FLOOD_SURFACE)
        end
      end
      bmp.set_mask(Wx::Mask.new(bmp, Wx::Colour.new(1, 1, 1)))
      dc.draw_bitmap(bmp, dc.from_dip(-10), dc.from_dip(-10), true)

      dc.draw_check_mark(dc.from_dip(5), dc.from_dip(80), dc.from_dip(15), dc.from_dip(15))
      dc.draw_check_mark(dc.from_dip(25), dc.from_dip(80), dc.from_dip(30), dc.from_dip(30))
      dc.draw_check_mark(dc.from_dip(60), dc.from_dip(80), dc.from_dip(60), dc.from_dip(60))
  
      # this is the test for "blitting bitmap into DC damages selected brush" bug
      rectSize = @std_icon.width + dc.from_dip(10)
      x = dc.from_dip(100)
      dc.set_pen(Wx::TRANSPARENT_PEN)
      dc.set_brush(Wx::GREEN_BRUSH)
      dc.draw_rectangle(x, dc.from_dip(10), rectSize, rectSize)
      dc.draw_bitmap(@std_icon.to_bitmap, x + dc.from_dip(5), dc.from_dip(15), true)
      x += rectSize + dc.from_dip(10)
      dc.draw_rectangle(x, dc.from_dip(10), rectSize, rectSize)
      dc.draw_icon(@std_icon, x + dc.from_dip(5), dc.from_dip(15))
      x += rectSize + dc.from_dip(10)
      dc.draw_rectangle(x, dc.from_dip(10), rectSize, rectSize)
  
      # test for "transparent" bitmap drawing (it intersects with the last
      # rectangle above)
      #dc.set_brush(Wx::TRANSPARENT_BRUSH)

      dc.draw_bitmap(@smile_bmp, x + rectSize - dc.from_dip(20), rectSize - dc.from_dip(10), true) if (@smile_bmp.ok?)
  
      dc.set_brush(Wx::BLACK_BRUSH)
      dc.draw_rectangle(0, dc.from_dip(160), dc.from_dip(1000), dc.from_dip(300))
  
      # draw lines
      bitmap = Wx::Bitmap.new(dc.from_dip([20,70]))
      Wx::MemoryDC.draw_on(bitmap) do |memdc|
        memdc.set_brush(Wx::BLACK_BRUSH)
        memdc.set_pen(Wx::WHITE_PEN)
        memdc.draw_rectangle(0, 0, dc.from_dip(20), dc.from_dip(70))
        memdc.draw_line( dc.from_dip(10), 0, dc.from_dip(10), dc.from_dip(70) )
    
        # to the right
        pen = Wx::RED_PEN
        memdc.set_pen(pen)
        memdc.draw_line(dc.from_dip(10), dc.from_dip(5),  dc.from_dip(10), dc.from_dip(5) )
        memdc.draw_line(dc.from_dip(10), dc.from_dip(10), dc.from_dip(11), dc.from_dip(10))
        memdc.draw_line(dc.from_dip(10), dc.from_dip(15), dc.from_dip(12), dc.from_dip(15))
        memdc.draw_line(dc.from_dip(10), dc.from_dip(20), dc.from_dip(13), dc.from_dip(20))
    
        # memdc.set_pen(Wx::RED_PEN)
        # memdc.draw_line( dc.from_dip(12),dc.from_dip( 5),dc.from_dip(12),dc.from_dip( 5) )
        # memdc.draw_line( dc.from_dip(12),dc.from_dip(10),dc.from_dip(13),dc.from_dip(10) )
        # memdc.draw_line( dc.from_dip(12),dc.from_dip(15),dc.from_dip(14),dc.from_dip(15) )
        # memdc.draw_line( dc.from_dip(12),dc.from_dip(20),dc.from_dip(15),dc.from_dip(20) )
    
        # same to the left
        memdc.draw_line(dc.from_dip(10), dc.from_dip(25), dc.from_dip(10), dc.from_dip(25))
        memdc.draw_line(dc.from_dip(10), dc.from_dip(30), dc.from_dip(9),  dc.from_dip(30))
        memdc.draw_line(dc.from_dip(10), dc.from_dip(35), dc.from_dip(8),  dc.from_dip(35))
        memdc.draw_line(dc.from_dip(10), dc.from_dip(40), dc.from_dip(7),  dc.from_dip(40))
    
        # XOR draw lines
        dc.set_pen(Wx::WHITE_PEN)
        memdc.set_logical_function(Wx::INVERT)
        memdc.set_pen(Wx::WHITE_PEN)
        memdc.draw_line(dc.from_dip(10), dc.from_dip(50), dc.from_dip(10), dc.from_dip(50))
        memdc.draw_line(dc.from_dip(10), dc.from_dip(55), dc.from_dip(11), dc.from_dip(55))
        memdc.draw_line(dc.from_dip(10), dc.from_dip(60), dc.from_dip(12), dc.from_dip(60))
        memdc.draw_line(dc.from_dip(10), dc.from_dip(65), dc.from_dip(13), dc.from_dip(65))
    
        memdc.draw_line(dc.from_dip(12), dc.from_dip(50), dc.from_dip(12), dc.from_dip(50))
        memdc.draw_line(dc.from_dip(12), dc.from_dip(55), dc.from_dip(13), dc.from_dip(55))
        memdc.draw_line(dc.from_dip(12), dc.from_dip(60), dc.from_dip(14), dc.from_dip(60))
        memdc.draw_line(dc.from_dip(12), dc.from_dip(65), dc.from_dip(15), dc.from_dip(65))
      end
      dc.draw_bitmap(bitmap, dc.from_dip(10), dc.from_dip(170))
      image = bitmap.convert_to_image
      image.rescale(dc.from_dip(60), dc.from_dip(210))
      bitmap = image.to_bitmap
      dc.draw_bitmap(bitmap, dc.from_dip(50), dc.from_dip(170))
  
      # test the rectangle outline drawing - there should be one pixel between
      # the rect and the lines
      dc.set_pen(Wx::WHITE_PEN)
      dc.set_brush(Wx::TRANSPARENT_BRUSH)
      dc.draw_rectangle(dc.from_dip(150), dc.from_dip(170), dc.from_dip(49), dc.from_dip(29))
      dc.draw_rectangle(dc.from_dip(200), dc.from_dip(170), dc.from_dip(49), dc.from_dip(29))
      dc.set_pen(Wx::WHITE_PEN)
      dc.draw_line(dc.from_dip(250), dc.from_dip(210), dc.from_dip(250), dc.from_dip(170))
      dc.draw_line(dc.from_dip(260), dc.from_dip(200), dc.from_dip(150), dc.from_dip(200))
  
      # test the rectangle filled drawing - there should be one pixel between
      # the rect and the lines
      dc.set_pen(Wx::TRANSPARENT_PEN)
      dc.set_brush(Wx::WHITE_BRUSH)
      dc.draw_rectangle(dc.from_dip(300), dc.from_dip(170), dc.from_dip(49), dc.from_dip(29))
      dc.draw_rectangle(dc.from_dip(350), dc.from_dip(170), dc.from_dip(49), dc.from_dip(29))
      dc.set_pen(Wx::WHITE_PEN)
      dc.draw_line(dc.from_dip(400), dc.from_dip(170), dc.from_dip(400), dc.from_dip(210))
      dc.draw_line(dc.from_dip(300), dc.from_dip(200), dc.from_dip(410), dc.from_dip(200))
  
      # a few more tests of this kind
      dc.set_pen(Wx::RED_PEN)
      dc.set_brush(Wx::WHITE_BRUSH)
      dc.draw_rectangle(dc.from_dip(300), dc.from_dip(220), dc.from_dip(1), dc.from_dip(1))
      dc.draw_rectangle(dc.from_dip(310), dc.from_dip(220), dc.from_dip(2), dc.from_dip(2))
      dc.draw_rectangle(dc.from_dip(320), dc.from_dip(220), dc.from_dip(3), dc.from_dip(3))
      dc.draw_rectangle(dc.from_dip(330), dc.from_dip(220), dc.from_dip(4), dc.from_dip(4))
  
      dc.set_pen(Wx::TRANSPARENT_PEN)
      dc.set_brush(Wx::WHITE_BRUSH)
      dc.draw_rectangle(dc.from_dip(300), dc.from_dip(230), dc.from_dip(1), dc.from_dip(1))
      dc.draw_rectangle(dc.from_dip(310), dc.from_dip(230), dc.from_dip(2), dc.from_dip(2))
      dc.draw_rectangle(dc.from_dip(320), dc.from_dip(230), dc.from_dip(3), dc.from_dip(3))
      dc.draw_rectangle(dc.from_dip(330), dc.from_dip(230), dc.from_dip(4), dc.from_dip(4))
  
      # and now for filled rect with outline
      dc.set_pen(Wx::RED_PEN)
      dc.set_brush(Wx::WHITE_BRUSH)
      dc.draw_rectangle(dc.from_dip(500), dc.from_dip(170), dc.from_dip(49), dc.from_dip(29))
      dc.draw_rectangle(dc.from_dip(550), dc.from_dip(170), dc.from_dip(49), dc.from_dip(29))
      dc.set_pen(Wx::WHITE_PEN)
      dc.draw_line(dc.from_dip(600), dc.from_dip(170), dc.from_dip(600), dc.from_dip(210))
      dc.draw_line(dc.from_dip(500), dc.from_dip(200), dc.from_dip(610), dc.from_dip(200))
  
      # test the rectangle outline drawing - there should be one pixel between
      # the rect and the lines
      dc.set_pen(Wx::WHITE_PEN)
      dc.set_brush( Wx::TRANSPARENT_BRUSH )
      dc.draw_rounded_rectangle(dc.from_dip(150), dc.from_dip(270), dc.from_dip(49), dc.from_dip(29), dc.from_dip(6))
      dc.draw_rounded_rectangle(dc.from_dip(200), dc.from_dip(270), dc.from_dip(49), dc.from_dip(29), dc.from_dip(6))
      dc.set_pen(Wx::WHITE_PEN)
      dc.draw_line(dc.from_dip(250), dc.from_dip(270), dc.from_dip(250), dc.from_dip(310))
      dc.draw_line(dc.from_dip(150), dc.from_dip(300), dc.from_dip(260), dc.from_dip(300))
  
      # test the rectangle filled drawing - there should be one pixel between
      # the rect and the lines
      dc.set_pen(Wx::TRANSPARENT_PEN)
      dc.set_brush( Wx::WHITE_BRUSH )
      dc.draw_rounded_rectangle(dc.from_dip(300), dc.from_dip(270), dc.from_dip(49), dc.from_dip(29), dc.from_dip(6))
      dc.draw_rounded_rectangle(dc.from_dip(350), dc.from_dip(270), dc.from_dip(49), dc.from_dip(29), dc.from_dip(6))
      dc.set_pen(Wx::WHITE_PEN)
      dc.draw_line(dc.from_dip(400), dc.from_dip(270), dc.from_dip(400), dc.from_dip(310))
      dc.draw_line(dc.from_dip(300), dc.from_dip(300), dc.from_dip(410), dc.from_dip(300))
  
      # Added by JACS to demonstrate bizarre behaviour.
      # With a size of 70, we get a missing red RHS,
      # and the height is too small, so we get yellow
      # showing. With a size of 40, it draws as expected:
      # it just shows a white rectangle with red outline.
      totalWidth = dc.from_dip(70)
      totalHeight = dc.from_dip(70)
      bitmap2 = Wx::Bitmap.new(totalWidth, totalHeight)
  
      Wx::MemoryDC.draw_on(bitmap2) do |memdc2|
        memdc2.set_background(Wx::YELLOW_BRUSH)
        memdc2.clear

        # Now draw a white rectangle with red outline. It should
        # entirely eclipse the yellow background.
        memdc2.set_pen(Wx::RED_PEN)
        memdc2.set_brush(Wx::WHITE_BRUSH)

        memdc2.draw_rectangle(0, 0, totalWidth, totalHeight)
      end
  
      dc.draw_bitmap(bitmap2, dc.from_dip(500), dc.from_dip(270))
  
      # Repeat, but draw directly on dc
      # Draw a yellow rectangle filling the bitmap
  
      x = dc.from_dip(600)
      y = dc.from_dip(270)
      dc.set_pen(Wx::YELLOW_PEN)
      dc.set_brush(Wx::YELLOW_BRUSH)
      dc.draw_rectangle(x, y, totalWidth, totalHeight)
  
      # Now draw a white rectangle with red outline. It should
      # entirely eclipse the yellow background.
      dc.set_pen(Wx::RED_PEN)
      dc.set_brush(Wx::WHITE_BRUSH)
  
      dc.draw_rectangle(x, y, totalWidth, totalHeight)
    end

    def draw_gradients(dc)
      text_height = dc.get_char_height
  
      # LHS: linear
      r = Wx::Rect.new(dc.from_dip(10), dc.from_dip(10), dc.from_dip(50), dc.from_dip(50))
      dc.draw_text("Wx::RIGHT", r.x, r.y)
      r.offset!(0, text_height)
      dc.gradient_fill_linear(r, Wx::WHITE, Wx::BLUE, Wx::RIGHT)
  
      r.offset!(0, r.height + dc.from_dip(10))
      dc.draw_text("Wx::LEFT", r.x, r.y)
      r.offset!(0, text_height)
      dc.gradient_fill_linear(r, Wx::WHITE, Wx::BLUE, Wx::LEFT)
  
      r.offset!(0, r.height + dc.from_dip(10))
      dc.draw_text("Wx::DOWN", r.x, r.y)
      r.offset!(0, text_height)
      dc.gradient_fill_linear(r, Wx::WHITE, Wx::BLUE, Wx::DOWN)
  
      r.offset!(0, r.height + dc.from_dip(10))
      dc.draw_text("Wx::UP", r.x, r.y)
      r.offset!(0, text_height)
      dc.gradient_fill_linear(r, Wx::WHITE, Wx::BLUE, Wx::UP)
  
      gfr = Wx::Rect.new.assign(r)
  
      # RHS: concentric
      r = Wx::Rect.new(dc.from_dip(200), dc.from_dip(10), dc.from_dip(50), dc.from_dip(50))
      dc.draw_text("Blue inside", r.x, r.y)
      r.offset!(0, text_height)
      dc.gradient_fill_concentric(r, Wx::BLUE, Wx::WHITE)
  
      r.offset!(0, r.height + dc.from_dip(10))
      dc.draw_text("White inside", r.x, r.y)
      r.offset!(0, text_height)
      dc.gradient_fill_concentric(r, Wx::WHITE, Wx::BLUE)
  
      r.offset!(0, r.height + dc.from_dip(10))
      dc.draw_text("Blue in top left corner", r.x, r.y)
      r.offset!(0, text_height)
      dc.gradient_fill_concentric(r, Wx::BLUE, Wx::WHITE, [0, 0])
  
      r.offset!(0, r.height + dc.from_dip(10))
      dc.draw_text("Blue in bottom right corner", r.x, r.y)
      r.offset!(0, text_height)
      dc.gradient_fill_concentric(r, Wx::BLUE, Wx::WHITE, [r.width, r.height])
  
      # check that the area filled by the gradient is exactly the interior of
      # the rectangle
      r.x = dc.from_dip(350)
      r.y = dc.from_dip(30)
      dc.draw_text("The interior should be filled but", r.x, r.y)
      r.y += text_height
      dc.draw_text(" the red border should remain visible:", r.x, r.y)
      r.y += text_height
  
      r.width =
      r.height = dc.from_dip(50)
      r2 = Wx::Rect.new.assign(r)
      r2.x += dc.from_dip(60)
      r3 = Wx::Rect.new.assign(r)
      r3.y += dc.from_dip(60)
      r4 = Wx::Rect.new.assign(r2)
      r4.y += dc.from_dip(60)
      dc.set_pen(Wx::RED_PEN)
      dc.draw_rectangle(r)
      r.deflate!(1)
      dc.gradient_fill_linear(r, Wx::GREEN, Wx::BLACK, Wx::NORTH)
      dc.draw_rectangle(r2)
      r2.deflate!(1)
      dc.gradient_fill_linear(r2, Wx::BLACK, Wx::GREEN, Wx::SOUTH)
      dc.draw_rectangle(r3)
      r3.deflate!(1)
      dc.gradient_fill_linear(r3, Wx::GREEN, Wx::BLACK, Wx::EAST)
      dc.draw_rectangle(r4)
      r4.deflate!(1)
      dc.gradient_fill_linear(r4, Wx::BLACK, Wx::GREEN, Wx::WEST)
  
      if Wx.has_feature?(:USE_GRAPHICS_CONTEXT)
        if @renderer
          gc = dc.get_graphics_context
          # double boxX, boxY, boxWidth, boxHeight

          gfr.offset!(0, gfr.height + gc.from_dip(10))
          dc.draw_text("Linear Gradient with Stops", gfr.x, gfr.y)
          gfr.offset!(0, text_height)

          stops = Wx::GraphicsGradientStops.new(Wx::RED, Wx::BLUE)
          stops.add(Wx::Colour.new(255,255,0), 0.33)
          stops.add(Wx::GREEN, 0.67)

          gc.set_brush(gc.create_linear_gradient_brush(gfr.x, gfr.y,
                                                       gfr.x + gfr.width, gfr.y + gfr.height,
                                                       stops))
          pth = gc.create_path
          pth.move_to_point(gfr.x,gfr.y)
          pth.add_line_to_point(gfr.x + gfr.width,gfr.y)
          pth.add_line_to_point(gfr.x + gfr.width,gfr.y+gfr.height)
          pth.add_line_to_point(gfr.x,gfr.y+gfr.height)
          pth.close_subpath
          gc.fill_path(pth)
          boxX, boxY, boxWidth, boxHeight = pth.get_box
          dc.calc_bounding_box(boxX.round, boxY.round)
          dc.calc_bounding_box((boxX+boxWidth).round, (boxY+boxHeight).round)

          simpleStops = Wx::GraphicsGradientStops.new(Wx::RED, Wx::BLUE)

          gfr.offset!(0, gfr.height + gc.from_dip(10))
          dc.draw_text("Radial Gradient from Red to Blue without intermediary Stops",
              gfr.x, gfr.y)
          gfr.offset!(0, text_height)

          gc.set_brush(gc.create_radial_gradient_brush(gfr.x + gfr.width / 2,
                                                       gfr.y + gfr.height / 2,
                                                       gfr.x + gfr.width / 2,
                                                       gfr.y + gfr.height / 2,
                                                       gfr.width / 2,
                                                       simpleStops))

          pth = gc.create_path
          pth.move_to_point(gfr.x,gfr.y)
          pth.add_line_to_point(gfr.x + gfr.width,gfr.y)
          pth.add_line_to_point(gfr.x + gfr.width,gfr.y+gfr.height)
          pth.add_line_to_point(gfr.x,gfr.y+gfr.height)
          pth.close_subpath
          gc.fill_path(pth)
          boxX, boxY, boxWidth, boxHeight = pth.get_box
          dc.calc_bounding_box(boxX.round, boxY.round)
          dc.calc_bounding_box((boxX+boxWidth).round, (boxY+boxHeight).round)

          gfr.offset!(0, gfr.height + gc.from_dip(10))
          dc.draw_text("Radial Gradient from Red to Blue with Yellow and Green Stops",
              gfr.x, gfr.y)
          gfr.offset!(0, text_height)

          gc.set_brush(gc.create_radial_gradient_brush(gfr.x + gfr.width / 2,
                                                       gfr.y + gfr.height / 2,
                                                       gfr.x + gfr.width / 2,
                                                       gfr.y + gfr.height / 2,
                                                       gfr.width / 2,
                                                       stops))
          pth = gc.create_path
          pth.move_to_point(gfr.x,gfr.y)
          pth.add_line_to_point(gfr.x + gfr.width,gfr.y)
          pth.add_line_to_point(gfr.x + gfr.width,gfr.y+gfr.height)
          pth.add_line_to_point(gfr.x,gfr.y+gfr.height)
          pth.close_subpath
          gc.fill_path(pth)
          boxX, boxY, boxWidth, boxHeight = pth.get_box
          dc.calc_bounding_box(boxX.round, boxY.round)
          dc.calc_bounding_box((boxX+boxWidth).round, (boxY+boxHeight).round)

          gfr.offset!(0, gfr.height + gc.from_dip(10))
          dc.draw_text("Linear Gradient with Stops and Gaps", gfr.x, gfr.y)
          gfr.offset!(0, text_height)

          stops = Wx::GraphicsGradientStops.new(Wx::RED, Wx::BLUE)
          stops.add(Wx::Colour.new(255,255,0), 0.33)
          stops.add(Wx::TRANSPARENT_COLOUR, 0.33)
          stops.add(Wx::TRANSPARENT_COLOUR, 0.67)
          stops.add(Wx::GREEN, 0.67)

          gc.set_brush(gc.create_linear_gradient_brush(gfr.x, gfr.y + gfr.height,
                                                       gfr.x + gfr.width, gfr.y,
                                                       stops))
          pth = gc.create_path
          pth.move_to_point(gfr.x,gfr.y)
          pth.add_line_to_point(gfr.x + gfr.width,gfr.y)
          pth.add_line_to_point(gfr.x + gfr.width,gfr.y+gfr.height)
          pth.add_line_to_point(gfr.x,gfr.y+gfr.height)
          pth.close_subpath
          gc.fill_path(pth)
          boxX, boxY, boxWidth, boxHeight = pth.get_box
          dc.calc_bounding_box(boxX.round, boxY.round)
          dc.calc_bounding_box((boxX+boxWidth).round, (boxY+boxHeight).round)

          gfr.offset!(0, gfr.height + gc.from_dip(10))
          dc.draw_text("Radial Gradient with Stops and Gaps", gfr.x, gfr.y)
          gfr.offset!(0, text_height)

          gc.set_brush(gc.create_radial_gradient_brush(gfr.x + gfr.width / 2,
                                                       gfr.y + gfr.height / 2,
                                                       gfr.x + gfr.width / 2,
                                                       gfr.y + gfr.height / 2,
                                                       gfr.width / 2,
                                                       stops))
          pth = gc.create_path
          pth.move_to_point(gfr.x,gfr.y)
          pth.add_line_to_point(gfr.x + gfr.width,gfr.y)
          pth.add_line_to_point(gfr.x + gfr.width,gfr.y+gfr.height)
          pth.add_line_to_point(gfr.x,gfr.y+gfr.height)
          pth.close_subpath
          gc.fill_path(pth)
          boxX, boxY, boxWidth, boxHeight = pth.get_box
          dc.calc_bounding_box(boxX.round, boxY.round)
          dc.calc_bounding_box((boxX+boxWidth).round, (boxY+boxHeight).round)

          gfr.offset!(0, gfr.height + gc.from_dip(10))
          dc.draw_text("Gradients with Stops and Transparency", gfr.x, gfr.y)
          gfr.offset!(0, text_height)

          stops = Wx::GraphicsGradientStops.new(Wx::RED, Wx::TRANSPARENT_COLOUR)
          stops.add(Wx::RED, 0.33)
          stops.add(Wx::TRANSPARENT_COLOUR, 0.33)
          stops.add(Wx::TRANSPARENT_COLOUR, 0.67)
          stops.add(Wx::BLUE, 0.67)
          stops.add(Wx::BLUE, 1.0)

          pth = gc.create_path
          pth.move_to_point(gfr.x,gfr.y)
          pth.add_line_to_point(gfr.x + gfr.width,gfr.y)
          pth.add_line_to_point(gfr.x + gfr.width,gfr.y+gfr.height)
          pth.add_line_to_point(gfr.x,gfr.y+gfr.height)
          pth.close_subpath

          gc.set_brush(gc.create_radial_gradient_brush(gfr.x + gfr.width / 2,
                                                       gfr.y + gfr.height / 2,
                                                       gfr.x + gfr.width / 2,
                                                       gfr.y + gfr.height / 2,
                                                       gfr.width / 2,
                                                       stops))
          gc.fill_path(pth)

          stops = Wx::GraphicsGradientStops.new(Wx::Colour.new(255,0,0, 128), Wx::Colour.new(0,0,255, 128))
          stops.add(Wx::Colour.new(255,255,0,128), 0.33)
          stops.add(Wx::Colour.new(0,255,0,128), 0.67)

          gc.set_brush(gc.create_linear_gradient_brush(gfr.x, gfr.y,
                                                     gfr.x + gfr.width, gfr.y,
                                                     stops))
          gc.fill_path(pth)
          boxX, boxY, boxWidth, boxHeight = pth.get_box
          dc.calc_bounding_box(boxX.round, boxY.round)
          dc.calc_bounding_box((boxX+boxWidth).round, (boxY+boxHeight).round)

          gfr.offset!(0, gfr.height + gc.from_dip(10))
          dc.draw_text("Stroked path with a gradient pen", gfr.x, gfr.y)
          gfr.offset!(0, text_height)

          pth = gc.create_path
          pth.move_to_point(gfr.x + gfr.width/2, gfr.y)
          pth.add_line_to_point(gfr.x + gfr.width, gfr.y + gfr.height/2)
          pth.add_line_to_point(gfr.x + gfr.width/2, gfr.y + gfr.height)
          pth.add_line_to_point(gfr.x, gfr.y + gfr.height/2)
          pth.close_subpath

          stops = Wx::GraphicsGradientStops.new(Wx::RED, Wx::BLUE)
          stops.add(Wx::Colour.new(255,255,0), 0.33)
          stops.add(Wx::GREEN, 0.67)

          pen = gc.create_pen(
            Wx::GraphicsPenInfo.new(Wx::Colour.new(0,0,0)).width(6).join(Wx::JOIN_BEVEL).linear_gradient(
                  gfr.x + gfr.width/2, gfr.y,
                  gfr.x + gfr.width/2, gfr.y + gfr.height,
                  stops))
          gc.set_pen(pen)
          gc.stroke_path(pth)
        end
      end # USE_GRAPHICS_CONTEXT
    end

    SYSTEM_COLOURS = {
         Wx::SYS_COLOUR_3DDKSHADOW => "Wx::SYS_COLOUR_3DDKSHADOW" ,
         Wx::SYS_COLOUR_3DLIGHT => "Wx::SYS_COLOUR_3DLIGHT" ,
         Wx::SYS_COLOUR_ACTIVEBORDER => "Wx::SYS_COLOUR_ACTIVEBORDER" ,
         Wx::SYS_COLOUR_ACTIVECAPTION => "Wx::SYS_COLOUR_ACTIVECAPTION" ,
         Wx::SYS_COLOUR_APPWORKSPACE => "Wx::SYS_COLOUR_APPWORKSPACE" ,
         Wx::SYS_COLOUR_BTNFACE => "Wx::SYS_COLOUR_BTNFACE" ,
         Wx::SYS_COLOUR_BTNHIGHLIGHT => "Wx::SYS_COLOUR_BTNHIGHLIGHT" ,
         Wx::SYS_COLOUR_BTNSHADOW => "Wx::SYS_COLOUR_BTNSHADOW" ,
         Wx::SYS_COLOUR_BTNTEXT => "Wx::SYS_COLOUR_BTNTEXT" ,
         Wx::SYS_COLOUR_CAPTIONTEXT => "Wx::SYS_COLOUR_CAPTIONTEXT" ,
         Wx::SYS_COLOUR_DESKTOP => "Wx::SYS_COLOUR_DESKTOP" ,
         Wx::SYS_COLOUR_GRADIENTACTIVECAPTION => "Wx::SYS_COLOUR_GRADIENTACTIVECAPTION" ,
         Wx::SYS_COLOUR_GRADIENTINACTIVECAPTION => "Wx::SYS_COLOUR_GRADIENTINACTIVECAPTION" ,
         Wx::SYS_COLOUR_GRAYTEXT => "Wx::SYS_COLOUR_GRAYTEXT" ,
         Wx::SYS_COLOUR_HIGHLIGHTTEXT => "Wx::SYS_COLOUR_HIGHLIGHTTEXT" ,
         Wx::SYS_COLOUR_HIGHLIGHT => "Wx::SYS_COLOUR_HIGHLIGHT" ,
         Wx::SYS_COLOUR_HOTLIGHT => "Wx::SYS_COLOUR_HOTLIGHT" ,
         Wx::SYS_COLOUR_INACTIVEBORDER => "Wx::SYS_COLOUR_INACTIVEBORDER" ,
         Wx::SYS_COLOUR_INACTIVECAPTIONTEXT => "Wx::SYS_COLOUR_INACTIVECAPTIONTEXT" ,
         Wx::SYS_COLOUR_INACTIVECAPTION => "Wx::SYS_COLOUR_INACTIVECAPTION" ,
         Wx::SYS_COLOUR_INFOBK => "Wx::SYS_COLOUR_INFOBK" ,
         Wx::SYS_COLOUR_INFOTEXT => "Wx::SYS_COLOUR_INFOTEXT" ,
         Wx::SYS_COLOUR_LISTBOXHIGHLIGHTTEXT => "Wx::SYS_COLOUR_LISTBOXHIGHLIGHTTEXT" ,
         Wx::SYS_COLOUR_LISTBOXTEXT => "Wx::SYS_COLOUR_LISTBOXTEXT" ,
         Wx::SYS_COLOUR_LISTBOX => "Wx::SYS_COLOUR_LISTBOX" ,
         Wx::SYS_COLOUR_MENUBAR => "Wx::SYS_COLOUR_MENUBAR" ,
         Wx::SYS_COLOUR_MENUHILIGHT => "Wx::SYS_COLOUR_MENUHILIGHT" ,
         Wx::SYS_COLOUR_MENUTEXT => "Wx::SYS_COLOUR_MENUTEXT" ,
         Wx::SYS_COLOUR_MENU => "Wx::SYS_COLOUR_MENU" ,
         Wx::SYS_COLOUR_SCROLLBAR => "Wx::SYS_COLOUR_SCROLLBAR" ,
         Wx::SYS_COLOUR_WINDOWFRAME => "Wx::SYS_COLOUR_WINDOWFRAME" ,
         Wx::SYS_COLOUR_WINDOWTEXT => "Wx::SYS_COLOUR_WINDOWTEXT" ,
         Wx::SYS_COLOUR_WINDOW => "Wx::SYS_COLOUR_WINDOW" 
    }

    def draw_system_colours(dc)
      mono = Wx::Font.new(Wx::FontInfo.new.family(Wx::FONTFAMILY_TELETYPE))
      textWidth, textHeight, _, _ = dc.with_font(mono) { dc.get_text_extent("#01234567") }

      x = from_dip(10)
      r = Wx::Rect.new(textWidth + x, x, dc.from_dip(100), textHeight)
  
      title = 'System colours'
  
      appearanceName = Wx::SystemSettings.get_appearance_name
      title << " for \"#{appearanceName}\"" unless appearanceName.empty?

      title += " (using dark system theme)" if Wx::SystemSettings.is_appearance_dark
      dc.draw_text(title, x, r.y)
      r.y += 2*textHeight
      dc.draw_text("Window background is #{Wx::SystemSettings.is_appearance_using_dark_background ? 'dark' : 'light'}",
                   x, r.y)
      r.y += 3*textHeight
  
      dc.set_pen(Wx::TRANSPARENT_PEN)

      SYSTEM_COLOURS.each_pair do |index, name|
        c = Wx::Colour.new(Wx::SystemSettings.get_colour(index))
        dc.with_font(mono) { dc.draw_text(c.get_as_string(Wx::C2S_HTML_SYNTAX), x, r.y) }

        dc.set_brush(Wx::Brush.new(c))
        dc.draw_rectangle(r)

        dc.draw_text(name, r.right + x, r.y)

        r.y += textHeight
      end
    end

    def draw_regions_helper(dc, x, firstTime)
      y = dc.from_dip(100)
  
      dc.destroy_clipping_region
      dc.set_brush(Wx::WHITE_BRUSH)
      dc.set_pen(Wx::TRANSPARENT_PEN)
      dc.draw_rectangle(x, y, dc.from_dip(310), dc.from_dip(310))
  
      dc.set_clipping_region(x + dc.from_dip(10), y + dc.from_dip(10), dc.from_dip(100), dc.from_dip(270))
  
      dc.set_brush(Wx::RED_BRUSH)
      dc.draw_rectangle(x, y, dc.from_dip(310), dc.from_dip(310))
  
      dc.set_clipping_region(x + dc.from_dip(10), y + dc.from_dip(10), dc.from_dip(100), dc.from_dip(100))
  
      dc.set_brush(Wx::CYAN_BRUSH)
      dc.draw_rectangle(x, y, dc.from_dip(310), dc.from_dip(310))
  
      dc.destroy_clipping_region
  
      region = Wx::Region.new(x + dc.from_dip(110), y + dc.from_dip(20), dc.from_dip(100), dc.from_dip(270))
      region.offset(dc.from_dip(10), dc.from_dip(10)) unless firstTime
      dc.set_device_clipping_region(region)
  
      dc.set_brush(Wx::GREY_BRUSH)
      dc.draw_rectangle(x, y, dc.from_dip(310), dc.from_dip(310))
  
      if @smile_bmp.ok?
        dc.draw_bitmap(@smile_bmp, x + dc.from_dip(150), y + dc.from_dip(150), true)
        dc.draw_bitmap(@smile_bmp, x + dc.from_dip(130), y + dc.from_dip(10),  true)
        dc.draw_bitmap(@smile_bmp, x + dc.from_dip(130), y + dc.from_dip(280), true)
        dc.draw_bitmap(@smile_bmp, x + dc.from_dip(100), y + dc.from_dip(70),  true)
        dc.draw_bitmap(@smile_bmp, x + dc.from_dip(200), y + dc.from_dip(70),  true)
      end
    end

  end
  
  if Wx.has_feature?(:USE_DC_TRANSFORM_MATRIX)

    class TransformDataDialog < Wx::Dialog
      
      def initialize(parent, dx, dy, scx, scy, rotAngle)
        super(parent, Wx::ID_ANY, 'Affine transformation parameters')
        @dx = dx 
        @dy = dy
        @scx = scx
        @scy = scy
        @rotAngle = rotAngle
        
        sizer = Wx::VBoxSizer.new

        border = Wx::SizerFlags.get_default_border
        paramSizer = Wx::FlexGridSizer.new(2, [border, border])
        paramSizer.add(Wx::StaticText.new(self, Wx::ID_ANY, 'Translation X:'), Wx::SizerFlags.new.centre_vertical)
        val_dx =  Wx::FloatValidator.new(1, Wx::NUM_VAL_NO_TRAILING_ZEROES)
        val_dx.on_transfer_from_window { |v| @dx = v }
        val_dx.on_transfer_to_window { @dx }
        paramSizer.add(Wx::TextCtrl.new(self, Wx::ID_ANY, style: 0, validator: val_dx), Wx::SizerFlags.new.centre_vertical)
        paramSizer.add(Wx::StaticText.new(self, Wx::ID_ANY, 'Translation Y:'), Wx::SizerFlags.new.centre_vertical)
        val_dy = Wx::FloatValidator.new(1, Wx::NUM_VAL_NO_TRAILING_ZEROES)
        val_dy.on_transfer_from_window { |v| @dy = v }
        val_dy.on_transfer_to_window { @dy }
        paramSizer.add(Wx::TextCtrl.new(self, Wx::ID_ANY, style: 0, validator: val_dy), Wx::SizerFlags.new.centre_vertical)
        paramSizer.add(Wx::StaticText.new(self, Wx::ID_ANY, 'Scale X (0.2 - 5):'), Wx::SizerFlags.new.centre_vertical)
        val_scx = Wx::FloatValidator.new(1, Wx::NUM_VAL_NO_TRAILING_ZEROES)
        val_scx.on_transfer_from_window { |v| @scx = v }
        val_scx.on_transfer_to_window { @scx }
        paramSizer.add(Wx::TextCtrl.new(self, Wx::ID_ANY, style: 0, validator: val_scx), Wx::SizerFlags.new.centre_vertical)
        paramSizer.add(Wx::StaticText.new(self, Wx::ID_ANY, 'Scale Y (0.2 - 5):'), Wx::SizerFlags.new.centre_vertical)
        val_scy = Wx::FloatValidator.new(1, Wx::NUM_VAL_NO_TRAILING_ZEROES)
        val_scy.on_transfer_from_window { |v| @scy = v }
        val_scy.on_transfer_to_window { @scy }
        paramSizer.add(Wx::TextCtrl.new(self, Wx::ID_ANY, style: 0, validator: val_scy), Wx::SizerFlags.new.centre_vertical)
        paramSizer.add(Wx::StaticText.new(self, Wx::ID_ANY, 'Rotation angle (deg):'), Wx::SizerFlags.new.centre_vertical)
        val_rot = Wx::FloatValidator.new(1, Wx::NUM_VAL_NO_TRAILING_ZEROES)
        val_rot.on_transfer_from_window { |v| @rotAngle = v }
        val_rot.on_transfer_to_window { @rotAngle }
        paramSizer.add(Wx::TextCtrl.new(self, Wx::ID_ANY, style: 0, validator: val_rot), Wx::SizerFlags.new.centre_vertical)
        sizer.add(paramSizer, Wx::SizerFlags.new.double_border)

        btnSizer = create_separated_button_sizer(Wx::OK | Wx::CANCEL)
        sizer.add(btnSizer, Wx::SizerFlags.new.expand.border)

        set_sizer_and_fit(sizer)
      end
    
      def transfer_data_from_window
        return false unless super

        if @scx < 0.2 || @scx > 5.0 || @scy < 0.2 || @scy > 5.0
          Wx.bell unless Wx::Validator.is_silent
          return false
        end

        true
      end
    
      def get_transformation_data
        [@dx, @dy, @scx, @scy, @rotAngle]
      end
    end

  end # USE_DC_TRANSFORM_MATRIX
  
  class MyFrame < Wx::Frame

    def initialize(title)
      super(nil, title: title)
      # set the frame icon
      self.icon = Wx.Icon(:sample, Wx::BITMAP_TYPE_XPM, art_path: File.join(__dir__, '..'))

      # initialize attributes
      @backgroundMode = Wx::BrushStyle::BRUSHSTYLE_SOLID
      @textureBackground = false
      @mapMode = Wx::MM_TEXT
      @xUserScale = 1.0
      @yUserScale = 1.0
      @xLogicalOrigin = 0
      @yLogicalOrigin = 0
      @xAxisReversed = false
      @yAxisReversed = false
      if Wx.has_feature?(:USE_DC_TRANSFORM_MATRIX)
        @transform_dx = 0.0
        @transform_dy = 0.0
        @transform_scx = 1.0
        @transform_scy = 1.0
        @transform_rot = 0.0
      end # USE_DC_TRANSFORM_MATRIX
      @colourForeground = Wx::BLACK    # these are _text_ colours
      @colourBackground = Wx::LIGHT_GREY
      @backgroundBrush = Wx::Brush.new
      @canvas = MyCanvas.new(self)
      @menuItemUseDC = nil

      # initialize menu and status bar
      menuScreen = Wx::Menu.new
      menuScreen.append(ID::File_ShowDefault, "&Default screen\tF1")
      menuScreen.append(ID::File_ShowText, "&Text screen\tF2")
      menuScreen.append(ID::File_ShowLines, "&Lines screen\tF3")
      menuScreen.append(ID::File_ShowBrushes, "&Brushes screen\tF4")
      menuScreen.append(ID::File_ShowPolygons, "&Polygons screen\tF5")
      menuScreen.append(ID::File_ShowMask, "&Mask screen\tF6")
      menuScreen.append(ID::File_ShowMaskStretch, "1/&2 scaled mask\tShift-F6")
      menuScreen.append(ID::File_ShowOps, "&Raster operations screen\tF7")
      menuScreen.append(ID::File_ShowRegions, "Re&gions screen\tF8")
      menuScreen.append(ID::File_ShowCircles, "&Circles screen\tF9")
      if DRAWING_DC_SUPPORTS_ALPHA || Wx.has_feature?(:USE_GRAPHICS_CONTEXT)
        menuScreen.append(ID::File_ShowAlpha, "&Alpha screen\tF10")
      end # DRAWING_DC_SUPPORTS_ALPHA || USE_GRAPHICS_CONTEXT
      menuScreen.append(ID::File_ShowSplines, "Spl&ines screen\tF11")
      menuScreen.append(ID::File_ShowGradients, "&Gradients screen\tF12")
      if Wx.has_feature?(:USE_GRAPHICS_CONTEXT)
        menuScreen.append(ID::File_ShowGraphics, "&Graphics screen")
      end
      menuScreen.append(ID::File_ShowSystemColours, "System &colours")

      menuFile = Wx::Menu.new
      if Wx.has_feature?(:USE_GRAPHICS_CONTEXT)
        # Number the different renderer choices consecutively, starting from 0.
        accel = -1
        @menuItemUseDC = menuFile.append_radio_item(
          ID::File_DC,"Use wx&DC\t#{accel += 1}")
        menuFile.append_radio_item(
          ID::File_GC_Default, "Use default wx&GraphicContext\t#{accel += 1}")
        if Wx.has_feature?(:USE_CAIRO)
          menuFile.append_radio_item(
            ID::File_GC_Cairo, "Use &Cairo\t#{accel += 1}")
        end # USE_CAIRO
        if Wx::PLATFORM == 'WXMSW'
          if Wx.has_feature?(:USE_GRAPHICS_GDIPLUS)
            menuFile.append_radio_item(
              ID::File_GC_GDIPlus, "Use &GDI+\t#{accel += 1}")
          end
          if Wx.has_feature?(:USE_GRAPHICS_DIRECT2D)
            menuFile.append_radio_item(
              ID::File_GC_Direct2D, "Use &Direct2D\t#{accel += 1}")
          end
        end # WXMSW
      end # USE_GRAPHICS_CONTEXT
      menuFile.append_separator
      menuFile.append_check_item(ID::File_BBox, "Show bounding box\tCtrl-E",
                                'Show extents used in drawing operations')
      menuFile.append_check_item(ID::File_Clip, "&Clip\tCtrl-C", 'Clip/unclip drawing')
      menuFile.append_check_item(ID::File_Buffer, "&Use wx&BufferedPaintDC\tCtrl-Z", 'Buffer painting')
      if Wx.has_feature?(:USE_GRAPHICS_CONTEXT)
        menuFile.append_check_item(ID::File_AntiAliasing,
                                "&Anti-Aliasing in wxGraphicContext\tCtrl-Shift-A",
                                'Enable Anti-Aliasing in wxGraphicContext')
                .check
      end
      menuFile.append_separator
      menuFile.append(ID::File_Copy, "Copy to clipboard")
      menuFile.append(ID::File_Save, "&Save...\tCtrl-S", 'Save drawing to file')
      menuFile.append_separator
      menuFile.append(ID::File_About, "&About\tCtrl-A", 'Show about dialog')
      menuFile.append_separator
      menuFile.append(ID::File_Quit, "E&xit\tAlt-X", 'Quit this program')

      menuMapMode = Wx::Menu.new
      menuMapMode.append(ID::MapMode_Text, "&TEXT map mode" )
      menuMapMode.append(ID::MapMode_Lometric, "&LOMETRIC map mode" )
      menuMapMode.append(ID::MapMode_Twips, "T&WIPS map mode" )
      menuMapMode.append(ID::MapMode_Points, "&POINTS map mode" )
      menuMapMode.append(ID::MapMode_Metric, "&METRIC map mode" )

      menuUserScale = Wx::Menu.new
      menuUserScale.append(ID::UserScale_StretchHoriz, "Stretch &horizontally\tCtrl-H")
      menuUserScale.append(ID::UserScale_ShrinkHoriz, "Shrin&k horizontally\tCtrl-G")
      menuUserScale.append(ID::UserScale_StretchVertic, "Stretch &vertically\tCtrl-V")
      menuUserScale.append(ID::UserScale_ShrinkVertic, "&Shrink vertically\tCtrl-W")
      menuUserScale.append_separator
      menuUserScale.append(ID::UserScale_Restore, "&Restore to normal\tCtrl-0")

      menuAxis = Wx::Menu.new
      menuAxis.append_check_item(ID::AxisMirror_Horiz, "Mirror horizontally\tCtrl-M")
      menuAxis.append_check_item(ID::AxisMirror_Vertic, "Mirror vertically\tCtrl-N")

      menuLogical = Wx::Menu.new
      menuLogical.append(ID::LogicalOrigin_MoveDown, "Move &down\tCtrl-D")
      menuLogical.append(ID::LogicalOrigin_MoveUp, "Move &up\tCtrl-U")
      menuLogical.append(ID::LogicalOrigin_MoveLeft, "Move &right\tCtrl-L")
      menuLogical.append(ID::LogicalOrigin_MoveRight, "Move &left\tCtrl-R")
      menuLogical.append_separator
      menuLogical.append(ID::LogicalOrigin_Set, "Set to (&100, 100)\tShift-Ctrl-1")
      menuLogical.append(ID::LogicalOrigin_Restore, "&Restore to normal\tShift-Ctrl-0")

      if Wx.has_feature?(:USE_DC_TRANSFORM_MATRIX)
        menuTransformMatrix = Wx::Menu.new
        menuTransformMatrix.append(ID::TransformMatrix_Set, "Set &transformation matrix")
        menuTransformMatrix.append_separator
        menuTransformMatrix.append(ID::TransformMatrix_Reset, "Restore to &normal")
      end # USE_DC_TRANSFORM_MATRIX

      menuColour = Wx::Menu.new
      if Wx.has_feature?(:USE_COLOURDLG)
        menuColour.append(ID::Colour_TextForeground, "Text &foreground...")
        menuColour.append(ID::Colour_TextBackground, "Text &background...")
        menuColour.append(ID::Colour_Background, "Background &colour...")
      end # USE_COLOURDLG
      menuColour.append_check_item(ID::Colour_BackgroundMode, "&Opaque/transparent\tCtrl-B")
      menuColour.append_check_item(ID::Colour_TextureBackground, "Draw textured back&ground\tCtrl-T")

      # now append the freshly created menu to the menu bar...
      menuBar = Wx::MenuBar.new
      menuBar.append(menuFile, "&Drawing")
      menuBar.append(menuScreen, "Scree&n")
      menuBar.append(menuMapMode, "&Mode")
      menuBar.append(menuUserScale, "&Scale")
      menuBar.append(menuAxis, "&Axis")
      menuBar.append(menuLogical, "&Origin")
      if Wx.has_feature?(:USE_DC_TRANSFORM_MATRIX)
        menuBar.append(menuTransformMatrix, "&Transformation")
      end # USE_DC_TRANSFORM_MATRIX
      menuBar.append(menuColour, "&Colours")

      # ... and attach this menu bar to the frame
      set_menu_bar(menuBar)

      if Wx.has_feature?(:USE_STATUSBAR)
        create_status_bar(2)
        set_status_text("Welcome to wxRuby3!")
      end # USE_STATUSBAR

      # connect event handlers
      evt_menu(ID::File_Quit, :on_quit)
      evt_menu(ID::File_About, :on_about)
      evt_menu(ID::File_Clip, :on_clip)

      if Wx.has_feature?(:USE_GRAPHICS_CONTEXT)
        evt_menu(ID::File_GC_Default, :on_graphic_context_default)
        evt_menu(ID::File_DC, :on_graphic_context_none)
        if Wx.has_feature?(:USE_CAIRO)
          evt_menu(ID::File_GC_Cairo, :on_graphic_context_cairo)
        end # USE_CAIRO
        if Wx::PLATFORM == 'WXMSW'
          if Wx.has_feature?(:USE_GRAPHICS_GDIPLUS)
            evt_menu(ID::File_GC_GDIPlus, :on_graphic_context_gdi_plus)
          end
          if Wx.has_feature?(:USE_GRAPHICS_DIRECT2D)
            evt_menu(ID::File_GC_Direct2D, :on_graphic_context_direct2d)
          end
        end # WXMSW
        evt_menu(ID::File_AntiAliasing, :on_anti_aliasing)
        evt_update_ui(ID::File_AntiAliasing, :on_anti_aliasing_update_ui)
      end # USE_GRAPHICS_CONTEXT

      evt_menu(ID::File_Buffer, :on_buffer)
      evt_menu(ID::File_Copy, :on_copy)
      evt_menu(ID::File_Save, :on_save)
      evt_menu(ID::File_BBox, :on_bounding_box)
      evt_update_ui(ID::File_BBox, :on_bounding_box_update_ui)

      evt_menu_range(ID::MenuShow_First, ID::MenuShow_Last, :on_show)

      evt_menu_range(ID::MenuOption_First, ID::MenuOption_Last, :on_option)

      @canvas.set_scrollbars(10, 10, 100, 240)

      set_size(from_dip([800, 700]))
      center(Wx::BOTH)
    end

    attr_reader :backgroundMode
    attr_reader :textureBackground
    attr_reader :mapMode
    attr_reader :xUserScale
    attr_reader :yUserScale
    attr_reader :xLogicalOrigin
    attr_reader :yLogicalOrigin
    attr_reader :xAxisReversed
    attr_reader :yAxisReversed
    attr_reader :transform_dx
    attr_reader :transform_dy
    attr_reader :transform_scx
    attr_reader :transform_scy
    attr_reader :transform_rot
    attr_reader :colourForeground
    attr_reader :colourBackground
    attr_reader :backgroundBrush
    attr_reader :canvas
    attr_reader :menuItemUseDC
    
    # event handlers (these functions should _not_ be virtual)
    def on_quit(_event)
      # true is to force the frame to close
      close(true)
    end

    def on_about(_event)
      msg = "This is the about dialog of the drawing sample.\n" \
            "This sample tests various primitive drawing functions\n" \
            "(without any attempts to prevent flicker).\n" \
            "Copyright (c) Martin Corino (adapted for wxRuby3; original Robert Roebling 1999)"

      Wx.message_box(msg, "About Drawing", Wx::OK | Wx::ICON_INFORMATION, self)
    end

    def on_clip(event)
      @canvas.clip(event.checked?)
    end

    if Wx.has_feature?(:USE_GRAPHICS_CONTEXT)
      def on_graphic_context_none(_event)
        @canvas.use_graphic_renderer(nil)
      end

      def on_graphic_context_default(_event)
        @canvas.use_graphic_renderer(Wx::GraphicsRenderer.get_default_renderer)
      end

      if Wx.has_feature?(:USE_CAIRO)
        def on_graphic_context_cairo(_event)
          @canvas.use_graphic_renderer(Wx::GraphicsRenderer.get_cairo_renderer)
        end
      end # USE_CAIRO

      if Wx::PLATFORM == 'WXMSW'
        if Wx.has_feature?(:USE_GRAPHICS_GDIPLUS)
          def on_graphic_context_gdi_plus(_event)
            @canvas.use_graphic_renderer(Wx::GraphicsRenderer.get_gdi_plus_renderer)
          end
        end

        if Wx.has_feature?(:USE_GRAPHICS_DIRECT2D)
          def on_graphic_context_direct2d(_event)
            @canvas.use_graphic_renderer(Wx::GraphicsRenderer.get_direct2d_renderer)
          end
        end
      end # WXMSW

      def on_anti_aliasing(event)
        @canvas.enable_anti_aliasing(event.is_checked)
      end

      def on_anti_aliasing_update_ui(event)
        event.enable(!@canvas.get_renderer.nil?)
      end
    end # USE_GRAPHICS_CONTEXT

    def on_buffer(event)
      @canvas.use_buffer(event.checked?)
    end

    def on_copy(_event)
      bitmap = Wx::Bitmap.new
      bitmap.create_with_dip_size(@canvas.get_dip_drawing_size, get_dpi_scale_factor)
      Wx::MemoryDC.draw_on(bitmap) do |mdc|
        mdc.set_background(Wx::WHITE_BRUSH)
        mdc.clear
        @canvas.draw(mdc)
      end
      Wx::Clipboard.open do | clip |
        clip.place Wx::BitmapDataObject.new(bitmap)
      end
    end

    def on_save(_event)
      wildCard = "Bitmap image (*.bmp)|*.bmp*.BMP"
      wildCard << "|PNG image (*.png)|*.png*.PNG" if Wx.has_feature?(:USE_LIBPNG)
      wildCard << "|SVG image (*.svg)|*.svg*.SVG" if Wx.has_feature?(:USE_SVG)
      wildCard << "|PostScript file (*.ps)|*.ps*.PS" if Wx.has_feature?(:USE_POSTSCRIPT)

      Wx.FileDialog(self, "Save as bitmap", '', '', wildCard, Wx::FD_SAVE | Wx::FD_OVERWRITE_PROMPT) do |dlg|
        if dlg.show_modal == Wx::ID_OK
          canvasSize = @canvas.get_dip_drawing_size
          fn = dlg.get_path
          ext = File.extname(fn).downcase
          if Wx.has_feature?(:USE_SVG) && ext == '.svg'
            if Wx.has_feature?(:USE_GRAPHICS_CONTEXT)
              # Graphics screen can only be drawn using GraphicsContext
              if @canvas.get_page == ID::File_ShowGraphics
                Wx.log_message('Graphics screen can not be saved as SVG.')
                return
              end
              tempRenderer = @canvas.get_renderer
              @canvas.use_graphic_renderer(nil)
            end
            Wx::SVGFileDC.draw_on(dlg.path,
                                  canvasSize.width,
                                  canvasSize.height,
                              72.0,
                              'Drawing sample') do |svgdc|
              svgdc.set_bitmap_handler(Wx::SVGBitmapEmbedHandler.new)
              @canvas.draw(svgdc)
            end
            if Wx.has_feature?(:USE_GRAPHICS_CONTEXT)
              @canvas.use_graphic_renderer(tempRenderer)
            end
          elsif Wx.has_feature?(:USE_POSTSCRIPT) && ext == '.ps'
            if Wx.has_feature?(:USE_GRAPHICS_CONTEXT)
              # Graphics screen can only be drawn using wxGraphicsContext
              if @canvas.get_page == ID::File_ShowGraphics
                Wx.log_message('Graphics screen can not be saved as PostScript file.')
                return
              end
              curRenderer = @canvas.get_renderer
              @canvas.use_graphic_renderer(nil)
            end # USE_GRAPHICS_CONTEXT
            printData = Wx::PrintData.new
            printData.set_print_mode(Wx::PRINT_MODE_FILE)
            printData.set_filename(dlg.path)
            printData.set_orientation(Wx::PORTRAIT)
            printData.set_paper_id(Wx::PAPER_A4)
            Wx::PostScriptDC.draw_on(printData) do |psdc|
              # Save current scale factor
              curUserScaleX = @xUserScale
              curUserScaleY = @yUserScale
              # Change the scale temporarily to fit the drawing into the page.
              w, h = psdc.get_size
              sc = [w.to_f / canvasSize.width, h.to_f / canvasSize.height].min
              @xUserScale *= sc
              @yUserScale *= sc
              psdc.start_doc('Drawing sample')
              # Define default font.
              psdc.set_font(Wx::FontInfo.new(10).family(Wx::FONTFAMILY_MODERN))
              psdc.start_page
              @canvas.draw(psdc)
              psdc.end_page
              psdc.end_doc
              # Restore original scale factor
              @xUserScale = curUserScaleX
              @yUserScale = curUserScaleY
            end
            if Wx.has_feature?(:USE_GRAPHICS_CONTEXT)
              @canvas.use_graphic_renderer(curRenderer)
            end # USE_GRAPHICS_CONTEXT
          else
            bmp = Wx::Bitmap.new
            bmp.create_with_dip_size(canvasSize, get_dpi_scale_factor)
            Wx::MemoryDC.draw_on(bmp) do |mdc|
              mdc.set_background(Wx::WHITE_BRUSH)
              mdc.clear
              @canvas.draw(mdc)
            end
            bmp.convert_to_image.save_file(dlg.path)
          end
        end
      end
    end

    def on_show(event)
      show = event.id

      if DRAWING_DC_SUPPORTS_ALPHA || Wx.has_feature?(:USE_GRAPHICS_CONTEXT)
        # Make sure we do use a graphics context when selecting one of the screens
        # requiring it.
        # If DC supports drawing with alpha
        # then GC is necessary only for graphics screen.
        if (DRAWING_DC_SUPPORTS_ALPHA && show == ID::File_ShowGraphics) ||
            # DC doesn't support drawing with alpha
            # so GC is necessary both for alpha and graphics screen.
            (!DRAWING_DC_SUPPORTS_ALPHA && (show == ID::File_ShowAlpha || show == ID::File_ShowGraphics))
          @canvas.use_graphic_renderer(Wx::GraphicsRenderer.get_default_renderer) unless @canvas.has_renderer
          # Disable selecting Wx::DC, if necessary.
          @menuItemUseDC.enable(!@canvas.has_renderer)
        else
          @menuItemUseDC.enable(true)
        end
      end # DRAWING_DC_SUPPORTS_ALPHA || USE_GRAPHICS_CONTEXT
      @canvas.to_show(show)
    end

    def on_option(event)
      case event.id
      when ID::MapMode_Text
        @mapMode = Wx::MM_TEXT
      when ID::MapMode_Lometric
        @mapMode = Wx::MM_LOMETRIC
      when ID::MapMode_Twips
        @mapMode = Wx::MM_TWIPS
      when ID::MapMode_Points
        @mapMode = Wx::MM_POINTS
      when ID::MapMode_Metric
        @mapMode = Wx::MM_METRIC

      when ID::LogicalOrigin_MoveDown
        @yLogicalOrigin += 10
      when ID::LogicalOrigin_MoveUp
        @yLogicalOrigin -= 10
      when ID::LogicalOrigin_MoveLeft
        @xLogicalOrigin += 10
      when ID::LogicalOrigin_MoveRight
        @xLogicalOrigin -= 10
      when ID::LogicalOrigin_Set
        @xLogicalOrigin =
        @yLogicalOrigin = -100
      when ID::LogicalOrigin_Restore
        @xLogicalOrigin =
        @yLogicalOrigin = 0

      when ID::UserScale_StretchHoriz
        @xUserScale *= 1.10
      when ID::UserScale_ShrinkHoriz
        @xUserScale /= 1.10
      when ID::UserScale_StretchVertic
        @yUserScale *= 1.10
      when ID::UserScale_ShrinkVertic
        @yUserScale /= 1.10
      when ID::UserScale_Restore
        @xUserScale =
        @yUserScale = 1.0

      when ID::AxisMirror_Vertic
        @yAxisReversed = !@yAxisReversed
      when ID::AxisMirror_Horiz
        @xAxisReversed = !@xAxisReversed

      when ID::TransformMatrix_Set
        if Wx.has_feature?(:USE_DC_TRANSFORM_MATRIX)
          Drawing.TransformDataDialog(self, @transform_dx, @transform_dy,
              @transform_scx, @transform_scy, @transform_rot) do |dlg|
            if dlg.show_modal == Wx::ID_OK
              @transform_dx, @transform_dy, @transform_scx, @transform_scy, @transform_rot = dlg.get_transformation_data
            end
          end
        end

      when ID::TransformMatrix_Reset
        if Wx.has_feature?(:USE_DC_TRANSFORM_MATRIX)
          @transform_dx = 0.0
          @transform_dy = 0.0
          @transform_scx = 1.0
          @transform_scy = 1.0
          @transform_rot = 0.0
        end

      when ID::Colour_TextForeground
        if Wx.has_feature?(:USE_COLOURDLG)
          @colourForeground = select_colour
        end
      when ID::Colour_TextBackground
        if Wx.has_feature?(:USE_COLOURDLG)
          @colourBackground = select_colour
        end
      when ID::Colour_Background
        if Wx.has_feature?(:USE_COLOURDLG)
          col = select_colour
          @backgroundBrush.set_colour(col) if col.ok?
        end

      when ID::Colour_BackgroundMode
          @backgroundMode = (@backgroundMode == Wx::BRUSHSTYLE_SOLID ?
                               Wx::BRUSHSTYLE_TRANSPARENT : Wx::BRUSHSTYLE_SOLID)

      when ID::Colour_TextureBackground
          @textureBackground = ! @textureBackground

      else
        return
      end
  
      @canvas.refresh
    end

    def on_bounding_box(evt)
      @canvas.show_bounding_box(evt.checked?)
    end

    def on_bounding_box_update_ui(evt)
      if Wx.has_feature?(:USE_GRAPHICS_CONTEXT)
        evt.enable(@canvas.get_page != ID::File_ShowGraphics)
      end
    end

    if Wx.has_feature?(:USE_COLOURDLG)
      def select_colour
        data = Wx::ColourData.new
        Wx.ColourDialog(self, data) do |dialog|
          return dialog.get_colour_data.get_colour if dialog.show_modal == Wx::ID_OK
        end
        Wx::Colour.new
      end
    end # USE_COLOURDLG

    def prepare_dc(dc)
      if Wx.has_feature?(:USE_DC_TRANSFORM_MATRIX)
        if dc.can_use_transform_matrix
          mtx = Wx::AffineMatrix2D.new
          mtx.translate(@transform_dx, @transform_dy)
          mtx.rotate((@transform_rot * Math::PI) / 180)
          mtx.scale(@transform_scx, @transform_scy)
          dc.set_transform_matrix(mtx)
        end
      end # USE_DC_TRANSFORM_MATRIX
      dc.set_logical_origin(dc.from_dip(@xLogicalOrigin), dc.from_dip(@yLogicalOrigin))
      dc.set_axis_orientation(!@xAxisReversed, @yAxisReversed)
      dc.set_user_scale(@xUserScale, @yUserScale)
      dc.set_map_mode(@mapMode)
    end
    
  end


  class MyApp < Wx::App

    def initialize
      super
      @images = {}
    end

    attr_reader :images

    def on_init
      # Create the main application window
      frame = MyFrame.new('Drawing sample')
  
      # Show it
      frame.show(true)
  
      unless load_images
        Wx.log_error('Cannot load one of the bitmap files needed ' \
                     'for this sample from the current or parent ' \
                     'directory, please copy them there.')

        # still continue, the sample can be used without images too if they're
        # missing for whatever reason
      end
  
      true
    end

    def on_exit
      delete_images
    end

    protected

    def load_images
      @images[:bmpNoMask] = Wx.Bitmap(:image)
      @images[:bmpWithMask] = Wx.Bitmap(:image)
      @images[:bmpWithColMask] = Wx.Bitmap(:image)

      @images[:bmpMask] = Wx.Bitmap(:mask)
      @images[:bmpWithMask].set_mask(Wx::Mask.new(@images[:bmpMask], Wx::BLACK))

      @images[:bmpWithColMask].set_mask(Wx::Mask.new(@images[:bmpWithColMask], Wx::WHITE))

      @images[:bmp4] = Wx.Bitmap(:pat4)
      @images[:bmp4_mono] = Wx.Bitmap(:pat4)
      @images[:bmp4_mono].set_mask(Wx::Mask.new(@images[:bmp4_mono], Wx::BLACK))

      @images[:bmp36] = Wx.Bitmap(:pat36)
      @images[:bmp36].set_mask(Wx::Mask.new(@images[:bmp36], Wx::BLACK))
      true
    end

    def delete_images
      @images.clear
    end

  end

end

module DrawingSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby Drawing example.',
      description: 'wxRuby example demonstrating and testing Wx::DC features. Adapted from wxWidgets sample.' }
  end

  def self.run
    execute(__FILE__)
  end

  if $0 == __FILE__
    Drawing::MyApp.run
  end

end
