# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Adapted for Wx::Ruby3
###

require 'wx'

module Help

  # Define this to false to use the help controller as the help
  # provider, or to true to use the 'simple help provider'
  # (the one implemented with Wx::TipWindow).
  USE_SIMPLE_HELP_PROVIDER = false

  # define this to true to use external help controller (not used by default)
  USE_EXT_HELP = false

  # IDs for the controls and the menu commands
  module ID
    include Wx::IDHelper
    # menu items
    HelpDemo_Quit = self.next_id
    HelpDemo_Help_Index = self.next_id
    HelpDemo_Help_Classes = self.next_id
    HelpDemo_Help_Functions = self.next_id
    HelpDemo_Help_Help = self.next_id
    HelpDemo_Help_Search = self.next_id
    HelpDemo_Help_ContextHelp = self.next_id
    HelpDemo_Help_DialogContextHelp = self.next_id

    HelpDemo_Html_Help_Index = self.next_id
    HelpDemo_Html_Help_Classes = self.next_id
    HelpDemo_Html_Help_Functions = self.next_id
    HelpDemo_Html_Help_Help = self.next_id
    HelpDemo_Html_Help_Search = self.next_id

    HelpDemo_Advanced_Html_Help_Index = self.next_id
    HelpDemo_Advanced_Html_Help_Classes = self.next_id
    HelpDemo_Advanced_Html_Help_Functions = self.next_id
    HelpDemo_Advanced_Html_Help_Help = self.next_id
    HelpDemo_Advanced_Html_Help_Search = self.next_id
    HelpDemo_Advanced_Html_Help_Modal = self.next_id

    HelpDemo_MS_Html_Help_Index = self.next_id
    HelpDemo_MS_Html_Help_Classes = self.next_id
    HelpDemo_MS_Html_Help_Functions = self.next_id
    HelpDemo_MS_Html_Help_Help = self.next_id
    HelpDemo_MS_Html_Help_Search = self.next_id

    HelpDemo_Best_Help_Index = self.next_id
    HelpDemo_Best_Help_Classes = self.next_id
    HelpDemo_Best_Help_Functions = self.next_id
    HelpDemo_Best_Help_Help = self.next_id
    HelpDemo_Best_Help_Search = self.next_id

    HelpDemo_Help_KDE = self.next_id
    HelpDemo_Help_GNOME = self.next_id
    HelpDemo_Help_Netscape = self.next_id
    # controls start here (the numbers are, of course, arbitrary)
    HelpDemo_Text = self.next_id(HelpDemo_Help_Netscape + 999)
  end

  # Define a new frame type: this is going to be our main frame
  class MyFrame < Wx::Frame
    # ctor(s)
    def initialize(title, pos, size)
      super(nil, pos: pos, size: size)

      @help = USE_EXT_HELP ? Wx::ExtHelpController.new : Wx::HelpController.new
      @embeddedHtmlHelp = Wx::HTML::HtmlHelpController.new(Wx::HTML::HF_EMBEDDED|Wx::HTML::HF_DEFAULT_STYLE)
      @advancedHtmlHelp = Wx::HTML::HtmlHelpController.new

      # set the frame icon
      self.icon = Wx.Icon(:sample, Wx::BITMAP_TYPE_XPM, art_path: File.join(__dir__, '..'))
  
      # create a menu bar
      menuFile = Wx::Menu.new
  
      menuFile.append(ID::HelpDemo_Help_Index, "&Help Index...")
      menuFile.append(ID::HelpDemo_Help_Classes, "&Help on Classes...")
      menuFile.append(ID::HelpDemo_Help_Functions, "&Help on Functions...")
      menuFile.append(ID::HelpDemo_Help_ContextHelp, "&Context Help...")
      menuFile.append(ID::HelpDemo_Help_DialogContextHelp, "&Dialog Context Help...\tCtrl-H")
      menuFile.append(ID::HelpDemo_Help_Help, "&About Help Demo...")
      menuFile.append(ID::HelpDemo_Help_Search, "&Search help...")
      menuFile.append_separator
      menuFile.append(ID::HelpDemo_Advanced_Html_Help_Index, "Advanced HTML &Help Index...")
      menuFile.append(ID::HelpDemo_Advanced_Html_Help_Classes, "Advanced HTML &Help on Classes...")
      menuFile.append(ID::HelpDemo_Advanced_Html_Help_Functions, "Advanced HTML &Help on Functions...")
      menuFile.append(ID::HelpDemo_Advanced_Html_Help_Help, "Advanced HTML &About Help Demo...")
      menuFile.append(ID::HelpDemo_Advanced_Html_Help_Search, "Advanced HTML &Search help...")
      menuFile.append(ID::HelpDemo_Advanced_Html_Help_Modal, "Advanced HTML Help &Modal Dialog...")

      unless Wx::PLATFORM == 'WXMSW' || !Wx.has_feature?(:USE_HTML)
        menuFile.append_separator
        menuFile.append(ID::HelpDemo_Help_KDE, "Use &KDE")
        menuFile.append(ID::HelpDemo_Help_GNOME, "Use &GNOME")
        menuFile.append(ID::HelpDemo_Help_Netscape, "Use &Netscape")
      end

      menuFile.append_separator
      menuFile.append(ID::HelpDemo_Quit, "E&xit")
  
      # now append the freshly created menu to the menu bar...
      menuBar = Wx::MenuBar.new
      menuBar.append(menuFile, "&File")
  
      # ... and attach this menu bar to the frame
      set_menu_bar(menuBar)
  
      if Wx.has_feature?(:USE_STATUSBAR)
        # create a status bar just for fun (by default with 1 pane only)
        create_status_bar
        set_status_text("Welcome to wxWidgets!")
      end # USE_STATUSBAR
  
      # Create embedded HTML Help window
      @embeddedHelpWindow = Wx::HTML::HtmlHelpWindow.new
      # @embeddedHtmlHelp.use_config(config, rootPath) # Can set your own config object here
      @embeddedHtmlHelp.set_help_window(@embeddedHelpWindow)
  
      @embeddedHelpWindow.create(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, get_client_size, Wx::TAB_TRAVERSAL|Wx::NO_BORDER, Wx::HTML::HF_DEFAULT_STYLE)
  
      @embeddedHtmlHelp.add_book(File.join(__dir__, 'doc.zip'))
      @embeddedHtmlHelp.display("Introduction")

      evt_menu(ID::HelpDemo_Quit,  :on_quit)
      evt_menu(ID::HelpDemo_Help_Index, :on_help)
      evt_menu(ID::HelpDemo_Help_Classes, :on_help)
      evt_menu(ID::HelpDemo_Help_Functions, :on_help)
      evt_menu(ID::HelpDemo_Help_Help, :on_help)
      evt_menu(ID::HelpDemo_Help_Search, :on_help)
      evt_menu(ID::HelpDemo_Help_ContextHelp, :on_show_context_help)
      evt_menu(ID::HelpDemo_Help_DialogContextHelp, :on_show_dialog_context_help)
  
      evt_menu(ID::HelpDemo_Advanced_Html_Help_Index, :on_advanced_html_help)
      evt_menu(ID::HelpDemo_Advanced_Html_Help_Classes, :on_advanced_html_help)
      evt_menu(ID::HelpDemo_Advanced_Html_Help_Functions, :on_advanced_html_help)
      evt_menu(ID::HelpDemo_Advanced_Html_Help_Help, :on_advanced_html_help)
      evt_menu(ID::HelpDemo_Advanced_Html_Help_Search, :on_advanced_html_help)
      evt_menu(ID::HelpDemo_Advanced_Html_Help_Modal, :on_modal_html_help)

      evt_menu(ID::HelpDemo_Help_KDE, :on_help)
      evt_menu(ID::HelpDemo_Help_GNOME, :on_help)
      evt_menu(ID::HelpDemo_Help_Netscape, :on_help)
    end

    def get_help_controller
      @help
    end

    def get_advanced_html_help_controller
      @advancedHtmlHelp
    end

    # event handlers
    def on_quit(_event)
      # true is to force the frame to close
      close(true)
    end

    def on_help(event)
      show_help(event.get_id, @help)
    end

    def on_advanced_html_help(event)
      show_help(event.get_id, @advancedHtmlHelp)
    end

    def on_modal_html_help(_event)
      Wx::HTML.HtmlModalHelp(self, File.join(__dir__, 'doc.zip'), "Introduction")
    end

    def on_show_context_help(_event)
      # This starts context help mode, then the user
      # clicks on a window to send a help message
      Wx::ContextHelp.new(self).end_context_help
    end

    def on_show_dialog_context_help(_event)
      Help::MyModalDialog(self)
    end

    def show_help(commandId, helpController)
      case commandId
      when ID::HelpDemo_Help_Classes,
        ID::HelpDemo_Html_Help_Classes,
        ID::HelpDemo_Advanced_Html_Help_Classes,
        ID::HelpDemo_MS_Html_Help_Classes,
        ID::HelpDemo_Best_Help_Classes
          helpController.display_section(2)
          #helpController.display_section("Classes") # An alternative form for most controllers
    
      when ID::HelpDemo_Help_Functions,
        ID::HelpDemo_Html_Help_Functions,
        ID::HelpDemo_Advanced_Html_Help_Functions,
        ID::HelpDemo_MS_Html_Help_Functions
        helpController.display_section(1)
        #helpController.display_section("Functions") # An alternative form for most controllers
    
      when ID::HelpDemo_Help_Help,
        ID::HelpDemo_Html_Help_Help,
        ID::HelpDemo_Advanced_Html_Help_Help,
        ID::HelpDemo_MS_Html_Help_Help,
        ID::HelpDemo_Best_Help_Help
        helpController.display_section(3)
        #helpController.display_section("About"); # An alternative form for most controllers

      when ID::HelpDemo_Help_Search,
        ID::HelpDemo_Html_Help_Search,
        ID::HelpDemo_Advanced_Html_Help_Search,
        ID::HelpDemo_MS_Html_Help_Search,
        ID::HelpDemo_Best_Help_Search
        key = Wx.get_text_from_user("Search for?",
                                    "Search help for keyword",
                                    '',
                                    self)
        helpController.keyword_search(key) unless key.empty?

      when ID::HelpDemo_Help_Index,
        ID::HelpDemo_Html_Help_Index,
        ID::HelpDemo_Advanced_Html_Help_Index,
        ID::HelpDemo_MS_Html_Help_Index,
        ID::HelpDemo_Best_Help_Index
        helpController.display_contents

       # These three calls are only used by wxExtHelpController

      when ID::HelpDemo_Help_KDE
        helpController.set_viewer("kdehelp")
      when ID::HelpDemo_Help_GNOME
        helpController.set_viewer("gnome-help-browser")
      when ID::HelpDemo_Help_Netscape
        helpController.set_viewer("netscape", Wx::HELP_NETSCAPE)
      else
        #
      end
    end

  end

  # A custom modal dialog
  class MyModalDialog < Wx::Dialog
    def initialize(parent)
      super(parent, Wx::ID_ANY, 'Modal Dialog')

      # Add the context-sensitive help button on the caption for the platforms
      # which support it (currently MSW only)
      set_extra_style(Wx::DIALOG_EX_CONTEXTHELP)
  
  
      sizerTop = Wx::VBoxSizer.new
      sizerRow = Wx::HBoxSizer.new
  
      btnOK = Wx::Button.new(self, Wx::ID_OK, "&OK")
      btnOK.set_help_text("The OK button confirms the dialog choices.")
  
      btnCancel = Wx::Button.new(self, Wx::ID_CANCEL, "&Cancel")
      btnCancel.set_help_text("The Cancel button cancels the dialog.")
  
      sizerRow.add(btnOK, 0, Wx::ALIGN_CENTER | Wx::ALL, 5)
      sizerRow.add(btnCancel, 0, Wx::ALIGN_CENTER | Wx::ALL, 5)
  
      # Add explicit context-sensitive help button for non-MSW
      unless Wx::PLATFORM == 'WXMSW'
        sizerRow.add(Wx::ContextHelpButton.new(self), 0, Wx::ALIGN_CENTER | Wx::ALL, 5)
      end
  
      text = Wx::TextCtrl.new(self, value: "A demo text control",
                              size: [300, 100],
                              style: Wx::TE_MULTILINE)
      text.set_help_text("Type text here if you have got nothing more interesting to do")
      sizerTop.add(text, 0, Wx::EXPAND|Wx::ALL, 5 )
      sizerTop.add(sizerRow, 0, Wx::ALIGN_RIGHT|Wx::ALL, 5 )
  
      set_sizer_and_fit(sizerTop)
  
      btnOK.set_focus
      btnOK.set_default
    end
  end

  class App < Wx::App
    def on_init
      # Create a simple help provider to make SetHelpText() do something.
      # Note that this must be set before any SetHelpText() calls are made.
      provider =  USE_SIMPLE_HELP_PROVIDER ? Wx::SimpleHelpProvider.new : Wx::HelpControllerHelpProvider.new
      Wx::HelpProvider.set(provider)
  
      # Required for advanced HTML help
      if Wx.has_feature?(:USE_STREAMS) && Wx.has_feature?(:USE_ZIPSTREAM) && Wx.has_feature?(:USE_ZLIB)
        Wx::FileSystem.add_handler(Wx::ArchiveFSHandler.new)
      end

      # Create the main application window
      frame = MyFrame.new("HelpDemo wxWidgets App",
                          [50, 50], [600, 400])

      unless USE_SIMPLE_HELP_PROVIDER
        provider.set_help_controller(frame.get_help_controller)
      end # !USE_SIMPLE_HELP_PROVIDER
  
      frame.show(true)
  
      # initialize the help system: this means that we'll use doc.hlp file under
      # Windows and that the HTML docs are in the subdirectory doc for platforms
      # using HTML help
      unless frame.get_help_controller.init(File.join(__dir__, 'doc'))
        Wx.log_error("Cannot initialize the help system, aborting.")
        # return false
      end

      # initialize the advanced HTML help system: this means that the HTML docs are in .htb
      # (zipped) form
      unless frame.get_advanced_html_help_controller.init(File.join(__dir__, 'doc'))
        Wx.log_error("Cannot initialize the advanced HTML help system, aborting.")
        # return false
      end

      true
    end

    def on_exit
      Wx::HelpProvider.set(nil)
      0
    end

  end

end

module HelpSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby Help example.',
      description: 'wxRuby example showcasing the use of Wx::HelpController.' }
  end

  def self.run
    execute(__FILE__)
  end

  if $0 == __FILE__
    Help::App.run
  end

end
