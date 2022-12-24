#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'

require 'net/http'
require 'uri'

ID_PageOpen,
  ID_DefaultLocalBrowser,
  ID_DefaultWebBrowser,
  ID_Back,
  ID_Forward,
  ID_Processor,
  ID_DrawCustomBg = (Wx::ID_HIGHEST..Wx::ID_HIGHEST+7).to_a


class MyHtmlFilter < Wx::Html::HtmlFilter
  def can_read(fsfile)
    return /\.foobar\Z/ =~ fsfile.location
  end

  def read_file(fsfile)
    uri = URI.parse(fsfile.location)
    if uri.scheme == 'file' && File.exist?(uri.path)
      return File.read(uri.path)
    else
      "<html><body><b>Cannot locate #{fsfile.location}</b></body></html>"
    end
  end
end

class MyHtmlWindow < Wx::Html::HtmlWindow
  BLUE_PEN = Wx::Pen.new
  attr_reader :html_src
  def initialize(*args)
    super
    @draw_custom_bg = false
    evt_erase_background :on_erase_bg_event

    BLUE_PEN.set_colour(Wx::BLUE)
  end

  def draw_custom_bg(val)
    @draw_custom_bg = !!val
    refresh
  end

  def on_opening_url(_type, url)
    related_frame.set_status_text(url + " lately opened", 1)
    Wx::HTML_OPEN
  end

  def on_erase_bg_event(event)
    unless @draw_custom_bg
      event.skip
      return
    end

    # draw a background grid to show that this handler is indeed executed
    paint do |dc|
      dc.pen = BLUE_PEN
      dc.clear

      vx, vy = get_virtual_size
      (vx / 15).times { |i| x = i*15; dc.draw_line(x, 0, x, vy) }
      (vy / 15).times { |i| y = i*15; dc.draw_line(0, y, vx, y) }
    end
  end

end

