###
# wxRuby3 sampler application
# Copyright (c) M.J.N. Corino, The Netherlands
###

require 'rbconfig'
require 'fileutils'
require 'wx'

require_relative 'sampler/editor'

class ::String

  def modulize!
    self.gsub!(/[^a-zA-Z0-9_]/, '_')
    self.sub!(/^[a-z\d]*/) { $&.capitalize }
    self.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
    self
  end

  def modulize
    self.dup.modulize!
  end
end

# Hack to make the sample loader modules behave like the normal 'toplevel' binding
# otherwise samples using 'include Wx' (or other modules) will fail on referencing
# a constant unscoped from one of these included modules
class ::Module
  def const_missing(sym)
    if self.name.start_with?('WxRuby::Sample::SampleLoader_') && (scope = self.name.split('::')).size > 3
      top_mod = Object.const_get(scope[0,3].join('::'))
      return top_mod.const_get(sym)
    end
    begin
      super
    rescue NoMethodError
      raise NameError, "uninitialized constant #{sym}"
    end
  end
end

# Hack to make the sample loader modules behave like the normal 'toplevel' binding
# otherwise samples using 'include Wx' (or other modules) will fail on referencing
# a (module) method unscoped from one of these included modules
module ::Kernel
  def method_missing(name, *args)
    if self.class.name.start_with?('WxRuby::Sample::SampleLoader_') && (scope = self.class.name.split('::')).size > 3
      top_mod = Object.const_get(scope[0,3].join('::'))
      return top_mod.__send__(name, *args) if top_mod.respond_to?(name)
      top_mod.included_modules.each do |imod|
        return imod.__send__(name, *args) if imod.respond_to?(name)
      end
    end
    super
  end
end

