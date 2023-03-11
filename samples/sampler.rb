###
# wxRuby3 sampler application
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'rbconfig'
require 'wx'

module WxRuby

  module Sample
    RUBY = ENV["RUBY"] || File.join(
      RbConfig::CONFIG["bindir"],
      RbConfig::CONFIG["ruby_install_name"] + RbConfig::CONFIG["EXEEXT"]).
      sub(/.*\s.*/m, '"\&"')

    Description = Struct.new(:file, :summary, :description, :thumbnail, keyword_init: true) do
      def name
        File.basename(self.file, '.*').downcase
      end

      def path
        File.dirname(self.file)
      end

      def image_file
        basename = self[:thumbnail] || "tn_#{self.name}"
        if File.exist?(tn_file = File.join(self.path, "#{basename}_#{Wx::PLATFORM}.png"))
          return tn_file
        elsif File.exist?(tn_file = File.join(self.path, "#{basename}.png"))
          return tn_file
        end
        nil
      end

      def image
        if (img_file = image_file)
          Wx::Bitmap.new(img_file)
        else
          Wx::ArtProvider::get_bitmap(Wx::ART_QUESTION)
        end
      end

      def thumbnail
        if (img_file = image_file)
          img = Wx::Image.new(img_file)
          if (scale = img.height / 50.0) > 1.0
            img = img.copy.rescale((img.width/scale).to_i, (img.height/scale).to_i)
          end
          img.to_bitmap
        else
          Wx::ArtProvider::get_bitmap(Wx::ART_QUESTION)
        end
      end
    end

    class << self

      def samples
        @samples ||= []
      end

      def collect_samples
        Dir[File.join(__dir__, '*')].each do |entry|
          if 'bigdemo' != File.basename(entry) && File.directory?(entry)
            Dir[File.join(entry, '*.rb')].each do |rb|
              # only if this is a file (paranoia check) and contains 'include WxRuby::Sample'
              if File.file?(rb) && File.readlines(rb).any? { |ln| /\s+include\s+WxRuby::Sample/ =~ ln }
                Kernel.eval((
                              <<~__CODE
                                  module #{modulize(File.basename(rb, '.*'))}_SampleLoader 
                                    #{File.read(rb)}
                                  end
                              __CODE
                            ),
                            TOPLEVEL_BINDING, rb, 1)
              end
            end
          end
        end
      end

      def modulize(s)
        s = s.gsub(/[^a-zA-Z0-9_]/, '_')
        s.sub!(/^[a-z\d]*/) { $&.capitalize }
        s.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
        s
      end
      private :modulize

      def run(sample_ix)
        system(RUBY, '-I', File.join(__dir__, '..', 'lib'), samples[sample_ix].describe.file)
      end

    end

    def self.included(mod)
      samples << mod
    end

  end

end

