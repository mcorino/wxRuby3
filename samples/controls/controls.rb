# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Adapted for wxRuby3
###

require 'wx'

include Wx

CONTROLS_QUIT   = ID_EXIT
CONTROLS_TEXT   = 101
CONTROLS_ABOUT  = ID_ABOUT
CONTROLS_CLEAR_LOG = 103
# tooltip menu
CONTROLS_SET_TOOLTIP_DELAY = 200
CONTROLS_ENABLE_TOOLTIPS = 201
# panel menu
CONTROLS_ENABLE_ALL     = 202


ID_NOTEBOOK          = 1000

ID_LISTBOX           = 130
ID_LISTBOX_SEL_NUM   = 131
ID_LISTBOX_SEL_STR   = 132
ID_LISTBOX_CLEAR     = 133
ID_LISTBOX_APPEND    = 134
ID_LISTBOX_DELETE    = 135
ID_LISTBOX_FONT      = 136
ID_LISTBOX_ENABLE    = 137
ID_LISTBOX_SORTED    = 138

ID_CHOICE            = 120
ID_CHOICE_SEL_NUM    = 121
ID_CHOICE_SEL_STR    = 122
ID_CHOICE_CLEAR      = 123
ID_CHOICE_APPEND     = 124
ID_CHOICE_DELETE     = 125
ID_CHOICE_FONT       = 126
ID_CHOICE_ENABLE     = 127
ID_CHOICE_SORTED     = 128

ID_COMBO             = 140
ID_COMBO_SEL_NUM     = 141
ID_COMBO_SEL_STR     = 142
ID_COMBO_CLEAR       = 143
ID_COMBO_APPEND      = 144
ID_COMBO_DELETE      = 145
ID_COMBO_FONT        = 146
ID_COMBO_ENABLE      = 147

ID_RADIOBOX          = 160
ID_RADIOBOX_SEL_NUM  = 161
ID_RADIOBOX_SEL_STR  = 162
ID_RADIOBOX_FONT     = 163
ID_RADIOBOX_ENABLE   = 164

ID_RADIOBUTTON_1     = 166
ID_RADIOBUTTON_2     = 167

ID_SET_FONT          = 170

ID_GAUGE             = 180
ID_SLIDER            = 181

ID_SPIN              = 182
ID_BTNPROGRESS       = 183
ID_BUTTON_LABEL      = 184
ID_SPINCTRL          = 185

ID_BUTTON_TEST1      = 190
ID_BUTTON_TEST2      = 191
ID_BITMAP_BTN        = 192

ID_CHANGE_COLOUR     = 200

ID_SIZER_CHECK1      = 201
ID_SIZER_CHECK2      = 202
ID_SIZER_CHECK3      = 203
ID_SIZER_CHECK4      = 204
ID_SIZER_CHECK14     = 205
ID_SIZER_CHECKBIG    = 206

Image_List, Image_Choice, Image_Combo, Image_Text, Image_Radio, Image_Gauge, Image_Max = (0..6).to_a


# a button which intercepts double clicks (for testing...)
class MyButton < Button
  def initialize(parent,id,label = EmptyString,pos = DEFAULT_POSITION,size = DEFAULT_SIZE)
    super(parent,id,label,pos,size)

    evt_left_dclick {|event| onDClick(event)}
  end

  def onDClick(event)
    log_message("MyButton::OnDClick")
    event.skip()
  end

end

# a combo which intercepts chars (to test Windows behaviour)
class MyComboBox < ComboBox
  def initialize(parent,id,value = EmptyString,
                  pos = DEFAULT_POSITION,
                  size = DEFAULT_SIZE,
                  choices = [],
                  style = 0)
    super(parent, id, value, pos, size, choices)#, style)

    evt_char {|event| onChar(event)}
    evt_key_down {|event| onKeyDown(event)}
    evt_key_up {|event| onKeyUp(event)}

    evt_set_focus {|event| onFocusGot(event)}
  end

  def onChar(event)
    log_message("MyComboBox::OnChar : [#{event.get_unicode_key ? event.get_unicode_key.ord : 0}]")
    if event.get_unicode_key == ?w
      log_message("MyComboBox: 'w' will be ignored.")
    else
      event.skip()
    end
  end

  def onKeyDown(event)
    log_message("MyComboBox::OnKeyDown")
    if event.key_code() == ?w
      log_message("MyComboBox: 'w' will be ignored.")
    else
      event.skip()
    end
  end

  def onKeyUp(event)
	#log_message("MyComboBox::OnKeyUp")
    event.skip()
  end

  def onFocusGot(event)
	  log_message("MyComboBox::OnFocusGot")
    event.skip()
  end

end

# a radiobox which handles focus set/kill (for testing)
class MyRadioBox < RadioBox
  def initialize(parent,
                  id,title = EmptyString,
                  pos = DEFAULT_POSITION,
                  size = DEFAULT_SIZE,
                  choices = [],
                  majorDim = 1,
                  style = RA_HORIZONTAL)
    super(parent, id, title, pos, size, choices, majorDim,style)
    set_foreground_colour(RED)

    evt_set_focus {|event| onFocusGot(event)}
    evt_kill_focus {|event| onFocusLost(event)}

  end

  def onFocusGot(event)
    log_message("MyRadioBox::OnFocusGot")
    event.skip()
  end

  def onFocusLost(event)
    log_message("MyRadioBox::OnFocusLost")
    event.skip()
  end

end


