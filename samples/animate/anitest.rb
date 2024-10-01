# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Julian Smart

require 'wx'

module AniTest

  # Define a new frame
  class MyFrame < Wx::Frame

    module ID
      include Wx::IDHelper

      PLAY = self.next_id
      SET_NULL_ANIMATION = self.next_id
      SET_INACTIVE_BITMAP = self.next_id
      SET_NO_AUTO_RESIZE = self.next_id
      SET_BGCOLOR = self.next_id
      USE_GENERIC = self.next_id

    end

    def initialize(title)
      super(nil, :title => title, :size => [500, 400], style: Wx::DEFAULT_FRAME_STYLE)

      set_icon(Wx.Icon(:sample, art_path: File.dirname(__dir__)))

      # Make a menubar
      file_menu = Wx::Menu.new

      if Wx.has_feature?(:USE_FILEDLG)
        file_menu.append(Wx::ID_OPEN, "&Open Animation...\tCtrl+O", 'Loads an animation')
      end # USE_FILEDLG
      file_menu.append(Wx::ID_EXIT)

      play_menu = Wx::Menu.new
      play_menu.append(ID::PLAY, "Play\tCtrl+P", "Play the animation")
      play_menu.append(Wx::ID_STOP, "Stop\tCtrl+S", "Stop the animation")
      play_menu.append_separator
      play_menu.append(ID::SET_NULL_ANIMATION, "Set null animation",
                       "Sets the empty animation in the control")
      play_menu.append_check_item(ID::SET_INACTIVE_BITMAP, "Set inactive bitmap",
                                  "Sets an inactive bitmap for the control")
      play_menu.append_check_item(ID::SET_NO_AUTO_RESIZE, "Set no autoresize",
                                  "Tells the control not to resize automatically")
      play_menu.append(ID::SET_BGCOLOR, "Set background colour...",
                       "Sets the background colour of the control")

      if Wx::PLATFORM == 'WXGTK'
        play_menu.append_separator
        play_menu.append_check_item(ID::USE_GENERIC, "Use &generic animation\tCtrl+G",
                                    "Selects whether native or generic version is used")
      end

      help_menu = Wx::Menu.new
      help_menu.append(Wx::ID_ABOUT)

      menu_bar = Wx::MenuBar.new

      menu_bar.append(file_menu, "&File")
      menu_bar.append(play_menu, "&Animation")
      menu_bar.append(help_menu, "&Help")

      # Associate the menu bar with this frame
      set_menu_bar(menu_bar)

      if Wx.has_feature?(:USE_STATUSBAR)
        create_status_bar
      end # USE_STATUSBAR

      # use a Wx::BoxSizer otherwise Wx::Frame will automatically
      # resize the @animation_ctrl to fill its client area on
      # user resizes
      sz = Wx::VBoxSizer.new
      sz.add(Wx::StaticText.new(self, Wx::ID_ANY, "wxAnimationCtrl:"),
             Wx::SizerFlags.new.centre.border)

      @animation_ctrl = Wx::AnimationCtrl.new(self, Wx::ID_ANY)

      if Wx::WXWIDGETS_VERSION >= '3.3.0'
        animations = Wx::AnimationBundle.new

        throbber = Wx::Animation.new(File.join(__dir__, 'throbber.gif'))
        animations.add(throbber) if throbber.ok?

        throbber2x = Wx::Animation.new(File.join(__dir__, 'throbber_2x.gif'))
        animations.add(throbber2x) if throbber2x.ok?

        if animations.ok?
          @animation_ctrl.set_animation(animations)
          @animation_ctrl.play
        end
      elsif @animation_ctrl.load('throbber.gif')
        @animation_ctrl.play
      end

      sz.add(@animation_ctrl, Wx::SizerFlags.new.centre.border)
      set_sizer(sz)

      evt_menu(ID::PLAY, :on_play)
      evt_menu(ID::SET_NULL_ANIMATION, :on_set_null_animation)
      evt_menu(ID::SET_INACTIVE_BITMAP, :on_set_inactive_bitmap)
      evt_menu(ID::SET_NO_AUTO_RESIZE, :on_set_no_auto_resize)
      evt_menu(ID::SET_BGCOLOR, :on_set_bg_color)
      if Wx::PLATFORM == 'WXGTK'
        evt_menu(ID::USE_GENERIC, :on_use_generic)
      end

      evt_menu(Wx::ID_STOP, :on_stop)
      evt_menu(Wx::ID_ABOUT, :on_about)
      evt_menu(Wx::ID_EXIT, :on_quit)
      if Wx.has_feature?(:USE_FILEDLG)
        evt_menu(Wx::ID_OPEN, :on_open)
      end # USE_FILEDLG

      evt_size { self.layout }
      evt_update_ui(Wx::ID_ANY, :on_update_ui)
    end

    def on_about(_event)
      info = Wx::AboutDialogInfo.new
      info.set_name("Wx::AnimationCtrl and Wx::Animation sample")
      info.set_description("This sample program demonstrates the usage of Wx::AnimationCtrl")
      info.set_copyright("(C) 2024 Martin Corino (original (C) 2006 Julian Smart)")

      info.add_developer("Martin Corino")

      Wx.about_box(info, self)
    end

    def on_quit(_event)
      close
    end

    def on_play(_event)
      Wx.log_error('Invalid animation') unless @animation_ctrl.play
    end

    def on_set_null_animation(_event)
      @animation_ctrl.set_animation(Wx::NULL_ANIMATION)
    end

    def on_set_inactive_bitmap(event)
      if event.checked?
        # set a dummy bitmap as the inactive bitmap
        bmp = Wx::ArtProvider.get_bitmap(Wx::ART_MISSING_IMAGE)
        @animation_ctrl.set_inactive_bitmap(bmp)
      else
        @animation_ctrl.set_inactive_bitmap(Wx::NULL_BITMAP)
      end
    end

    def on_set_no_auto_resize(event)
      # recreate the control with the new flag if necessary
      style = Wx::AC_DEFAULT_STYLE | (event.checked? ? Wx::AC_NO_AUTORESIZE : 0)

      recreate_animation(style) if style != @animation_ctrl.get_window_style
    end

    def on_set_bg_color(_event)
      clr = Wx.get_colour_from_user(self, @animation_ctrl.get_background_colour,
                                    'Choose the background colour')

      @animation_ctrl.set_background_colour(clr) if clr.ok?
    end

    def on_stop(_event)
      @animation_ctrl.stop
    end

    if Wx::PLATFORM == 'WXGTK'

      def on_use_generic(_event)
        recreate_animation(@animation_ctrl.get_window_style)
      end

    end

    def on_update_ui(_event)
      get_menu_bar.find_item(Wx::ID_STOP).first.enable(@animation_ctrl.playing?)
      get_menu_bar.find_item(ID::PLAY).first.enable(!@animation_ctrl.playing?)
      get_menu_bar.find_item(ID::SET_NO_AUTO_RESIZE).first.enable(!@animation_ctrl.playing?)
    end

    if Wx.has_feature?(:USE_FILEDLG)

      def on_open(_event)
        Wx.FileDialog(self, "Please choose an animation", '', '', '*.gif;*.ani', Wx::FD_OPEN) do |dialog|
          if dialog.show_modal == Wx::ID_OK
              filename = dialog.get_path

              temp = @animation_ctrl.create_animation
              unless temp.load_file(filename)
                Wx.log_error("Sorry, this animation is not a valid format for Wx::Animation.")
                return
              end

              @animation_ctrl.set_animation(temp)
              @animation_ctrl.play

              get_sizer.layout
          end
        end
      end

    end # USE_FILEDLG

    private

    def recreate_animation(style) 
      # save status of the control before destroying it
  
      # We can't reuse the existing animation if we're switching from native to
      # generic control or vice versa (as indicated by the absence of change in
      # the style, which is the only other reason we can get called). We could
      # save the file name we loaded it from and recreate it, of course, but for
      # now, for simplicity, just start without any animation in this case.
      curr = Wx::Animation.new
      if Wx::PLATFORM == 'WXGTK'
        curr = @animation_ctrl.get_animation if style != @animation_ctrl.get_window_style
      end
  
      inactive = @animation_ctrl.get_inactive_bitmap
      bg = @animation_ctrl.get_background_colour
  
      # destroy & rebuild
      old = @animation_ctrl
  
      if Wx::PLATFORM == 'WXGTK' && get_menu_bar.is_checked(ID::USE_GENERIC)
        @animation_ctrl = Wx::GenericAnimationCtrl.new(self, Wx::ID_ANY, curr, style: style)
      else
        @animation_ctrl = Wx::AnimationCtrl.new(self, Wx::ID_ANY, curr, style: style)
      end
  
      get_sizer.replace(old, @animation_ctrl)

      # load old status in new control
      @animation_ctrl.set_inactive_bitmap(inactive)
      @animation_ctrl.set_background_colour(bg)
  
      get_sizer.layout
    end

  end


  class App < Wx::App

    # this one is called on application startup and is a good place for the app
    # initialization (doing it here and not in the ctor allows to have an error
    # return: if OnInit() returns false, the application terminates)
    def on_init
      # Create the main frame window
      frame = MyFrame.new('Animation Demo')
      frame.show
    end

  end

end

module AniTestSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby AnimationCtrl example.',
      description: <<~__DESC
        A Ruby port of the wxWidgets anitest sample which showcases
        animation controls.
      __DESC
    }
  end

  def self.run
    execute(__FILE__)
  end

  if $0 == __FILE__
    AniTest::App.run
  end

end