module WxRuby

  ART_FOLDER = File.join(__dir__, 'art')

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

      def category
        File.basename(path).modulize!
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
          img = Wx::Image.new(img_file)
          scale = 320.0 / img.height
          img = img.copy.rescale((img.width*scale).to_i, (img.height*scale).to_i)
          img.to_bitmap
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

    class SampleEntry
      def initialize(mod, newfiles)
        @module = mod
        @runner = nil
        @description = nil
        # filter new required files; keep only .rb from sample path
        @files = newfiles.select { |fp| File.extname(fp) == '.rb' && fp.start_with?(path) }
      end

      attr_reader :files

      def description
        @description ||= Description.new(**@module.describe)
      end

      def file
        description.file
      end

      def path
        description.path
      end

      def category
        description.category
      end

      def summary
        description.summary
      end

      def run
        @runner = @module.run
      end

      def close
        @runner.close if @runner
        @runner = nil
      end

      def close_window(win)
        if EmbeddedRunner === @runner && @runner.frame == win
          @runner.frame = nil
        end
      end

      class Copy < SampleEntry
        def initialize(desc, files)
          super(nil, [])
          @description = desc
          @files = files
        end

        def run
          @runner = SpawnedRunner.new(::Process.spawn(RUBY, '-I', File.join(__dir__, '..', 'lib'), description.file))
        end
      end

      def copy_to(dest)
        # create description clone
        desc_clone = description.dup
        # create sample folder at dest
        sample_folder = File.join(dest, File.basename(path))
        FileUtils.mkdir_p(sample_folder)
        # copy main file
        desc_clone.file = File.join(sample_folder, File.basename(file))
        FileUtils.cp(file, desc_clone.file)
        # copy required files
        files_copy = []
        files.each do |f|
          files_copy << File.join(sample_folder, File.basename(f))
          FileUtils.cp(f, files_copy.last)
        end
        # copy thumbnail image file if any
        if description.image_file
          desc_clone[:thumbnail] = File.join(sample_folder, File.basename(description.image_file))
          FileUtils.cp(description.image_file, desc_clone[:thumbnail])
        end
        # copy sample specific resources (not .rb or 'tn_*.png' files and not directories)
        Dir[File.join(path, '*')].each do |fp|
          unless File.directory?(fp) || File.extname(fp) == '.rb' || /\Atn_.*\.png\Z/ =~ File.basename(fp)
            FileUtils.cp(fp, File.join(sample_folder, File.basename(fp)))
          end
        end
        # copy art folder to dest
        art_dest = File.join(dest, 'art')
        FileUtils.mkdir_p(art_dest)
        Dir[File.join(ART_FOLDER, '*')].each do |fp|
          FileUtils.cp(fp, File.join(art_dest, File.basename(fp)))
        end
        # copy sample.xpm
        FileUtils.cp(File.join(__dir__, 'sample.xpm'), File.join(dest, 'sample.xpm'))
        # copy and return SampleEntry::Copy
        Copy.new(desc_clone, files_copy)
      end

      class EmbeddedRunner
        def initialize(frame)
          @frame = frame
        end
        attr_accessor :frame
        def close
          @frame.close(true) if @frame
        end
      end

      class SpawnedRunner
        def initialize(pid)
          @pid = pid
        end

        def check_status
          begin
            tmp, status = ::Process.waitpid2(@pid, ::Process::WNOHANG)
            if tmp==@pid and status.success? == false
              return false
            end
            return true
          rescue Errno::ECHILD, Errno::ESRCH
            return false
          end
        end
        private :check_status

        def close
          if check_status
            ::Process.kill('SIGKILL', @pid) rescue Errno::ESRCH
            10.times do
              sleep(0.1)
              return unless check_status
            end
            ::Process.kill('SIGKILL', @pid) if check_status
          end
        end
      end
    end

    class << self

      def loading_sample
        @loading_sample
      end

      def samples
        @samples ||= []
      end

      def categories
        @categories ||= {}
      end

      def category_samples(cat)
        categories[cat] ||= []
      end

      def sample_captures
        @captures ||= []
      end
      private :sample_captures

      def collect_samples
        Dir[File.join(__dir__, '*')].each do |entry|
          if File.directory?(entry)
            category = File.basename(entry)
            unless 'bigdemo' ==  category || 'sampler' == category
              category.modulize!
              Dir[File.join(entry, '*.rb')].each do |rb|
                # only if this is a file (paranoia check) and contains 'include WxRuby::Sample'
                if File.file?(rb) && (sample_lns = File.readlines(rb)).any? { |ln| /\s+include\s+WxRuby::Sample/ =~ ln }
                  # register currently required files
                  cur_loaded = ::Set.new($LOADED_FEATURES)
                  @loading_sample = rb
                  # cannot use (Kernel#load with) an anonymous module because that will break the Wx::Dialog functor
                  # functionality for one thing (that code will attempt to define a module method for a new dialog class
                  # in the class/module scope in which the dialog class is defined working from the dialog class name;
                  # this will fail for anonymous modules as these cannot be identified by name)
                  sample_mod = Sample.const_set("SampleLoader_#{File.basename(rb, '.*').modulize!}", Module.new)
                  sample_mod.module_eval File.read(rb), rb, 1
                  # determine additionally required files
                  new_loaded = ::Set.new($LOADED_FEATURES) - cur_loaded
                  sample_captures.each do |mod|
                    samples << (smpl = SampleEntry.new(mod, new_loaded))
                    category_samples(smpl.category) << (samples.size-1)
                  end
                  sample_captures.clear
                  @loading_sample = nil
                end
              end
            end
          end
        end
      end

    end

    module SampleMethods
      def activate
        raise NotImplementedError, '#activate needs an override'
      end

      def run
        SampleEntry::EmbeddedRunner.new(activate)
      end

      def execute(sample_file)
        SampleEntry::SpawnedRunner.new(::Process.spawn(RUBY, '-I', File.join(__dir__, '..', 'lib'), sample_file))
      end
      private :execute
    end

    def self.included(mod)
      mod.extend SampleMethods
      sample_captures << mod
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

    CATEGORY_ID_MIN = Wx::ID_HIGHEST+4000

    SAMPLE_ID_MIN = Wx::ID_HIGHEST+6000
    RUN = 1
    EDIT = 2

    def self.index_to_sample_id(sample_ix)
      SAMPLE_ID_MIN+(sample_ix*10)
    end

    def self.id_to_sample_index(sample_id)
      (sample_id - SAMPLE_ID_MIN)/10
    end

    def self.index_to_run_id(sample_ix)
      SAMPLE_ID_MIN+(sample_ix*10)+RUN
    end

    def self.index_to_edit_id(sample_ix)
      SAMPLE_ID_MIN+(sample_ix*10)+EDIT
    end

    def self.id_is_run_button?(id)
      ((id - SAMPLE_ID_MIN) % 10) == RUN
    end

    def self.id_is_edit_button?(id)
      ((id - SAMPLE_ID_MIN) % 10) == EDIT
    end

    def self.run_id_to_sample_index(run_id)
      (run_id - (SAMPLE_ID_MIN + RUN))/10
    end

    def self.edit_id_to_sample_index(run_id)
      (run_id - (SAMPLE_ID_MIN + EDIT))/10
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
      filename = File.join(__dir__, 'art', imgname)
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
      frameSize = Wx::Size.new([850, (Wx::SystemSettings.get_metric(Wx::SYS_SCREEN_X) / 4)].max,
                               (Wx::SystemSettings.get_metric(Wx::SYS_SCREEN_Y) / 2))
      framePos = Wx::Point.new(Wx::SystemSettings.get_metric(Wx::SYS_SCREEN_X) / 20,
                               Wx::SystemSettings.get_metric(Wx::SYS_SCREEN_Y) / 4)
      # The main application frame has no parent (nil)
      super(nil, :title => title, :size => frameSize, pos: framePos)

      # Give the frame an icon. PNG is a good choice of format for
      # cross-platform images. Note that OS X doesn't have "Frame" icons.
      icon_file = File.join(__dir__, 'art', "wxruby.png")
      self.icon = Wx::Icon.new(icon_file)

      @tbicon = SampleTaskBarIcon.new(self)

      @main_panel = Wx::Panel.new(self, Wx::ID_ANY)
      main_sizer = Wx::VBoxSizer.new
      @scroll_panel = Wx::ScrolledWindow.new(@main_panel, Wx::ID_ANY, :size => [ 600, 400 ], style: Wx::VSCROLL)
      @scroll_panel.set_scroll_rate(15, 15)
      scroll_sizer = Wx::VBoxSizer.new
      @category_panes = []
      @category_thumbnails = []
      @sample_thumbnails = []
      @sample_panes = []
      @scroll_panel.set_sizer(scroll_sizer)

      @startup_panel = Wx::Panel.new(@main_panel)
      @startup_panel.background_colour = Wx::LIGHT_GREY
      startup_sizer = Wx::VBoxSizer.new
      startup_sizer.add(Wx::StaticBitmap.new(@startup_panel,Wx::ID_ANY, Wx::Bitmap.new(icon_file)),
                        0, Wx::TOP|Wx::ALIGN_CENTER, 100)
      txt = Wx::StaticText.new(@startup_panel, Wx::ID_ANY, 'wxRuby Sampler Starting')
      txt.own_font = Wx::Font.new(20, Wx::FontFamily::FONTFAMILY_ROMAN, Wx::FONTSTYLE_NORMAL, Wx::FONTWEIGHT_BOLD)
      txt.font.set_weight(Wx::FontWeight::FONTWEIGHT_BOLD)
      startup_sizer.add(txt,  0, Wx::ALL|Wx::ALIGN_CENTER, 30)
      txt = Wx::StaticText.new(@startup_panel, Wx::ID_ANY, 'Loading samples, please wait...')
      startup_sizer.add(txt,  0, Wx::ALL|Wx::ALIGN_CENTER, 10)
      @startup_panel.sizer = startup_sizer
      main_sizer.add(@startup_panel, 1, Wx::EXPAND, 0)

      # main_sizer.add(@scroll_panel, 1, Wx::GROW|Wx::ALL, 4)
      @main_panel.sizer = main_sizer

      @expanded_sample = nil
      @expanded_category = nil
      @running_sample = nil
      @sample_editor = nil

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

      evt_button Wx::ID_ANY, :on_sample_button

      @main_panel.layout
    end

    attr_reader :running_sample
    attr_accessor :sample_editor

    def load_samples
      @main_panel.sizer.remove(0)
      @startup_panel.destroy
      @startup_panel = nil
      Sample.categories.keys.each_with_index { |cat, cat_ix| create_category_pane(@scroll_panel.sizer, cat, cat_ix) }
      @main_panel.sizer.add(@scroll_panel, 1, Wx::GROW|Wx::ALL, 4)
      @main_panel.layout
    end

    def create_category_pane(scroll_sizer, cat, cat_ix)
      category_panel = Wx::Panel.new(@scroll_panel, Wx::ID_ANY, style: Wx::RAISED_BORDER)
      @category_panes << (category_pane = Wx::CollapsiblePane.new(category_panel, ID::CATEGORY_ID_MIN+cat_ix, "#{cat} samples"))
      category_pane_win = category_pane.pane
      category_pane_sizer = Wx::VBoxSizer.new

      Sample.category_samples(cat).each do |sample_ix|
        sample = Sample.samples[sample_ix]
        sample_desc = sample.description

        sample_panel = Wx::Panel.new(category_pane_win, Wx::ID_ANY, style: Wx::SUNKEN_BORDER)
        @sample_panes << (sample_pane = Wx::CollapsiblePane.new(sample_panel, ID.index_to_sample_id(sample_ix), sample_desc.summary))
        pane = sample_pane.pane

        sample_pane_sizer = Wx::HBoxSizer.new
        sample_pane_sizer.add(Wx::StaticBitmap.new(pane, Wx::ID_ANY, sample_desc.image), 0, Wx::ALIGN_TOP)
        sample_pane_ctrl_sizer = Wx::VBoxSizer.new
        sample_buttons_sizer = Wx::HBoxSizer.new
        sample_buttons_sizer.add(Wx::Button.new(pane, ID.index_to_run_id(sample_ix), 'Run sample'), 0, Wx::ALL, 2)
        sample_buttons_sizer.add(Wx::Button.new(pane, ID.index_to_edit_id(sample_ix), 'Inspect sample'), 0, Wx::ALL, 2)
        sample_pane_ctrl_sizer.add(sample_buttons_sizer, 0, Wx::ALL, 0)
        sample_pane_ctrl_sizer.add(Wx::StaticLine.new(pane, Wx::ID_ANY, size: [30, 30], style: Wx::LI_HORIZONTAL|Wx::RAISED_BORDER), 0, Wx::EXPAND|Wx::ALL, 2)
        desc = Wx::TextCtrl.new(pane, Wx::ID_ANY, sample_desc.description, style: Wx::TE_MULTILINE|Wx::TE_READONLY|Wx::BORDER_NONE)
        desc.background_colour = background_colour
        sample_pane_ctrl_sizer.add(desc, 1, Wx::EXPAND|Wx::ALL, 2)
        sample_pane_sizer.add(sample_pane_ctrl_sizer, 1, Wx::EXPAND, 2)
        pane.sizer = sample_pane_sizer
        sample_pane_sizer.set_size_hints(pane)

        sample_sizer = Wx::HBoxSizer.new
        sample_sizer.add(sample_pane, 1, Wx::EXPAND|Wx::ALL, 4)
        @sample_thumbnails << Wx::StaticBitmap.new(sample_panel, Wx::ID_ANY, sample_desc.thumbnail)
        sample_sizer.add(@sample_thumbnails.last, 0, Wx::ALIGN_TOP)
        sample_panel.sizer = sample_sizer
        category_pane_sizer.add(sample_panel, 0, Wx::EXPAND|Wx::ALL, 3)
      end

      category_pane_win.sizer = category_pane_sizer
      category_pane_sizer.set_size_hints(category_pane_win)

      category_sizer = Wx::HBoxSizer.new
      @category_thumbnails << Wx::StaticBitmap.new(category_panel, Wx::ID_ANY, Wx::ArtProvider::get_bitmap(Wx::ART_FOLDER, Wx::ART_OTHER, [32,32]))
      category_sizer.add(category_pane, 1, Wx::EXPAND|Wx::ALL, 2)
      category_sizer.add(@category_thumbnails.last, 0, Wx::ALIGN_TOP)
      category_panel.sizer = category_sizer

      scroll_sizer.add(category_panel, 0, Wx::EXPAND|Wx::ALL, 3)
    end

    def run_sample(sample)
      @running_sample.close if @running_sample
      @running_sample = sample
      @running_sample.run
    end

    def on_sample_button(_evt)
      if ID.id_is_run_button?(_evt.id)
        run_sample(Sample.samples[ID.run_id_to_sample_index(_evt.id)])
      elsif ID.id_is_edit_button?(_evt.id)
        @sample_editor.destroy if @sample_editor
        sample_ix = ID.edit_id_to_sample_index(_evt.id)
        sample = Sample.samples[sample_ix]
        @sample_editor = SampleEditor.new(self, sample)
        @sample_editor.show
      end
    end

    def on_sample_pane_changed(_evt)
      if _evt.id < ID::SAMPLE_ID_MIN
        cat_ix = _evt.id - ID::CATEGORY_ID_MIN
        if @expanded_sample
          @sample_thumbnails[@expanded_sample].show
          @sample_panes[@expanded_sample].collapse
          @expanded_sample = nil
        end
        if _evt.collapsed
          @category_thumbnails[cat_ix].show
          @expanded_category = nil
        else
          @category_thumbnails[cat_ix].hide
          if @expanded_category
            @category_thumbnails[@expanded_category].show
            @category_panes[@expanded_category].collapse
          end
          @expanded_category = cat_ix
        end
      else
        sample_ix = ID.id_to_sample_index(_evt.id)
        if _evt.collapsed
          @sample_thumbnails[sample_ix].show
          @expanded_sample = nil
        else
          @sample_thumbnails[sample_ix].hide
          if @expanded_sample
            @sample_thumbnails[@expanded_sample].show
            @sample_panes[@expanded_sample].collapse
          end
          @expanded_sample = sample_ix
        end
      end
      @main_panel.layout
    end

    def on_close(_evt)
      @running_sample.close if @running_sample
      @sample_editor.destroy if @sample_editor
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
  self.set_app_name('wxRuby Sampler')

  @frame = nil

  evt_window_destroy do |evt|
    unless @frame.nil? || @frame == evt.window
      if evt.window == @frame.sample_editor
        @frame.sample_editor = nil
      else
        @frame.running_sample.close_window(evt.window) if @frame.running_sample
      end
    end
    evt.skip
  end

  WxRuby::Sample.collect_samples
  if WxRuby::Sample.samples.empty?
    STDERR.puts 'No samples available here.'
    false
  else
    @frame = WxRuby::SamplerFrame.new('wxRuby Sampler Application')
    @frame.show
    self.call_after do
      Wx::WindowDisabler.disable(@frame) do
        @frame.load_samples
      end
      @frame.update
    end
    true
  end
end

end