class MyPanel < Panel

  #    delete Log::set_active_target(@m_logTargetOld)
  #    delete @m_notebook.GetImageList()
  attr_reader   :m_text,:m_logTargetOld

  def initialize(frame,x,y,w,h)
    super( frame, -1, Point.new(x, y), Size.new(w, h) )

    @s_colOld = NULL_COLOUR

    @m_text = TextCtrl.new(self, -1, "This is the log window.\n",
                            Point.new(0, 250), Size.new(100, 50), TE_MULTILINE)
    @m_text.set_background_colour(Colour.new("wheat"))

	  @m_logTargetOld = Log::set_active_target(LogTextCtrl.new(@m_text))

    @m_notebook = Wx::Notebook.new(self, ID_NOTEBOOK, Point.new(0,0), Size.new(100,50))

    choices = [
      "This",
      "is one of my",
      "really",
      "wonderful",
      "examples."
    ]

    # fill the image list

    imagelist = ImageList.new(16, 16)

    imagelist.add( Bitmap.new( local_icon_file("list.xpm"), 
                               Wx::BITMAP_TYPE_XPM))
    imagelist.add( Bitmap.new( local_icon_file("choice.xpm"), 
                               Wx::BITMAP_TYPE_XPM))
    imagelist.add( Bitmap.new( local_icon_file("combo.xpm"), 
                               Wx::BITMAP_TYPE_XPM))
    imagelist.add( Bitmap.new( local_icon_file("text.xpm"), 
                               Wx::BITMAP_TYPE_XPM))
    imagelist.add( Bitmap.new( local_icon_file("radio.xpm"), 
                               Wx::BITMAP_TYPE_XPM))
    imagelist.add( Bitmap.new( local_icon_file("gauge.xpm"), 
                               Wx::BITMAP_TYPE_XPM))

    @m_notebook.set_image_list(imagelist)

    panel = Panel.new(@m_notebook)
    @m_listbox = ListBox.new( panel, ID_LISTBOX,
                              Point.new(10,10), Size.new(120,70),
                              choices, LB_ALWAYS_SB )

    @m_listboxSorted = ListBox.new( panel, ID_LISTBOX_SORTED,
                                    Point.new(10,90), Size.new(120,70),
                                    choices, LB_SORT )


    @m_listbox.set_cursor(CROSS_CURSOR)

    @m_listbox.set_tool_tip( "This is a list box" )


    @m_lbSelectNum = Button.new( panel, ID_LISTBOX_SEL_NUM, "Select #&2", Point.new(180,30), Size.new(140,30) )
    @m_lbSelectThis = Button.new( panel, ID_LISTBOX_SEL_STR, "&Select 'This'", Point.new(340,30), Size.new(140,30) )
    Button.new( panel, ID_LISTBOX_CLEAR, "&clear", Point.new(180,80), Size.new(140,30) )
    MyButton.new( panel, ID_LISTBOX_APPEND, "&append 'Hi!'", Point.new(340,80), Size.new(140,30) )
    Button.new( panel, ID_LISTBOX_DELETE, "D&elete selected item", Point.new(180,130), Size.new(140,30) )
    button = MyButton.new( panel, ID_LISTBOX_FONT, "Set &Italic font", Point.new(340,130), Size.new(140,30) )

    button.set_default()

    button.set_foreground_colour(BLUE)

    button.set_tool_tip( "Press here to set italic font" )

    @m_checkbox = CheckBox.new( panel, ID_LISTBOX_ENABLE, "&Disable", Point.new(20,170) )
    @m_checkbox.set_value(false)
    @m_checkbox.set_tool_tip( "Click here to disable the listbox" )
    @m_toggle_color = CheckBox.new( panel, ID_CHANGE_COLOUR, "&Toggle colour",
                                    Point.new(110,170) )
    panel.set_cursor(Cursor.new(CURSOR_HAND))
    @m_notebook.add_page(panel, "ListBox", true, Image_List)

    panel = Panel.new(@m_notebook)
    @m_choice = Choice.new( panel, ID_CHOICE, Point.new(10,10), Size.new(120,-1), choices )
    @m_choiceSorted = Choice.new( panel, ID_CHOICE_SORTED, Point.new(10,70), Size.new(120,-1),
                                  choices, CB_SORT )

    @m_choice.set_selection(2)
    @m_choice.set_background_colour(Colour.new("red"))
    Button.new( panel, ID_CHOICE_SEL_NUM, "Select #&2", Point.new(180,30), Size.new(140,30) )
    Button.new( panel, ID_CHOICE_SEL_STR, "&Select 'This'", Point.new(340,30), Size.new(140,30) )
    Button.new( panel, ID_CHOICE_CLEAR, "&clear", Point.new(180,80), Size.new(140,30) )
    Button.new( panel, ID_CHOICE_APPEND, "&append 'Hi!'", Point.new(340,80), Size.new(140,30) )
    Button.new( panel, ID_CHOICE_DELETE, "D&elete selected item", Point.new(180,130), Size.new(140,30) )
    Button.new( panel, ID_CHOICE_FONT, "Set &Italic font", Point.new(340,130), Size.new(140,30) )
    CheckBox.new( panel, ID_CHOICE_ENABLE, "&Disable", Point.new(20,130), Size.new(140,30) )

    @m_notebook.add_page(panel, "Choice", false, Image_Choice)

    panel = Panel.new(@m_notebook)
    StaticBox.new( panel, -1, "&Box around combobox",
                   Point.new(5, 5), Size.new(150, 100))
    @m_combo = MyComboBox.new( panel, ID_COMBO, "This",
                               Point.new(20,25), Size.new(120, -1),
                               choices,TE_PROCESS_ENTER)
    # CB_READONLY | PROCESS_ENTER)

    @m_combo.set_tool_tip("This is a natural\ncombobox - can you believe me?")

    Button.new( panel, ID_COMBO_SEL_NUM, "Select #&2", Point.new(180,30), Size.new(140,30) )
    Button.new( panel, ID_COMBO_SEL_STR, "&Select 'This'", Point.new(340,30), Size.new(140,30) )
    Button.new( panel, ID_COMBO_CLEAR, "&clear", Point.new(180,80), Size.new(140,30) )
    Button.new( panel, ID_COMBO_APPEND, "&append 'Hi!'", Point.new(340,80), Size.new(140,30) )
    Button.new( panel, ID_COMBO_DELETE, "D&elete selected item", Point.new(180,130), Size.new(140,30) )
    Button.new( panel, ID_COMBO_FONT, "Set &Italic font", Point.new(340,130), Size.new(140,30) )
    CheckBox.new( panel, ID_COMBO_ENABLE, "&Disable", Point.new(20,130), Size.new(140,30) )
    @m_notebook.add_page(panel, "ComboBox", false, Image_Combo)

    choices2 = ["First", "Second"]
    # "Third",
    #"Fourth", "Fifth", "Sixth",
    #"Seventh", "Eighth", "Nineth", "Tenth" */

    panel = Panel.new(@m_notebook)
    MyRadioBox.new( panel, ID_RADIOBOX, "&That", Point.new(10,160), Size.new(-1,-1), choices2, 1, RA_SPECIFY_ROWS )
    @m_radio = RadioBox.new( panel, ID_RADIOBOX, "T&his", Point.new(10,10), Size.new(-1,-1), choices, 1, RA_SPECIFY_COLS )
    @m_radio.set_foreground_colour(RED)

    @m_radio.set_tool_tip("Ever seen a radiobox?")

    Button.new( panel, ID_RADIOBOX_SEL_NUM, "Select #&2", Point.new(180,30), Size.new(140,30) )
    Button.new( panel, ID_RADIOBOX_SEL_STR, "&Select 'This'", Point.new(180,80), Size.new(140,30) )
    @m_fontButton = Button.new( panel, ID_SET_FONT, "Set &more Italic font", Point.new(340,30), Size.new(140,30) )
    Button.new( panel, ID_RADIOBOX_FONT, "Set &Italic font", Point.new(340,80), Size.new(140,30) )
    CheckBox.new( panel, ID_RADIOBOX_ENABLE, "&Disable", Point.new(340,130), DEFAULT_SIZE )
    rb = RadioButton.new( panel, ID_RADIOBUTTON_1, "Radiobutton1", Point.new(210,170), DEFAULT_SIZE, RB_GROUP )
    rb.set_value( false )
    RadioButton.new( panel, ID_RADIOBUTTON_2, "&Radiobutton2", Point.new(340,170), DEFAULT_SIZE )
    @m_notebook.add_page(panel, "RadioBox", false, Image_Radio)

    panel = Panel.new(@m_notebook)
    StaticBox.new( panel, -1, "&Gauge and Slider", Point.new(10,10), Size.new(222,130) )
    @m_gauge = Gauge.new( panel, -1, 200, Point.new(18,50), Size.new(155, 30), GA_HORIZONTAL|NO_BORDER )
    @m_gauge.set_background_colour(GREEN)
    @m_gauge.set_foreground_colour(RED)
    @m_gaugeVert = Gauge.new( panel, -1, 100,
                              Point.new(195,35), Size.new(30, 90),
                              GA_VERTICAL | GA_SMOOTH | NO_BORDER )
    @m_slider = Slider.new( panel, ID_SLIDER, 0, 0, 200, Point.new(18,90), Size.new(155,-1),
                            SL_AUTOTICKS | SL_LABELS )
    @m_slider.set_tick_freq(40) unless Wx::PLATFORM == 'WXOSX'
    @m_slider.set_tool_tip("This is a sliding slider")

    StaticBox.new( panel, -1, "&Explanation",
                   Point.new(230,10), Size.new(270,130),
                   ALIGN_CENTER )

    StaticText.new( panel, -1,
                    "In order see the gauge (aka progress bar)\n"+
                    "control do something you have to drag the\n"+
                    "handle of the slider to the right.\n"+
                    "\n"+
                    "This is also supposed to demonstrate how\n"+
                    "to use static controls.\n",
                    Point.new(250,25),
                    Size.new(240, 110))
    initialSpinValue = -5
    s = initialSpinValue.to_s
    @m_spintext = TextCtrl.new( panel, -1, s, Point.new(20,160), Size.new(80,-1) )
    @m_spinbutton = SpinButton.new( panel, ID_SPIN, Point.new(103,160), Size.new(80, -1) )
    @m_spinbutton.set_range(-40,30)
    @m_spinbutton.set_value(initialSpinValue)

    @m_btnProgress = Button.new( panel, ID_BTNPROGRESS, "&Show progress dialog",
                                 Point.new(300, 160) )

    @m_spinctrl = SpinCtrl.new( panel, ID_SPINCTRL, "", Point.new(200, 160), Size.new(80, -1) )
    @m_spinctrl.set_range(10,30)
    @m_spinctrl.set_value(15)

    @m_notebook.add_page(panel, "Gauge", false, Image_Gauge)

    panel = Panel.new(@m_notebook)

    icon = ArtProvider::get_icon(ART_INFORMATION)
    StaticBitmap.new( panel, -1, icon, Point.new(10, 10) )

    bitmap = Bitmap.new( 100, 100 )
    bitmap.draw do | dc |
      dc.clear()
      dc.set_pen(GREEN_PEN)
      dc.draw_ellipse(5, 5, 90, 90)
      dc.draw_text("Bitmap", 30, 40)
    end

    BitmapButton.new(panel, ID_BITMAP_BTN, bitmap, Point.new(100, 20))

    # test for masked bitmap display
    bitmap = Bitmap.new( File.join(File.dirname(__FILE__), "test2.bmp"), 
                         BITMAP_TYPE_BMP)
    if bitmap.is_ok()
      bitmap.set_mask(Mask.new(bitmap, BLUE))
      StaticBitmap.new(panel, -1, bitmap, Point.new(300, 120))
    end

    bmp1 = ArtProvider::get_bitmap(ART_INFORMATION)
    bmp2 = ArtProvider::get_bitmap(ART_WARNING)
    bmp3 = ArtProvider::get_bitmap(ART_QUESTION)
    bmpBtn = BitmapButton.new(panel, -1,
                              bmp1,
                              Point.new(30, 70))

    bmpBtn.set_bitmap_current(bmp2)
    bmpBtn.set_bitmap_pressed(bmp3)

    ToggleButton.new(panel, ID_BUTTON_LABEL,
                      "&Toggle label", Point.new(250, 20))
    @m_label = StaticText.new(panel, -1, "Label with some long text",
                               Point.new(250, 60), DEFAULT_SIZE,
                               ALIGN_RIGHT)
    @m_label.set_foreground_colour(BLUE )

    @m_notebook.add_page(panel, "BitmapXXX")

    # sizer

    panel = Panel.new(@m_notebook)
    panel.set_auto_layout( true )

    sizer = BoxSizer.new( VERTICAL )

    csizer =
      StaticBoxSizer.new(sbox = StaticBox.new(panel, -1, "Show Buttons"),
                          HORIZONTAL )

    check1 = CheckBox.new(sbox, ID_SIZER_CHECK1, "1")
    check1.set_value(true)
    csizer.add(check1)
    check2 = CheckBox.new(sbox, ID_SIZER_CHECK2, "2")
    check2.set_value(true)
    csizer.add(check2)
    check3 = CheckBox.new(sbox, ID_SIZER_CHECK3, "3")
    check3.set_value(true)
    csizer.add(check3)
    check4 = CheckBox.new(sbox, ID_SIZER_CHECK4, "4")
    check4.set_value(true)
    csizer.add(check4)
    check14 = CheckBox.new(sbox, ID_SIZER_CHECK14, "1-4")
    check14.set_value(true)
    csizer.add(check14)
    checkBig = CheckBox.new(sbox, ID_SIZER_CHECKBIG, "Big")
    checkBig.set_value(true)
    csizer.add(checkBig)

    sizer.add(csizer)

    @m_hsizer = BoxSizer.new( HORIZONTAL )

    @m_buttonSizer = BoxSizer.new(VERTICAL)

    @m_sizerBtn1 = Button.new(panel, -1, "Test Button &1" )
    @m_buttonSizer.add( @m_sizerBtn1, 0, ALL, 10 )
    @m_sizerBtn2 = Button.new(panel, -1, "Test Button &2" )
    @m_buttonSizer.add( @m_sizerBtn2, 0, ALL, 10 )
    @m_sizerBtn3 = Button.new(panel, -1, "Test Button &3" )
    @m_buttonSizer.add( @m_sizerBtn3, 0, ALL, 10 )
    @m_sizerBtn4 = Button.new(panel, -1, "Test Button &4" )
    @m_buttonSizer.add( @m_sizerBtn4, 0, ALL, 10 )

    @m_hsizer.add(@m_buttonSizer)
    @m_hsizer.add( 20,20, 1 )
    @m_bigBtn = Button.new(panel, -1, "Multiline\nbutton" )
    @m_hsizer.add( @m_bigBtn , 3, GROW|ALL, 10 )

    sizer.add(@m_hsizer, 1, GROW)

    panel.set_sizer( sizer )

    @m_notebook.add_page(panel, "Sizer")

    evt_size {|event| onSize(event) }
    evt_notebook_page_changing(ID_NOTEBOOK)  {|event| onPageChanging(event) }
    evt_notebook_page_changed(ID_NOTEBOOK) {|event| onPageChanged(event) }
    evt_listbox(ID_LISTBOX) {|event| onListBox(event) }
    evt_listbox(ID_LISTBOX_SORTED) {|event| onListBox(event) }
    evt_listbox_dclick(ID_LISTBOX) {|event| onListBoxDoubleClick(event) }
    evt_button(ID_LISTBOX_SEL_NUM) {|event| onListBoxButtons(event) }
    evt_button(ID_LISTBOX_SEL_STR) {|event| onListBoxButtons(event) }
    evt_button(ID_LISTBOX_CLEAR) {|event| onListBoxButtons(event) }
    evt_button(ID_LISTBOX_APPEND) {|event| onListBoxButtons(event) }
    evt_button(ID_LISTBOX_DELETE) {|event| onListBoxButtons(event) }
    evt_button(ID_LISTBOX_FONT) {|event| onListBoxButtons(event) }
    evt_checkbox(ID_LISTBOX_ENABLE) {|event| onListBoxButtons(event) }
    evt_choice(ID_CHOICE) {|event| onChoice(event) }
    evt_choice(ID_CHOICE_SORTED) {|event| onChoice(event) }
    evt_button(ID_CHOICE_SEL_NUM) {|event| onChoiceButtons(event) }
    evt_button(ID_CHOICE_SEL_STR) {|event| onChoiceButtons(event) }
    evt_button(ID_CHOICE_CLEAR) {|event| onChoiceButtons(event) }
    evt_button(ID_CHOICE_APPEND) {|event| onChoiceButtons(event) }
    evt_button(ID_CHOICE_DELETE) {|event| onChoiceButtons(event) }
    evt_button(ID_CHOICE_FONT) {|event| onChoiceButtons(event) }
    evt_checkbox(ID_CHOICE_ENABLE) {|event| onChoiceButtons(event) }
    evt_combobox(ID_COMBO) {|event| onCombo(event) }
    evt_text(ID_COMBO) {|event| onComboTextChanged(event) }
    evt_text_enter(ID_COMBO) {|event| onComboTextEnter(event) }
    evt_button(ID_COMBO_SEL_NUM) {|event| onComboButtons(event) }
    evt_button(ID_COMBO_SEL_STR) {|event| onComboButtons(event) }
    evt_button(ID_COMBO_CLEAR) {|event| onComboButtons(event) }
    evt_button(ID_COMBO_APPEND) {|event| onComboButtons(event) }
    evt_button(ID_COMBO_DELETE) {|event| onComboButtons(event) }
    evt_button(ID_COMBO_FONT) {|event| onComboButtons(event) }
    evt_checkbox(ID_COMBO_ENABLE) {|event| onComboButtons(event) }
    evt_radiobox(ID_RADIOBOX) {|event| onRadio(event) }
    evt_button(ID_RADIOBOX_SEL_NUM) {|event| onRadioButtons(event) }
    evt_button(ID_RADIOBOX_SEL_STR) {|event| onRadioButtons(event) }
    evt_button(ID_RADIOBOX_FONT) {|event| onRadioButtons(event) }
    evt_checkbox(ID_RADIOBOX_ENABLE) {|event| onRadioButtons(event) }
    evt_button(ID_SET_FONT) {|event| onSetFont(event) }
    evt_slider(ID_SLIDER) {|event| onSliderupdate(event) }
    evt_spin(ID_SPIN) {|event| onSpinupdate(event) }
    evt_spin_up(ID_SPIN) {|event| onSpinUp(event) }
    evt_spin_down(ID_SPIN) {|event| onSpinDown(event) }
    evt_update_ui(ID_BTNPROGRESS) {|event| onupdateShowProgress(event) }
    evt_button(ID_BTNPROGRESS) {|event| onShowProgress(event) }
    evt_spinctrl(ID_SPINCTRL) {|event| onSpinCtrl(event) }
    evt_spin_up(ID_SPINCTRL) {|event| onSpinCtrlUp(event) }
    evt_spin_down(ID_SPINCTRL) {|event| onSpinCtrlDown(event) }
    evt_text(ID_SPINCTRL) {|event| onSpinCtrlText(event) }
    if (RUBY_PLATFORM =~ /mswin/)
      evt_togglebutton(ID_BUTTON_LABEL) {|event| onupdateLabel(event) }
    end
    evt_checkbox(ID_CHANGE_COLOUR) {|event| onChangeColour(event) }
    evt_button(ID_BUTTON_TEST1) {|event| onTestButton(event) }
    evt_button(ID_BUTTON_TEST2) {|event| onTestButton(event) }
    evt_button(ID_BITMAP_BTN) {|event| onBmpButton(event) }

    evt_checkbox(ID_SIZER_CHECK1) {|event| onSizerCheck(event) }
    evt_checkbox(ID_SIZER_CHECK2) {|event| onSizerCheck(event) }
    evt_checkbox(ID_SIZER_CHECK3) {|event| onSizerCheck(event) }
    evt_checkbox(ID_SIZER_CHECK4) {|event| onSizerCheck(event) }
    evt_checkbox(ID_SIZER_CHECK14) {|event| onSizerCheck(event) }
    evt_checkbox(ID_SIZER_CHECKBIG) {|event| onSizerCheck(event) }

  end

  # utility function to find an icon relative to this ruby script
  def local_icon_file(icon_name)
    File.join( __dir__, icon_name)
  end


  def onSize(event)
    size = get_client_size()
    x = size.get_width
    y = size.get_height
    if @m_notebook
      @m_notebook.set_size( 2, 2, x-4, y*2/3-4 )
    end
    if @m_text
      @m_text.set_size( 2, y*2/3+2, x-4, y/3-4 )
    end
  end

  def onPageChanging(event)
	
    selOld = event.get_old_selection()
    if selOld == 2
      if message_box("This demonstrates how a program may prevent the\n"+
                      "page change from taking place - if you select\n"+
                      "[No] the current page will stay the third one\n",
                      "Control sample",
                      ICON_QUESTION | YES_NO, self) != YES
        event.veto()
        return nil
      end
    end
    @m_text << "Notebook selection is being changed from " << selOld \
    << " to " << event.get_selection()   \
    << " (current page from notebook is "   \
    << @m_notebook.get_selection() << ")\n"
  end

  def onPageChanged(event)
    @m_text << "Notebook selection is now " << event.get_selection() \
    << " (from notebook: " << @m_notebook.get_selection()    \
    << ")\n"
  end

  def onTestButton(event)
    log_message("Button %s clicked.",
                 event.get_id() == ID_BUTTON_TEST1 ? '1' : '2')
  end

  def onBmpButton(event)
    log_message("Bitmap button clicked.")
  end

  def onChangeColour(event)
    # test panel colour changing and propagation to the subcontrols
    if @s_colOld.is_ok()

      set_background_colour(@s_colOld)
      @s_colOld = NULL_COLOUR

      @m_lbSelectThis.set_foreground_colour(Colour.new("red"))
      @m_lbSelectThis.set_background_colour(Colour.new("white"))
    else
      @s_colOld = Colour.new("red")
      set_background_colour(Colour.new("white"))

      @m_lbSelectThis.set_foreground_colour(Colour.new("white"))
      @m_lbSelectThis.set_background_colour(Colour.new("red"))
    end

    @m_lbSelectThis.refresh()
    refresh()
  end

  def onListBox(event)
    #    GetParent().Move(100, 100)
    if event.get_int() == -1
      @m_text.append_text( "ListBox has no selections anymore\n" )
      return Qnil
    end

    listbox = (event.get_id() == ID_LISTBOX) ? @m_listbox : @m_listboxSorted

    @m_text.append_text( "ListBox event selection string is: '" )
    @m_text.append_text( event.get_string() )
    @m_text.append_text( "'\n" )
    @m_text.append_text( "ListBox control selection string is: '" )
    @m_text.append_text( listbox.get_string_selection() )
    @m_text.append_text( "'\n" )

    # NOTE: get_client_data and set_client_data have been removed from wxRuby 0.4
    # because they could cause crashes
    #        obj = event.get_client_data()
    #        @m_text.append_text( "ListBox event client data string is: '" )
    #        if obj
    #            @m_text.append_text( obj )
    #        else
    #            @m_text.append_text( "none" )
    #        end

    #        @m_text.append_text( "'\n" )
    #        @m_text.append_text( "ListBox control client data string is: '" )
    #        obj = listbox.get_client_data(listbox.get_selection())
    #        if obj
    #            @m_text.append_text( obj )
    #        else
    #            @m_text.append_text( "none" )
    #        end
    #        @m_text.append_text( "'\n" )
  end

  def onListBoxDoubleClick(event)
    @m_text.append_text( "ListBox double click string is: " )
    @m_text.append_text( event.get_string() )
    @m_text.append_text( "\n" )
  end

  def onListBoxButtons(event)
    case event.get_id()
    when ID_LISTBOX_ENABLE
      @m_text.append_text("Checkbox clicked.\n")
      if event.get_int() != 0
        @m_checkbox.set_tool_tip( "Click to enable listbox" )
        @m_toggle_color.enable(false)
      else
        @m_checkbox.set_tool_tip( "Click to disable listbox" )
        @m_toggle_color.enable(true)
      end
      @m_listbox.enable( event.get_int() == 0 )
      @m_lbSelectThis.enable( event.get_int() == 0 )
      @m_lbSelectNum.enable( event.get_int() == 0 )
      @m_listboxSorted.enable( event.get_int() == 0 )
      #w = Window::find_window_by_id(ID_CHANGE_COLOUR)
      #if(w)
      #    w.enable( event.get_int() == 0 )
      #else
      #    puts("Window ID_CHANGE_COLOR not found")
      #end
    when ID_LISTBOX_SEL_NUM
      @m_listbox.set_selection( 2 )
      @m_listboxSorted.set_selection( 2 )
      @m_lbSelectThis.warp_pointer( 40, 14 )
    when ID_LISTBOX_SEL_STR
      @m_listbox.set_string_selection( "This" )
      @m_listboxSorted.set_string_selection( "This" )
      @m_lbSelectNum.warp_pointer( 40, 14 )
    when ID_LISTBOX_CLEAR
      @m_listbox.clear()
      @m_listboxSorted.clear()
    when ID_LISTBOX_APPEND
      @m_listbox.append( "Hi!" )
      @m_listboxSorted.append( "Hi!" )
    when ID_LISTBOX_DELETE
      idx = @m_listbox.get_selection()
      if idx != NOT_FOUND
        @m_listbox.delete( idx )
      end
      idx = @m_listboxSorted.get_selection()
      if idx != NOT_FOUND
        @m_listboxSorted.delete( idx )
      end
    when ID_LISTBOX_FONT
      @m_listbox.set_font( ITALIC_FONT )
      @m_listboxSorted.set_font( ITALIC_FONT )
      @m_checkbox.set_font( ITALIC_FONT )
    end
  end


  def onChoice(event)

    choice = (event.get_id() == ID_CHOICE) ? @m_choice : @m_choiceSorted

    @m_text.append_text( "Choice event selection string is: '" )
    @m_text.append_text( event.get_string() )
    @m_text.append_text( "'\n" )
    @m_text.append_text( "Choice control selection string is: '" )
    @m_text.append_text( choice.get_string_selection() )
    @m_text.append_text( "'\n" )

    # NOTE: get_client_data and set_client_data have been removed from wxRuby 0.4
    # because they could cause crashes
    #        obj = event.get_client_data()
    #        @m_text.append_text( "Choice event client data string is: '" )

    #        if obj
    #           @m_text.append_text( obj )
    #        else
    #           @m_text.append_text( "none" )
    #        end

    #        @m_text.append_text( "'\n" )
    #        @m_text.append_text( "Choice control client data string is: '" )

    #        obj = choice.get_client_data(choice.get_selection())
    #        if obj
    #           @m_text.append_text( obj )
    #        else
    #           @m_text.append_text( "none" )
    #        end
    #        @m_text.append_text( "'\n" )
  end

  def onChoiceButtons(event)
    case event.get_id()
    when ID_CHOICE_ENABLE
      @m_choice.enable( event.get_int() == 0 )
      @m_choiceSorted.enable( event.get_int() == 0 )
    when ID_CHOICE_SEL_NUM
      @m_choice.set_selection( 2 )
      @m_choiceSorted.set_selection( 2 )
    when ID_CHOICE_SEL_STR
      @m_choice.set_string_selection( "This" )
      @m_choiceSorted.set_string_selection( "This" )
    when ID_CHOICE_CLEAR
      @m_choice.clear()
      @m_choiceSorted.clear()
    when ID_CHOICE_APPEND
      @m_choice.append( "Hi!" )
      @m_choiceSorted.append( "Hi!" )
    when ID_CHOICE_DELETE
      idx = @m_choice.get_selection()
      if idx != NOT_FOUND
        @m_choice.delete( idx )
      end
      idx = @m_choiceSorted.get_selection()
      if idx != NOT_FOUND
        @m_choiceSorted.delete( idx )
      end
    when ID_CHOICE_FONT
      @m_choice.set_font( ITALIC_FONT )
      @m_choiceSorted.set_font( ITALIC_FONT )
    end
  end

  def onCombo(event)
    @m_text.append_text( "ComboBox event selection string is: " )
    @m_text.append_text( event.get_string() )
    @m_text.append_text( "\n" )
    @m_text.append_text( "ComboBox control selection string is: " )
    @m_text.append_text( @m_combo.get_string_selection() )
    @m_text.append_text( "\n" )
  end

  def onComboTextChanged(event)
    str = sprintf( "Text in the combobox changed: now is '%s'.",
                   event.get_string())
    log_message( str )
  end

  def onComboTextEnter(event)
    log_message("Enter pressed in the combobox: value is '%s'.",
                 @m_combo.get_value())
  end

  def onComboButtons(event)
    case event.get_id()
    when ID_COMBO_ENABLE
      @m_combo.enable( event.get_int() == 0 )
    when ID_COMBO_SEL_NUM
      @m_combo.set_selection( 2 )
    when ID_COMBO_SEL_STR
      @m_combo.set_string_selection( "This" )
    when ID_COMBO_CLEAR
      @m_combo.clear()
    when ID_COMBO_APPEND
      @m_combo.append( "Hi!" )
    when ID_COMBO_DELETE
      idx = @m_combo.get_selection()
      @m_combo.delete( idx )
    when ID_COMBO_FONT
      @m_combo.set_font( ITALIC_FONT )
    end
  end

  def onRadio(event)
    @m_text.append_text( "RadioBox selection string is: " )
    @m_text.append_text( event.get_string() )
    @m_text.append_text( "\n" )
  end

  def onRadioButtons(event)
    case event.get_id()
    when ID_RADIOBOX_ENABLE
      @m_radio.enable( event.get_int() == 0 )
    when ID_RADIOBOX_SEL_NUM
      @m_radio.set_selection( 2 )
    when ID_RADIOBOX_SEL_STR
      @m_radio.set_string_selection( "This" )
    when ID_RADIOBOX_FONT
      @m_radio.set_foreground_colour(GREEN)
      @m_radio.set_font( ITALIC_FONT )
    end
  end

  def onSetFont(event)
    @m_fontButton.set_font( ITALIC_FONT )
    @m_text.set_font( ITALIC_FONT )
  end

  def onupdateLabel(event)
    @m_label.set_label(event.get_int() != 0 ? "Very very very very very long text." : "Shorter text.")
  end

  def onSliderupdate(event)
    @m_gauge.set_value( @m_slider.get_value() )
    @m_gaugeVert.set_value( @m_slider.get_value() / 2 )
  end


  def onSpinCtrlText(event)
    if @m_spinctrl
      s = sprintf( "Spin ctrl text changed: now %d (from event: %s)\n",
                   @m_spinctrl.get_value(), event.get_string() )
      @m_text.append_text(s)
    end
  end

  def onSpinCtrl(event)
    if @m_spinctrl
      s = sprintf( "Spin ctrl changed: now %d (from event: %d)\n",
                   @m_spinctrl.get_value(), event.get_int() )
      @m_text.append_text(s)
    end
  end

  def onSpinCtrlUp(event)
    if @m_spinctrl
      @m_text.append_text( sprintf(
                                    "Spin up: %d (from event: %d)\n",
                                    @m_spinctrl.get_value(), event.get_int() ) )
    end
  end

  def onSpinCtrlDown(event)
    if @m_spinctrl
      @m_text.append_text( sprintf(
                                    "Spin down: %d (from event: %d)\n",
                                    @m_spinctrl.get_value(), event.get_int() ) )
    end
  end


  def onSpinUp(event)
    value = sprintf( "Spin control up: current = %d\n",
                     @m_spinbutton.get_value())

    if event.get_position() > 17
      value += "Preventing the spin button from going above 17.\n"
      event.veto()
    end

    @m_text.append_text(value)
  end

  def onSpinDown(event)
    value = sprintf( "Spin control down: current = %d\n",
                     @m_spinbutton.get_value())

    if event.get_position() < -17
      value += "Preventing the spin button from going below -17.\n"
      event.veto()
    end

    @m_text.append_text(value)
  end

  def onSpinupdate(event)
    value = sprintf( "%d", event.get_position() )
    @m_spintext.set_value( value )

    value = sprintf( "Spin control range: (%d, %d), current = %d\n",
                     @m_spinbutton.get_min(), @m_spinbutton.get_max(),
                     @m_spinbutton.get_value())

    @m_text.append_text(value)
  end

  def onupdateShowProgress(event)
    event.enable( @m_spinbutton.get_value() > 0 )
  end

  def onShowProgress(event)
    max = @m_spinbutton.get_value()
    if max <= 0
      log_error("You must set positive range!")
      return nil
    end

    cont = false
    ProgressDialog("Progress dialog example",
                   "An informative message",
                   max, # range
                   self, # parent
                   PD_CAN_ABORT |
                     PD_AUTO_HIDE |
                     PD_APP_MODAL |
                     PD_ELAPSED_TIME |
                     PD_ESTIMATED_TIME |
                     PD_REMAINING_TIME) do |dialog|
      cont = true
      0.upto(max) {|i|
        break if !cont
        sleep(1)
        if i == max
          cont = dialog.update(i, "That's all, folks!")
        elsif i == max / 2
          cont = dialog.update(i, "Only a half left (very long message)!")
        else
          cont = dialog.update(i)
        end
      }
    end
    if !cont
      @m_text << "Progress dialog aborted!\n"
    else
      @m_text << "Countdown from " << max << " finished.\n"
    end
  end

  def onSizerCheck(event)
    case event.get_id()
    when ID_SIZER_CHECK1
      @m_buttonSizer.show(@m_sizerBtn1, event.is_checked())
      @m_buttonSizer.layout()
    when ID_SIZER_CHECK2
      @m_buttonSizer.show(@m_sizerBtn2, event.is_checked())
      @m_buttonSizer.layout()
    when ID_SIZER_CHECK3
      @m_buttonSizer.show(@m_sizerBtn3, event.is_checked())
      @m_buttonSizer.layout()
    when ID_SIZER_CHECK4
      @m_buttonSizer.show(@m_sizerBtn4, event.is_checked())
      @m_buttonSizer.layout()
    when ID_SIZER_CHECK14
      @m_hsizer.show(@m_buttonSizer, event.is_checked())
      @m_hsizer.layout()
    when ID_SIZER_CHECKBIG
      @m_hsizer.show(@m_bigBtn, event.is_checked())
      @m_hsizer.layout()
    end
  end
