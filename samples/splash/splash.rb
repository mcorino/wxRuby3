#!/usr/bin/env ruby
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'wx'

class MyFrame < Wx::Frame
  def initialize(title)
    # The main application frame has no parent (nil)
    super(nil, :title => title, :size => [ 400, 300 ])

    @isPda = (Wx::SystemSettings.get_screen_type <= Wx::SYS_SCREEN_PDA)

    # Give the frame an icon. PNG is a good choice of format for
    # cross-platform images. Note that OS X doesn't have "Frame" icons.
    icon_file = File.join(__dir__,'..', 'art', "wxruby.png")
    self.icon = Wx::Icon.new(icon_file)

    menu_bar = Wx::MenuBar.new
    # The "file" menu
    menu_file = Wx::Menu.new
    # Using Wx::ID_EXIT standard id means the menu item will be given
    # the right label for the platform and language, and placed in the
    # correct platform-specific menu - eg on OS X, in the Application's menu
    menu_file.append(Wx::ID_EXIT, "E&xit\tAlt-X", "Quit this program")
    menu_bar.append(menu_file, "&File")

    # The "help" menu
    menu_help = Wx::Menu.new
    menu_help.append(Wx::ID_ABOUT, "&About...\tF1", "Show about dialog")
    menu_bar.append(menu_help, "&Help")

    # Assign the menubar to this frame
    self.menu_bar = menu_bar

    # Create a status bar at the bottom of the frame
    create_status_bar(2)
    self.status_text = "Welcome to wxRuby!"

    # Set it up to handle menu events using the relevant methods.
    evt_menu Wx::ID_EXIT, :on_quit
    evt_menu Wx::ID_ABOUT, :on_about
  end

  # End the application; it should finish automatically when the last
  # window is closed.
  def on_quit
    close(true)
  end

  def on_about
    bitmap = Wx::Bitmap.new(File.join(__dir__, @isPda ? 'mobile.xpm' : 'splash.png'))

    if bitmap.ok?
      image = bitmap.convert_to_image

      # do not scale on already small screens
      image.rescale(bitmap.width/2, bitmap.height/2) unless @isPda

      bitmap = Wx::Bitmap.new(image)

      splash = Wx::SplashScreen.new(bitmap,
                                    Wx::SPLASH_CENTRE_ON_PARENT | Wx::SPLASH_NO_TIMEOUT,
                          0, self,
                                    style: Wx::SIMPLE_BORDER|Wx::STAY_ON_TOP)

      win = splash.get_splash_window
      text = Wx::StaticText.new(win,
                                id: Wx::ID_EXIT,
                                label: "click somewhere\non this image",
                                pos: [@isPda ? 0 : 13, @isPda ? 0 : 11])
      text.set_background_colour(Wx::WHITE)
      text.set_foreground_colour(Wx::BLACK)
      font = text.font
      font.set_fractional_point_size(2.0*font.get_fractional_point_size/3.0)
      text.font = font
    end
  end

end

class SplashApp < Wx::App

  def on_init
    # create the main application window
    frame = MyFrame.new('Wx::SplashScreen sample application')

    bitmap = Wx::Bitmap.new(File.join(__dir__, @isPda ? 'mobile.xpm' : 'splash.png'))

    if bitmap.ok?
      # we can even draw dynamic artwork onto our splashscreen
      decorate_splash_screen(bitmap)

      # show the splashscreen
      Wx::SplashScreen.new(bitmap,
                           Wx::SPLASH_CENTRE_ON_SCREEN|Wx::SPLASH_TIMEOUT,
                 6000, frame,
                           style: Wx::SIMPLE_BORDER|Wx::STAY_ON_TOP)
    end

    self.yield

    # and show it (the frames, unlike simple controls, are not shown when
    # created initially)
    frame.show(true)

    # success: the app will enter the main message
    # loop and the application will run. If we returned false here, the
    # application would exit immediately.
    true
  end

  def decorate_splash_screen(bmp)
    # use a memory DC to draw directly onto the bitmap
    bmp.draw do |memDc|
      # draw an orange box (with black outline) at the bottom of the splashscreen.
      # this box will be 8% of the height of the bitmap, and be at the bottom.
      bannerRect = Wx::Rect.new(Wx::Point.new(0, ((bmp.height / 10)*9.2).to_i),
                                Wx::Point.new(bmp.width, bmp.height))
      memDc.with_brush Wx::Brush.new(Wx::Colour.new(255, 102, 0)) do
        memDc.draw_rectangle(bannerRect)
        memDc.draw_line(bannerRect.top_left, bannerRect.top_right)

        # dynamically get the wxWidgets version to display
        description = "wxRuby %s" % Wx::WXRUBY_VERSION
        # create a copyright notice that uses the year that this file is run
        copyrightLabel = "%s%s wxWidgets. %s" % ["\xc2\xa9", Time.now.year.to_s, "All rights reserved."]

        # draw the (white) labels inside of our orange box (at the bottom of the splashscreen)
        memDc.set_text_foreground(Wx::WHITE)
        # draw the "wxRuby" label on the left side, vertically centered.
        # note that we deflate the banner rect a little bit horizontally
        # so that the text has some padding to its left.
        labelRect = bannerRect.deflate([5, 0])
        memDc.draw_label(description, labelRect, Wx::ALIGN_CENTRE_VERTICAL | Wx::ALIGN_LEFT)

        # draw the copyright label on the right side
        memDc.font = Wx::Font.new(Wx::FontInfo.new(8))
        memDc.draw_label(copyrightLabel, labelRect, Wx::ALIGN_CENTRE_VERTICAL | Wx::ALIGN_RIGHT)
      end
    end
  end

end

module SplashSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby SplashScreen example.',
      description: 'wxRuby example showcasing Wx::SplashScreen.' }
  end

  def self.run
    execute(__FILE__)
  end

  if $0 == __FILE__
    SplashApp.run
  end

end