if $0 == __FILE__
module WxRuby

  module ID
    TB_RESTORE = Wx::ID_HIGHEST + 2000
    TB_CLOSE = Wx::ID_HIGHEST + 2001
    TB_CHANGE = Wx::ID_HIGHEST + 2002
    TB_REMOVE = Wx::ID_HIGHEST + 2003

    SAMPLE_ID_MIN = Wx::ID_HIGHEST+6000
    RUN = 1

    def self.index_to_sample_id(sample_ix)
      SAMPLE_ID_MIN+(sample_ix*10)
    end

    def self.id_to_sample_index(sample_id)
      (sample_id - SAMPLE_ID_MIN)/10
    end

    def self.index_to_run_id(sample_ix)
      SAMPLE_ID_MIN+(sample_ix*10)+RUN
    end

    def self.id_is_run_button?(id)
      ((id - SAMPLE_ID_MIN) % 10) == RUN
    end

    def self.run_id_to_sample_index(run_id)
      (run_id - (SAMPLE_ID_MIN + RUN))/10
    end
  end

  class SampleTaskBarIcon < Wx::TaskBarIcon

    def initialize(frame)
      super()

      @frame = frame

      # starting image
      icon = make_icon('wxruby-128x128.png')
      set_icon(icon, 'wxRuby Sampler')

      # events
      evt_taskbar_left_dclick { |evt| on_taskbar_activate(evt) }

      evt_menu(ID::TB_RESTORE) { |evt| on_taskbar_activate(evt) }
      evt_menu(ID::TB_CLOSE) { @frame.close }
    end

    def create_popup_menu
      # Called by the base class when it needs to popup the menu
      #  (the default evt_right_down event).  Create and return
      #  the menu to display.
      menu = Wx::Menu.new
      menu.append(ID::TB_RESTORE, "Restore wxRuby Sampler")
      menu.append(ID::TB_CLOSE, "Close wxRuby Sampler")
      return menu
    end

    def make_icon(imgname)
      # Different platforms have different requirements for the
      #  taskbar icon size
      filename = File.join(__dir__, '..', 'art', imgname)
      img = Wx::Image.new(filename)
      if Wx::PLATFORM == "WXMSW"
        img = img.scale(16, 16)
      elsif Wx::PLATFORM == "WXGTK"
        img = img.scale(22, 22)
      end
      # WXMAC can be any size up to 128x128, so don't scale
      icon = Wx::Icon.new
      icon.copy_from_bitmap(Wx::Bitmap.new(img))
      return icon
    end

    def on_taskbar_activate(evt)
      @frame.iconize(false)
      @frame.show(true)
      @frame.raise
    end
  end

  class SamplerFrame < Wx::Frame

    def initialize(title)
      # The main application frame has no parent (nil)
      super(nil, :title => title, :size => [ 800, 600 ])

      @tbicon = SampleTaskBarIcon.new(self)

      @main_panel = Wx::Panel.new(self, Wx::ID_ANY)
      main_sizer = Wx::VBoxSizer.new
      @scroll_panel = Wx::ScrolledWindow.new(@main_panel, Wx::ID_ANY, :size => [ 600, 400 ], style: Wx::VSCROLL)
      @scroll_panel.set_scroll_rate(15, 15)
      scroll_sizer = Wx::VBoxSizer.new
      @sample_thumbnails = []
      @sample_panes = []
      Sample.samples.each_with_index do |sample, sample_ix|
        sample_desc = sample.describe

        sample_panel = Wx::Panel.new(@scroll_panel, Wx::ID_ANY, style: Wx::SUNKEN_BORDER)
        @sample_panes << (sample_pane = Wx::CollapsiblePane.new(sample_panel, ID.index_to_sample_id(sample_ix), sample_desc.summary))
        pane = sample_pane.pane

        sample_pane_sizer = Wx::HBoxSizer.new
        sample_pane_sizer.add(Wx::StaticBitmap.new(pane, Wx::ID_ANY, sample_desc.image), 0, Wx::ALIGN_TOP)
        sample_pane_ctrl_sizer = Wx::VBoxSizer.new
        sample_pane_ctrl_sizer.add(Wx::StaticText.new(pane, Wx::ID_ANY, sample_desc.description), 0, Wx::ALL, 2)
        sample_pane_ctrl_sizer.add(Wx::StaticLine.new(pane, Wx::ID_ANY, size: [30, 30], style: Wx::LI_HORIZONTAL|Wx::RAISED_BORDER), 0, Wx::EXPAND|Wx::ALL, 2)
        sample_pane_ctrl_sizer.add(Wx::Button.new(pane, ID.index_to_run_id(sample_ix), 'Run sample'), 0, Wx::ALL, 2)
        sample_pane_sizer.add(sample_pane_ctrl_sizer, 0, Wx::EXPAND, 2)
        pane.sizer = sample_pane_sizer

        sample_sizer = Wx::HBoxSizer.new
        sample_sizer.add(sample_pane, 1, Wx::EXPAND, 4)
        @sample_thumbnails << Wx::StaticBitmap.new(sample_panel, Wx::ID_ANY, sample_desc.thumbnail)
        sample_sizer.add(@sample_thumbnails.last, 0, Wx::ALIGN_TOP)
        sample_panel.sizer = sample_sizer
        scroll_sizer.add(sample_panel, 0, Wx::EXPAND, 3)
      end
      @scroll_panel.set_sizer(scroll_sizer)

      main_sizer.add(@scroll_panel, 1, Wx::GROW|Wx::ALL, 4)
      @main_panel.sizer = main_sizer

      @expanded_sample_pane = nil

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
      menu_file.append(Wx::ID_EXIT, "E&xit\tAlt-X", "Quit wxRuby Sampler")
      menu_bar.append(menu_file, "&File")

      # The "help" menu
      menu_help = Wx::Menu.new
      menu_help.append(Wx::ID_ABOUT, "&About...\tF1", "Show about dialog")
      menu_bar.append(menu_help, "&Help")

      # Assign the menubar to this frame
      self.menu_bar = menu_bar

      # Create a status bar at the bottom of the frame
      create_status_bar(2)
      self.status_text = "Welcome to wxRuby Sampler!"

      # Set it up to handle menu events using the relevant methods.
      evt_close :on_close
      evt_iconize :on_iconize

      evt_menu Wx::ID_EXIT, :on_quit
      evt_menu Wx::ID_ABOUT, :on_about

      evt_collapsiblepane_changed Wx::ID_ANY, :on_sample_pane_changed

      evt_button Wx::ID_ANY, :on_run_sample

      @main_panel.layout
    end

    def on_run_sample(_evt)
      if ID.id_is_run_button?(_evt.id)
        sample_ix = ID.run_id_to_sample_index(_evt.id)
        Sample.run(sample_ix)
      end
    end

    def on_sample_pane_changed(_evt)
      sample_ix = ID.id_to_sample_index(_evt.id)
      if _evt.collapsed
        @sample_thumbnails[sample_ix].show
        @expanded_sample_pane = nil
      else
        @sample_thumbnails[sample_ix].hide
        if @expanded_sample_pane
          @sample_thumbnails[@expanded_sample_pane].show
          @sample_panes[@expanded_sample_pane].collapse
        end
        @expanded_sample_pane = sample_ix
      end
      @main_panel.layout
    end

    def on_close(_evt)
      @tbicon.remove_icon
      destroy
    end

    def on_iconize(_evt)
      hide
      _evt.skip
    end

    # End the application; it should finish automatically when the last
    # window is closed.
    def on_quit(_evt)
      close
    end

    # show an 'About' dialog - WxRuby's about_box function will show a
    # platform-native 'About' dialog, but you could also use an ordinary
    # Wx::MessageDialog here.
    def on_about
      Wx::about_box(:name => 'wxRuby Sampler',
                    :version     => Wx::WXRUBY_VERSION,
                    :description => "wxRuby Samples inspection application.",
                    :developers  => ['Martin Corino'] )
    end
  end
end

  Wx::App.run do
    WxRuby::Sample.collect_samples
    if WxRuby::Sample.samples.empty?
      STDERR.puts 'No samples available here.'
      false
    else
      frame = WxRuby::SamplerFrame.new('wxRuby Sampler Application')
      frame.show
    end
  end
end