end


class MyFrame < Frame
  def initialize(title,x,y)
    super(nil, -1, title, Point.new(x, y), Size.new(500, 430))

    @s_delay = 5000
    @s_enabled = true
    @s_enable2 = true
    @s_windowFocus = nil
    mondrian_icon = 
      case Wx::PLATFORM
      when  "WXMSW"
        Icon.new( File.join( File.dirname(__FILE__), "mondrian.ico"),
                  Wx::BITMAP_TYPE_ICO ) 
      else
        Icon.new( File.join( File.dirname(__FILE__), "mondrian.xpm"),
                  Wx::BITMAP_TYPE_XPM ) 
      end

    set_icon(mondrian_icon)

    file_menu = Menu.new

    file_menu.append(CONTROLS_CLEAR_LOG, "&clear log\tCtrl-L")
    file_menu.append_separator()
    file_menu.append(CONTROLS_ABOUT, "&About\tF1")
    file_menu.append_separator()
    file_menu.append(CONTROLS_QUIT, "E&xit\tAlt-X", "Quit controls sample")

    menu_bar = MenuBar.new
    menu_bar.append(file_menu, "&File")

    tooltip_menu = Menu.new
    tooltip_menu.append(CONTROLS_SET_TOOLTIP_DELAY, "Set &delay\tCtrl-D")
    tooltip_menu.append_separator()
    tooltip_menu.append(CONTROLS_ENABLE_TOOLTIPS, "&Toggle tooltips\tCtrl-T",
                         "enable/disable tooltips", ITEM_CHECK)
    tooltip_menu.check(CONTROLS_ENABLE_TOOLTIPS, true)
    menu_bar.append(tooltip_menu, "&Tooltips")

    panel_menu = Menu.new
    panel_menu.append(CONTROLS_ENABLE_ALL, "&Disable all\tCtrl-E",
                       "enable/disable all panel controls", ITEM_CHECK)
    menu_bar.append(panel_menu, "&Panel")

    set_menu_bar(menu_bar)

    create_status_bar(2)

    @m_panel = MyPanel.new( self, 10, 10, 300, 100 )

    set_size_hints( 500, 425 )

    evt_menu(CONTROLS_QUIT) {|event| onQuit(event) }
    evt_menu(CONTROLS_ABOUT) {|event| onAbout(event) }
    evt_menu(CONTROLS_CLEAR_LOG) {|event| onClearLog(event) }
    evt_menu(CONTROLS_SET_TOOLTIP_DELAY) {|event| onSetTooltipDelay(event) }
    evt_menu(CONTROLS_ENABLE_TOOLTIPS) {|event| onToggleTooltips(event) }
    evt_menu(CONTROLS_ENABLE_ALL) {|event| onenableAll(event) }

    evt_size() {|event| onSize(event) }
    evt_move() {|event| onMove(event) }
    evt_idle() {|event| onIdle(event) }
    evt_close() {|event| onClose(event) }
  end

  def onClose(event)
    Log::set_active_target(@m_panel.m_logTargetOld)
    destroy()
  end

  def onQuit(event)
    close(true)
  end

  def onAbout(event)
    BusyCursor.busy do
      Wx.MessageDialog(self, "This is a control sample", "About Controls", OK) { |dlg| dlg.show_modal }
    end
  end

  def onClearLog(event)
    @m_panel.m_text.clear()
  end

  def onSetTooltipDelay(event)
    delay = @s_delay.to_s

    delay = get_text_from_user("Enter delay (in milliseconds)",
                                "Set tooltip delay",
                                delay,
                                self)
    if !delay
      return Qnil # cancelled
    end

    @s_delay = delay.to_i

    ToolTip::set_delay(@s_delay)

    log_status(self, "Tooltip delay set to %d milliseconds", @s_delay)
  end

  def onToggleTooltips(event)
    @s_enabled = ! @s_enabled
    ToolTip::enable(@s_enabled)
    log_status(self, "Tooltips %sabled", @s_enabled ? "en" : "dis" )
  end

  def onenableAll(event)
    @s_enable2 = ! @s_enable2
    @m_panel.enable(@s_enable2)
  end

  def onMove(event)
    update_status_bar(event.get_position(), get_size())
    event.skip()
  end

  def onSize(event)
    update_status_bar(get_position(), event.get_size())
    event.skip()
  end

  def onIdle(event)
    # track the window which has the focus in the status bar
    focus = Window::find_focus()
    if focus && (focus != @s_windowFocus)
      @s_windowFocus = focus
      msg = sprintf( "Focus: %s @ %d",
                       @s_windowFocus.wx_class,
                       @s_windowFocus.object_id )
      set_status_text(msg)
    end
  end

  def GetPanel()
    @m_panel
  end

  def update_status_bar(pos,size)
    if get_status_bar()
      sizeAll = get_size()
      sizeCl = get_client_size()
      msg = sprintf("pos=(%d, %d), size=%dx%d or %dx%d (client=%dx%d)",
                     pos.x, pos.y,
                     size.width, size.height,
                     sizeAll.width, sizeAll.height,
                     sizeCl.width, sizeCl.height)
      set_status_text(msg, 1)
    end
  end

end

module ControlsSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby controls example.',
      description: 'wxRuby example demonstrating various common controls.' }
  end

  def self.activate
    # Create the main frame window
    frame = MyFrame.new("Controls Windows App", 50, 50)
    frame.show(true)
    frame
  end

  if $0 == __FILE__
    Wx::App.run { !!ControlsSample.activate }
  end

end
