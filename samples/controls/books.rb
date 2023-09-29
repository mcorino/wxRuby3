# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

###

require 'wx'

class BooksFrame < Wx::Frame

  ID_NOTEBOOK = Wx::ID_HIGHEST+1
  ID_CHOICEBOOK = Wx::ID_HIGHEST+2
  ID_LISTBOOK = Wx::ID_HIGHEST+3
  ID_TREEBOOK = Wx::ID_HIGHEST+4

  PAGES = %w[Yet Another Way To Select Pages]

  def initialize
    super(nil, title: 'Book controls sample', size: [600, 450])

    icon_file = File.join(__dir__,'..', 'art', "wxruby.png")
    self.icon = Wx::Icon.new(icon_file)

    if Wx.has_feature?(:USE_STATUSBAR)
      create_status_bar()
    end

    # Make a menubar for the frame
    self.menu_bar = Wx::MenuBar.new {

      append Wx::Menu.new {
        append Wx::ID_EXIT
      }, '&File'

      append Wx::Menu.new {
        append ID_NOTEBOOK, 'Notebook'
        append ID_CHOICEBOOK, 'Choicebook'
        append ID_LISTBOOK, 'Listbook'
        append ID_TREEBOOK, 'Treebook'
      }, '&Books'

      append Wx::Menu.new {
        append Wx::ID_ABOUT
      }, '&Help'

    }

    @main_panel = Wx::Panel.new(self, Wx::ID_ANY)
    @main_panel.sizer = Wx::VBoxSizer.new
    @book_ctrl = nil

    evt_menu ID_NOTEBOOK, :show_notebook
    evt_menu ID_CHOICEBOOK, :show_choicebook
    evt_menu ID_LISTBOOK, :show_listbook
    evt_menu ID_TREEBOOK, :show_treebook

    evt_menu Wx::ID_EXIT, :on_quit
    evt_menu Wx::ID_ABOUT, :on_about
  end

  def setup_book(ctrl_name, tree = false)
    set_status_text("Using #{ctrl_name}")
    if tree
      PAGES.each_with_index do  |txt, ix|
        win = Wx::Panel.new(@book_ctrl)
        if ix == 0
          Wx::StaticText.new(win, -1,
                             "#{ctrl_name} is yet another way to switch between 'page' windows",
                             Wx::Point.new(10, 10))
        else
          Wx::StaticText.new(win, -1, "Page: #{ix+1}", Wx::Point.new(10,10))
        end

        if (ix % 2) == 0
          @book_ctrl.add_page(win, txt, ix == 0)
        else
          @book_ctrl.add_sub_page(win, txt)
        end
      end
    else
      PAGES.each_with_index do  |txt, ix|
        win = Wx::Panel.new(@book_ctrl)
        if ix == 0
          Wx::StaticText.new(win, -1,
                             "#{ctrl_name} is yet another way to switch between 'page' windows",
                             Wx::Point.new(10, 10))
        else
          Wx::StaticText.new(win, -1, "Page: #{ix+1}", Wx::Point.new(10,10))
        end

        @book_ctrl.add_page(win, txt)
      end
    end
  end
  private :setup_book

  def clear_book
    if @book_ctrl
      @main_panel.sizer.remove(0)
      @book_ctrl.destroy
      @book_ctrl = nil
    end
  end
  private :clear_book

  def show_notebook
    clear_book
    @book_ctrl = Wx::Notebook.new(@main_panel)
    @main_panel.sizer.add(@book_ctrl, 1, Wx::GROW|Wx::ALL, 1)
    setup_book('Wx::Notebook')
    @main_panel.layout
    refresh
  end

  def show_choicebook
    clear_book
    @book_ctrl = Wx::Choicebook.new(@main_panel)
    @main_panel.sizer.add(@book_ctrl, 1, Wx::GROW|Wx::ALL, 1)
    setup_book('Wx::Choicebook')
    @main_panel.layout
    refresh
  end

  def show_listbook
    clear_book
    @book_ctrl = Wx::Listbook.new(@main_panel)
    @main_panel.sizer.add(@book_ctrl, 1, Wx::GROW|Wx::ALL, 1)
    setup_book('Wx::Listbook')
    @main_panel.layout
    refresh
  end

  def show_treebook
    clear_book
    @book_ctrl = Wx::Treebook.new(@main_panel)
    style = @book_ctrl.tree_ctrl.window_style
    style &= ~Wx::TR_NO_LINES
    @book_ctrl.tree_ctrl.window_style = style
    @main_panel.sizer.add(@book_ctrl, 1, Wx::GROW|Wx::ALL, 1)
    setup_book('Wx::Treebook', true)
    @main_panel.layout
    refresh
  end

  def on_about(event)
    Wx.message_box(
      "wxRuby Books sample\n" +
        "Authors:\n" +
        "   Martin Corino (c) 2023\n" +
        'Usage: click Books and select a book control',
      'About Books sample')
  end

  def on_quit(event)
    close
  end

end

module BooksSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby Book controls example.',
      description: "wxRuby example showcasing the various common book controls.\n"+
                   "  - Wx::NoteBook\n"+
                   "  - Wx::ChoiceBook\n"+
                   "  - Wx::ListBook\n"+
                   "  - Wx::TreeBook\n"
    }
  end

  def self.activate
    frame = BooksFrame.new
    frame.show
    frame
  end

  if $0 == __FILE__
    Wx::App.run { BooksSample.activate }
  end

end