# The frame or self-contained window for this application
class HtmlFrame < Wx::Frame
  attr_reader :html_win

  def initialize(title, pos, size, style = Wx::DEFAULT_FRAME_STYLE)
    # A main application frame has no parent (nil)
    # -1 means this frame will be supplied a default id
    super(nil, -1, title, pos, size, style)
    setup_menus
    create_status_bar(2)
    self.icon = Wx::Icon.new(local_icon_file('../sample.xpm'))
    setup_panel
    self.status_text = "Welcome to wxRuby!"

    evt_html_link_clicked Wx::ID_ANY, :on_html_link_clicked
    evt_html_cell_hover Wx::ID_ANY, :on_html_cell_hover
    evt_html_cell_clicked Wx::ID_ANY, :on_html_cell_clicked
  end

  def setup_panel
    panel = Wx::Panel.new(self, -1)

    @html_win = MyHtmlWindow.new(panel, -1)
    @html_win.set_related_frame(self, 'HTML : %s')
    @html_win.set_related_status_bar(1)

    @html_win.load_file('samples/html/test.htm')

    text = Wx::TextCtrl.new(panel, Wx::ID_ANY, "",
                            Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE,
                            Wx::TE_MULTILINE)
    Wx::Log.set_active_target(Wx::LogTextCtrl.new(text))

    sizer = Wx::BoxSizer.new(Wx::VERTICAL)
    sizer.add(@html_win, 3, Wx::GROW)
    sizer.add(text, 1, Wx::GROW)
    panel.set_sizer(sizer)
  end

  def setup_menus
    menu_file = Wx::Menu.new
    menu_nav = Wx::Menu.new
    menu_help = Wx::Menu.new


    menu_file.append(ID_PageOpen, "&Open HTML page...\tCtrl-O")
    menu_file.append(ID_DefaultLocalBrowser, "&Open current page with default browser")
    menu_file.append(ID_DefaultWebBrowser, "Open a &web page with default browser")
    # menu_file.append_separator
    # menu_file.append(ID_Processor, "&Remove bold attribute",
    #                  '', Wx::ITEM_CHECK)
    menu_file.append_separator
    menu_file.append_check_item(ID_DrawCustomBg, "&Draw custom background")
    menu_file.append_separator
    menu_file.append(Wx::ID_EXIT, "&Close frame")

    menu_nav.append(ID_Back, "Go &BACK")
    menu_nav.append(ID_Forward, "Go &FORWARD")
    
    # Using Wx::ID_ABOUT default id means the menu item will be placed
    # in the correct platform-specific place
    menu_help.append(Wx::ID_ABOUT, "&About...\tF1", "Show about dialog")

    menu_bar = Wx::MenuBar.new
    menu_bar.append(menu_file, "&File")
    menu_bar.append(menu_nav, "&Navigate")
    menu_bar.append(menu_help, "&Help")
    # Assign the menus to this frame
    self.menu_bar = menu_bar

    if Wx.has_feature?(:USE_ACCEL)
      accel_entries = [
        Wx::AcceleratorEntry.new(Wx::ACCEL_ALT, Wx::K_LEFT, ID_Back),
        Wx::AcceleratorEntry.new(Wx::ACCEL_ALT, Wx::K_RIGHT, ID_Forward)
      ]
      set_accelerator_table(Wx::AcceleratorTable.new(accel_entries))
    end

    # handle menu events
    evt_menu ID_PageOpen, :on_open_page
    evt_menu ID_DefaultLocalBrowser, :on_default_local_browser
    evt_menu ID_DefaultWebBrowser, :on_default_web_browser
    evt_menu ID_Back, :on_back
    evt_menu ID_Forward, :on_forward
    evt_menu ID_DrawCustomBg, :on_draw_custom_bg
    evt_menu Wx::ID_EXIT, :on_quit
    evt_menu Wx::ID_ABOUT, :on_about
  end

  # end the application
  def on_quit(_evt)
    close(true)
  end

  def on_open_page(_evt)
    if Wx.has_feature?(:USE_FILEDLG)
      p = Wx.file_selector("Open HTML document", '',
                           '', '', 'HTML files|*.htm;*.html');
      unless p.empty?
        tm = Time.now
        if html_win.load_file(p)
          Wx.log_status("Loaded \"#{p}\" in #{Time.now-tm}sec")
        end
      end
    end
  end

  def on_default_local_browser(_evt)
    page = html_win.get_opened_page
    Wx.launch_default_browser(page) unless page.empty?
  end

  def on_default_web_browser(_evt)
    page = html_win.get_opened_page
    Wx.launch_default_browser('http://www.google.com') unless page.empty?
  end

  def on_back(_evt)
    Wx.message_box('You reached prehistory era!') unless html_win.history_back
  end

  def on_forward(_evt)
    Wx.message_box('No more items in history!') unless html_win.history_forward
  end

  def on_draw_custom_bg(event)
    html_win.draw_custom_bg(event.checked?)
  end

  # show an 'About' dialog
  def on_about(_evt)
    msg =  sprintf("This is the About dialog of the HTML sample.\n" \
                   "Welcome to wxRuby, version %s", Wx::WXRUBY_VERSION)

    # create a simple message dialog with OK button
    about_dlg = Wx::MessageDialog.new( self, msg, 'About WxRuby HTML',
                                       Wx::OK|Wx::ICON_INFORMATION )
    about_dlg.show_modal
	about_dlg.destroy
  end

  def on_html_link_clicked(event)
    Wx.log_message("The url '%s' has been clicked!", event.link_info.href)

    # skipping this event the default behaviour (load the clicked URL)
    # will happen...
    event.skip
  end

  def on_html_cell_hover(event)
    Wx.log_message("Mouse moved over cell %p at %d;%d",
                 event.cell, event.point.x, event.point.y)
  end

  def on_html_cell_clicked(event)
    Wx.log_message("Click over cell %p at %d;%d",
                 event.cell, event.point.x, event.point.y)

    # if we don't skip the event, OnHtmlLinkClicked won't be called!
    event.skip
  end

  # utility function to find an icon relative to this ruby script
  def local_icon_file(icon_name)
    File.join( File.dirname(__FILE__), icon_name) 
  end
end

# Wx::App is the container class for any wxruby app - only a single
# instance is required
class HtmlApp < Wx::App
  def on_init
    Wx::Html::HtmlWindow.add_filter(MyHtmlFilter.new)

    set_vendor_name("wxRuby")
    set_app_name("Wx::HtmlTest")

    frame = HtmlFrame.new("Wx::HtmlWindow testing application",
                             Wx::Point.new(50, 50), 
                             Wx::Size.new(450, 340))
    set_app_name('HtmlDemo')
    # required
    frame.show
  end
end

HtmlApp.new.run
