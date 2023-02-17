###
# PropertyGrid extended sample
# Copyright (c) M.J.N. Corino, The Netherlands
###

begin
  require 'rubygems'
rescue LoadError
end
require 'wx'

require_relative './sample_props'

# -----------------------------------------------------------------------
# WxSampleMultiButtonEditor
#   A sample editor class that has multiple buttons.
# -----------------------------------------------------------------------

class WxSampleMultiButtonEditor < Wx::PG::PGTextCtrlEditor

  def initialize
    super
  end

  def create_controls(propGrid, property, pos, sz)
    # Create and populate buttons-subwindow
    buttons = Wx::PG::PGMultiButton.new(propGrid, sz)

    # Add two regular buttons
    buttons.add('...')
    buttons.add('A')
    # Add a bitmap button
    buttons.add(Wx::ArtProvider::get_bitmap(Wx::ART_FOLDER))

    # Create the 'primary' editor control (textctrl in this case)
    primary, _ = super(propGrid, property, pos, buttons.primary_size)

    # Finally, move buttons-subwindow to correct position and make sure
    # returned Wx::PG::PGWindowList contains our custom button list.
    buttons.finalize(propGrid, pos)

    [primary, buttons]
  end

  def on_event(propGrid, property, ctrl, event)
    if event.event_type == Wx::EVT_BUTTON
      buttons = propGrid.get_editor_control_secondary

      if event.id == buttons.button_id(0)

        # Do something when the first button is pressed
        Wx::log_info('First button pressed')
        return false # Return false since value did not change
      end
      if event.id == buttons.get_button_id(1)

        # Do something when the second button is pressed
        Wx.message_box('Second button pressed')
        return false # Return false since value did not change
      end
      if event.id == buttons.button_id(2)
        # Do something when the third button is pressed
        Wx.message_box('Third button pressed')
        return false # Return false since value did not change
      end
    end
    super(propGrid, property, ctrl, event)
  end

end # class WxSampleMultiButtonEditor

if Wx.has_feature?(:USE_VALIDATORS)

  class WxInvalidWordValidator < Wx::Validator

    def initialize(invalidWord)
      super()
      @invalidWord = invalidWord
    end

    def clone
      return WxInvalidWordValidator.new(@invalidWord)
    end

    def validate(parent_)
      tc = get_window
      raise 'validator window must be wxTextCtrl' unless Wx::TextCtrl === tc

      val = tc.value

      return true unless val.index(@invalidWord)

      Wx.message_box("%s is not allowed word" % @invalidWord,
                     "Validation Failure")
      false
    end

  end # class WxInvalidWordValidator

end

# -----------------------------------------------------------------------
# WxVectorProperty
# -----------------------------------------------------------------------

class WxVectorProperty < Wx::PG::PGProperty

  WxVector3f = Struct.new(:x, :y, :z) do |klass|
    def initialize
      self.x = self.y = self.z = 0.0
    end
  end

  def initialize(label = Wx::PG::PG_LABEL, name = Wx::PG::PG_LABEL, value = WxVector3f.new)
    super(label, name)
    self.value = value
    add_private_child(Wx::PG::FloatProperty.new("X",Wx::PG::PG_LABEL, value.x))
    add_private_child(Wx::PG::FloatProperty.new("Y",Wx::PG::PG_LABEL, value.y))
    add_private_child(Wx::PG::FloatProperty.new("Z",Wx::PG::PG_LABEL, value.z))
  end

  def child_changed(thisValue, childIndex, childValue)
    vector = thisValue.object;
    case childIndex
    when 0
      vector.x = childValue.to_f
    when 1
      vector.y = childValue.to_f
    when 2
      vector.z = childValue.to_f
    end
    Wx::Variant.new(vector)
  end

  def refresh_children
    return if get_child_count == 0
    vector = self.value_.object
    item(0).value = vector.x
    item(1).value = vector.y
    item(2).value = vector.z
  end

end # class WxVectorProperty

# -----------------------------------------------------------------------
# Wx::PG::TriangleProperty
# -----------------------------------------------------------------------

class WxTriangleProperty < Wx::PG::PGProperty

  WxTriangle = Struct.new(:a, :b, :c) do |klass|
    def initialize
      self.a = WxVectorProperty::WxVector3f.new
      self.b = WxVectorProperty::WxVector3f.new
      self.c = WxVectorProperty::WxVector3f.new
    end
  end

  def initialize(label = Wx::PG::PG_LABEL, name = Wx::PG::PG_LABEL, value = WxTriangle.new)
    super(label, name)
    self.value = value
    add_private_child(WxVectorProperty.new("A", Wx::PG::PG_LABEL, value.a.dup))
    add_private_child(WxVectorProperty.new("B", Wx::PG::PG_LABEL, value.b.dup))
    add_private_child(WxVectorProperty.new("C", Wx::PG::PG_LABEL, value.c.dup))
  end

  def child_changed(thisValue, childIndex, childValue)
    triangle = thisValue.object.dup
    vector = childValue.object.dup
    case childIndex
    when 0
      triangle.a = vector
    when 1
      triangle.b = vector
    when 2
      triangle.c = vector
    end
    Wx::Variant.new(triangle)
  end

  def refresh_children
    return if get_child_count == 0
    triangle = self.value_.object
    item(0).value = triangle.a
    item(1).value = triangle.b
    item(2).value = triangle.c
  end

end # class WxTriangleProperty


# -----------------------------------------------------------------------
# wxSingleChoiceDialogAdapter (Wx::PG::PGEditorDialogAdapter sample)
# -----------------------------------------------------------------------

class WxSingleChoiceDialogAdapter < Wx::PG::PGEditorDialogAdapter

  def initialize(choices)
    super()
    @choices = choices
  end

  def do_show_dialog(propGrid_, property_)
    s = Wx.get_single_choice("Message",
                             "Caption",
                             @choices.labels)
    unless s.empty?
      value = s
      return true
    end

    return false
  end

end # class WxSingleChoiceDialogAdapter

class SingleChoiceProperty < Wx::PG::StringProperty

  def initialize(label, name = Wx::PG::PG_LABEL, value = '')
    super(label, name, value)
    # Prepare choices
    @choices = Wx::PG::PGChoices.new
    @choices.add("Cat")
    @choices.add("Dog")
    @choices.add("Gibbon")
    @choices.add("Otter")
  end

  # Set editor to have button
  def do_get_editor_class
    Wx::PG::PG_EDITOR_TEXT_CTRL_AND_BUTTON
  end

  # Set what happens on button click
  def get_editor_dialog
    WxSingleChoiceDialogAdapter.new(@choices)
  end

end # class SingleChoiceProperty

#
# Test customizing wxColourProperty via subclassing
#
# * Includes custom colour entry.
# * Includes extra custom entry.
#
class MyColourProperty < Wx::PG::ColourProperty

  def initialize(label = Wx::PG::PG_LABEL,
                 name = Wx::PG::PG_LABEL,
                 value = Wx::WHITE )
    super(label, name, value)
    self.choices = Wx::PG::PGChoices.new(%w[White Black Red Green Blue Custom None])
    set_index(0)
    self.value = value
  end

  def get_colour(index)
    case index
    when 0
      return Wx::WHITE
    when 1
      return Wx::BLACK
    when 2
      return Wx::RED
    when 3
      return Wx::GREEN
    when 4
      return Wx::BLUE
    when 5
      # Return current colour for the custom entry
      if get_index == get_custom_colour_index
        return self.value_.colour unless self.value_.null?
      else
        return Wx::WHITE
      end
    end
    Wx::Colour.new
  end

  def colour_to_string(col, index, argFlags = 0)
    return '' if index == (self.choices.get_count-1)

    super(col, index, argFlags)
  end

  def get_custom_colour_index
    self.choices.get_count-2
  end
end

module ID
  %i[
    PGID
    ABOUT
    QUIT
    APPENDPROP
    APPENDCAT
    INSERTPROP
    INSERTCAT
    ENABLE
    SETREADONLY
    HIDE
    BOOL_CHECKBOX
    DELETE
    DELETER
    DELETEALL
    UNSPECIFY
    ITERATE1
    ITERATE2
    ITERATE3
    ITERATE4
    CLEARMODIF
    FREEZE
    DUMPLIST
    COLOURSCHEME1
    COLOURSCHEME2
    COLOURSCHEME3
    CATCOLOURS
    SETBGCOLOUR
    SETBGCOLOURRECUR
    STATICLAYOUT
    POPULATE1
    POPULATE2
    COLLAPSE
    COLLAPSEALL
    GETVALUES
    SETVALUES
    SETVALUES2
    RUNTESTFULL
    RUNTESTPARTIAL
    FITCOLUMNS
    CHANGEFLAGSITEMS
    TESTINSERTCHOICE
    TESTDELETECHOICE
    INSERTPAGE
    REMOVEPAGE
    SETSPINCTRLEDITOR
    SETPROPERTYVALUE
    TESTREPLACE
    SETCOLUMNS
    SETVIRTWIDTH
    SETPGDISABLED
    TESTXRC
    ENABLECOMMONVALUES
    SELECTSTYLE
    SAVESTATE
    RESTORESTATE
    RUNMINIMAL
    ENABLELABELEDITING
    VETOCOLDRAG
    ONEXTENDEDKEYNAV
    SHOWPOPUP
    POPUPGRID
  ].each_with_index { |sym, ix| self.const_set(sym, ix+1) }

  if Wx.has_feature?(:USE_HEADERCTRL)
    SHOWHEADER = POPUPGRID+1
  end

  COLOURSCHEME4 = 100
end

#
# Handle events of the third page here.
class WxMyPropertyGridPage < Wx::PG::PropertyGridPage

  def initialize
    super
    evt_pg_selected(Wx::ID_ANY, :on_property_select)
    evt_pg_changing(Wx::ID_ANY, :on_property_changing)
    evt_pg_changed(Wx::ID_ANY, :on_property_change)
    evt_pg_page_changed(Wx::ID_ANY, :on_page_change)
  end

  # Return false here to indicate unhandled events should be
  # propagated to manager's parent, as normal.
  def is_handling_all_events; false; end

  def do_insert(parent, index, property)
    super(parent,index,property)
  end

  def on_property_select(event)
    Wx.log_debug("WxMyPropertyGridPage#on_property_select('%s' is %s",
                 event.property.get_name,
                 (property_selected?(event.property) ? "selected": "unselected"))
  end
  def on_property_changing(event)
    Wx.log_verbose("WxMyPropertyGridPage#on_property_change('%s', to value '%s')",
                   event.property.get_name,
                   event.property.get_displayed_string)
  end
  def on_property_change(event)
    Wx.log_verbose("WxMyPropertyGridPage#on_property_changing('%s', to value '%s')",
                   event.property.get_name,
                   event.value.to_s)
  end
  def on_page_change(event)
    Wx.log_debug("WxMyPropertyGridPage#on_page_change()")
  end

end # class WxMyPropertyGridPage


class WxPGKeyHandler < Wx::EvtHandler

  def initialize
    super
    evt_key_down :on_key_event
  end

  def on_key_event(event)
    Wx.message_box("%i" % event.get_key_code)
    event.skip
  end

end

class FormMain < Wx::Frame

  FS_WINDOWSTYLE_LABELS = %w[
    wxSIMPLE_BORDER wxDOUBLE_BORDER wxSUNKEN_BORDER wxRAISED_BORDER wxNO_BORDER 
    wxTRANSPARENT_WINDOW wxTAB_TRAVERSAL wxWANTS_CHARS wxVSCROLL wxALWAYS_SHOW_SB 
    wxCLIP_CHILDREN wxFULL_REPAINT_ON_RESIZE]

  FS_WINDOWSTYLE_VALUES = [
    Wx::SIMPLE_BORDER,
    Wx::DOUBLE_BORDER,
    Wx::SUNKEN_BORDER,
    Wx::RAISED_BORDER,
    Wx::NO_BORDER,
    Wx::TRANSPARENT_WINDOW,
    Wx::TAB_TRAVERSAL,
    Wx::WANTS_CHARS,
    Wx::VSCROLL,
    Wx::ALWAYS_SHOW_SB,
    Wx::CLIP_CHILDREN,
    Wx::FULL_REPAINT_ON_RESIZE
  ]

  FS_FRAMESTYLE_LABELS = %w[
    wxCAPTION wxMINIMIZE wxMAXIMIZE wxCLOSE_BOX wxSTAY_ON_TOP wxSYSTEM_MENU
    wxRESIZE_BORDER wxFRAME_TOOL_WINDOW wxFRAME_NO_TASKBAR
    wxFRAME_FLOAT_ON_PARENT wxFRAME_SHAPED]

  FS_FRAMESTYLE_VALUES = [
    Wx::CAPTION,
    Wx::MINIMIZE,
    Wx::MAXIMIZE,
    Wx::CLOSE_BOX,
    Wx::STAY_ON_TOP,
    Wx::SYSTEM_MENU,
    Wx::RESIZE_BORDER,
    Wx::FRAME_TOOL_WINDOW,
    Wx::FRAME_NO_TASKBAR,
    Wx::FRAME_FLOAT_ON_PARENT,
    Wx::FRAME_SHAPED
  ]
  
  def initialize(title, pos, size)
    super(nil, title: title, pos: pos, size: size,
          style: (Wx::MINIMIZE_BOX|Wx::MAXIMIZE_BOX|Wx::RESIZE_BORDER|Wx::SYSTEM_MENU|
                  Wx::CAPTION|Wx::TAB_TRAVERSAL|Wx::CLOSE_BOX))
    @propGridManager = nil
    @propGrid = nil
    @hasHeader = false
    @labelEditingEnabled = false
    @combinedFlags = Wx::PG::PGChoices.new

    self.icon = Wx::Icon.new(local_icon_file('../sample.xpm'))
    centre

    # This is default in wxRuby
    # if Wx.has_feature?(:USE_IMAGE)
    #   # This is here to really test the Wx::PG::ImageFileProperty.
    #   wxInitAllImageHandlers()
    # end

    # Create menu bar
    menuFile = Wx::Menu.new('', Wx::MENU_TEAROFF)
    menuTry = Wx::Menu.new
    menuTools1 = Wx::Menu.new
    menuTools2 = Wx::Menu.new
    menuHelp = Wx::Menu.new

    menuHelp.append(ID::ABOUT, '&About', 'Show about dialog')

    menuTools1.append(ID::APPENDPROP, 'Append New Property')
    menuTools1.append(ID::APPENDCAT, "Append New Category\tCtrl-S")
    menuTools1.append_separator
    menuTools1.append(ID::INSERTPROP, "Insert New Property\tCtrl-I")
    menuTools1.append(ID::INSERTCAT, "Insert New Category\tCtrl-W")
    menuTools1.append_separator
    menuTools1.append(ID::DELETE, 'Delete Selected')
    menuTools1.append(ID::DELETER, 'Delete Random')
    menuTools1.append(ID::DELETEALL, 'Delete All')
    menuTools1.append_separator
    menuTools1.append(ID::SETBGCOLOUR, 'Set Bg Colour')
    menuTools1.append(ID::SETBGCOLOURRECUR, 'Set Bg Colour (Recursively)')
    menuTools1.append(ID::UNSPECIFY, 'Set Value to Unspecified')
    menuTools1.append_separator
    m_itemEnable = menuTools1.append(ID::ENABLE, 'Enable',
                                      'Toggles item\'s enabled state.')
    m_itemEnable.enable(false)
    menuTools1.append(ID::HIDE, 'Hide', 'Hides a property')
    menuTools1.append(ID::SETREADONLY, 'Set as Read-Only',
                       'Set property as read-only')

    menuTools2.append(ID::ITERATE1, 'Iterate Over Properties')
    menuTools2.append(ID::ITERATE2, 'Iterate Over Visible Items')
    menuTools2.append(ID::ITERATE3, 'Reverse Iterate Over Properties')
    menuTools2.append(ID::ITERATE4, 'Iterate Over Categories')
    menuTools2.append_separator
    menuTools2.append(ID::ONEXTENDEDKEYNAV, 'Extend Keyboard Navigation',
                       'This will set Enter to navigate to next property, '+
                       'and allows arrow keys to navigate even when in '+
                       'editor control.')
    menuTools2.append_separator
    menuTools2.append(ID::SETPROPERTYVALUE, 'Set Property Value')
    menuTools2.append(ID::CLEARMODIF, 'Clear Modified Status', 'Clears Wx::PG::PG_MODIFIED flag from all properties.')
    menuTools2.append_separator
    m_itemFreeze = menuTools2.append_check_item(ID::FREEZE, 'Freeze',
                                               'Disables painting, auto-sorting, etc.')
    menuTools2.append_separator
    menuTools2.append(ID::DUMPLIST, 'Display Values as wxVariant List', 'Tests GetAllValues method and wxVariant conversion.')
    menuTools2.append_separator
    menuTools2.append(ID::GETVALUES, 'Get Property Values', 'Stores all property values.')
    menuTools2.append(ID::SETVALUES, 'Set Property Values', 'Reverts property values to those last stored.')
    menuTools2.append(ID::SETVALUES2, 'Set Property Values 2', 'Adds property values that should not initially be as items (so new items are created).')
    menuTools2.append_separator
    menuTools2.append(ID::SAVESTATE, 'Save Editable State')
    menuTools2.append(ID::RESTORESTATE, 'Restore Editable State')
    menuTools2.append_separator
    menuTools2.append(ID::ENABLECOMMONVALUES, 'Enable Common Value',
                       'Enable values that are common to all properties, for selected property.')
    menuTools2.append_separator
    menuTools2.append(ID::COLLAPSE, 'Collapse Selected')
    menuTools2.append(ID::COLLAPSEALL, 'Collapse All')
    menuTools2.append_separator
    menuTools2.append(ID::INSERTPAGE, 'Add Page')
    menuTools2.append(ID::REMOVEPAGE, 'Remove Page')
    menuTools2.append_separator
    menuTools2.append(ID::FITCOLUMNS, 'Fit Columns')
    m_itemVetoDragging =
      menuTools2.append_check_item(ID::VETOCOLDRAG,
                                  'Veto Column Dragging')
    menuTools2.append_separator
    menuTools2.append(ID::CHANGEFLAGSITEMS, 'Change Children of FlagsProp')
    menuTools2.append_separator
    menuTools2.append(ID::TESTINSERTCHOICE, 'Test InsertPropertyChoice')
    menuTools2.append(ID::TESTDELETECHOICE, 'Test DeletePropertyChoice')
    menuTools2.append_separator
    menuTools2.append(ID::SETSPINCTRLEDITOR, 'Use SpinCtrl Editor')
    menuTools2.append(ID::TESTREPLACE, 'Test ReplaceProperty')

    menuTry.append(ID::SELECTSTYLE, 'Set Window Style',
                    'Select window style flags used by the grid.')
    menuTry.append_check_item(ID::ENABLELABELEDITING, 'Enable label editing',
                             'This calls wxPropertyGrid::MakeColumnEditable(0)')
    menuTry.check(ID::ENABLELABELEDITING, @labelEditingEnabled)
    if Wx.has_feature?(:USE_HEADERCTRL)
      menuTry.append_check_item(ID::SHOWHEADER,
                               'Enable header',
                               'This calls wxPropertyGridManager::ShowHeader()')
      menuTry.check(ID::SHOWHEADER, @hasHeader)
    end # USE_HEADERCTRL
    menuTry.append_separator
    menuTry.append_radio_item(ID::COLOURSCHEME1, 'Standard Colour Scheme')
    menuTry.append_radio_item(ID::COLOURSCHEME2, 'White Colour Scheme')
    menuTry.append_radio_item(ID::COLOURSCHEME3, '.NET Colour Scheme')
    menuTry.append_radio_item(ID::COLOURSCHEME4, 'Cream Colour Scheme')
    menuTry.append_separator
    m_itemCatColours = menuTry.append_check_item(ID::CATCOLOURS, 'Category Specific Colours',
                                                'Switches between category-specific cell colours and default scheme (actually done using SetPropertyTextColour and SetPropertyBackgroundColour).')
    menuTry.append_separator
    menuTry.append_check_item(ID::STATICLAYOUT, 'Static Layout',
                             'Switches between user-modifiable and static layouts.')
    menuTry.append_check_item(ID::BOOL_CHECKBOX, 'Render Boolean values as checkboxes',
                             'Renders Boolean values as checkboxes')
    menuTry.append(ID::SETCOLUMNS, 'Set Number of Columns')
    menuTry.append(ID::SETVIRTWIDTH, 'Set Virtual Width')
    menuTry.append_check_item(ID::SETPGDISABLED, 'Disable Grid')
    menuTry.append_separator
    menuTry.append(ID::TESTXRC, 'Display XRC sample')

    menuFile.append(ID::RUNMINIMAL, 'Run Minimal Sample')
    menuFile.append_separator
    menuFile.append(ID::RUNTESTFULL, 'Run Tests (full)')
    menuFile.append(ID::RUNTESTPARTIAL, 'Run Tests (fast)')
    menuFile.append_separator
    menuFile.append(ID::QUIT, "E&xit\tAlt-X", 'Quit this program')

    # Now append the freshly created menu to the menu bar...
    menuBar = Wx::MenuBar.new
    menuBar.append(menuFile, '&File')
    menuBar.append(menuTry, '&Try These!')
    menuBar.append(menuTools1, '&Basic')
    menuBar.append(menuTools2, '&Advanced')
    menuBar.append(menuHelp, '&Help')

    # ... and attach this menu bar to the frame
    self.menu_bar = menuBar

    if Wx.has_feature?(:USE_STATUSBAR)
      # create a status bar
      create_status_bar(1)
      set_status_text('')
    end # USE_STATUSBAR

    # this is default with wxRuby
    # Register all editors (SpinCtrl etc.)
    # wxPropertyGridInterface::RegisterAdditionalEditors()

    # Register our sample custom editors
    @sampleMultiButtonEditor =
      Wx::PG::PropertyGrid.register_editor_class(WxSampleMultiButtonEditor.new)

    @panel = Wx::Panel.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::TAB_TRAVERSAL)

    style = Wx::PG::PG_BOLD_MODIFIED |
      Wx::PG::PG_SPLITTER_AUTO_CENTER |
      Wx::PG::PG_AUTO_SORT |
      #Wx::PG::PG_HIDE_MARGIN|Wx::PG::PG_STATIC_SPLITTER |
      #Wx::PG::PG_TOOLTIPS |
      #Wx::PG::PG_HIDE_CATEGORIES |
      #Wx::PG::PG_LIMITED_EDITING |
      Wx::PG::PG_TOOLBAR |
      Wx::PG::PG_DESCRIPTION
    # extra style
    xtra_style = Wx::PG::PG_EX_MODE_BUTTONS |
      Wx::PG::PG_EX_MULTIPLE_SELECTION
      #| Wx::PG::PG_EX_AUTO_UNSPECIFIED_VALUES
      #| Wx::PG::PG_EX_GREY_LABEL_WHEN_DISABLED
      #| Wx::PG::PG_EX_HELP_AS_TOOLTIPS
    if Wx.has_feature?(:ALWAYS_NATIVE_DOUBLE_BUFFER)
      xtra_style |= Wx::PG::PG_EX_NATIVE_DOUBLE_BUFFERING
    end # ALWAYS_NATIVE_DOUBLE_BUFFER

    create_grid(style, xtra_style)
    
    @topSizer = Wx::BoxSizer.new(Wx::VERTICAL)

    @topSizer.add(@propGridManager, Wx::SizerFlags.new(1).expand)

    # Button for tab traversal testing
    btnSizer = Wx::BoxSizer.new(Wx::HORIZONTAL)
    btnSizer.add(Wx::Button.new(@panel, Wx::ID_ANY,
                               'Should be able to move here with Tab'),
                 Wx::SizerFlags.new(1).border(Wx::ALL, 10))
    btnSizer.add(Wx::Button.new(@panel, ID::SHOWPOPUP,
                               'Show Popup'),
                 Wx::SizerFlags.new(1).border(Wx::ALL, 10))
    @topSizer.add(btnSizer, Wx::SizerFlags.new(0).border(Wx::ALL, 5).expand)

    @panel.set_sizer(@topSizer)
    @topSizer.set_size_hints(@panel)

    @panel.layout

    if Wx.has_feature?(:USE_LOGWINDOW)
      # Create log window
      @logWindow = Wx::LogWindow.new(self, 'Log Messages', false)
      @logWindow.frame.move(position.x + size.width + 10,
                            position.y)
      @logWindow.show
    end

    evt_menu ID::QUIT, :on_close_click

    evt_menu ID::COLOURSCHEME1, :on_colour_scheme
    evt_menu ID::COLOURSCHEME2, :on_colour_scheme
    evt_menu ID::COLOURSCHEME3, :on_colour_scheme
    evt_menu ID::COLOURSCHEME4, :on_colour_scheme

    evt_menu ID::ABOUT, :on_about

  end

  #
  # Normally, wxPropertyGrid does not check whether item with identical
  # label already exists. However, since in this sample we use labels for
  # identifying properties, we have to be sure not to generate identical
  # labels.
  #
  def self.generate_unique_property_label(pg, base_label)
    count = -1;

    if pg.get_property_by_label(base_label)
      while true
        count += 1
        new_label = "%s%i" % [base_label,count]
        break unless pg.get_property_by_label(new_label)
      end
    end

    base_label = new_label if count >= 0

    base_label
  end

  # utility function to find an icon relative to this ruby script
  def local_icon_file(icon_name)
    File.join(File.dirname(__FILE__), icon_name)
  end

  def create_grid(style, extraStyle)
    #
    # This function (re)creates the property grid in our sample
    #

    if style == -1
      # default style
      style =  Wx::PG::PG_BOLD_MODIFIED |
        Wx::PG::PG_SPLITTER_AUTO_CENTER |
        Wx::PG::PG_AUTO_SORT |
        #Wx::PG::PG_HIDE_MARGIN|Wx::PG::PG_STATIC_SPLITTER |
        #Wx::PG::PG_TOOLTIPS |
        #Wx::PG::PG_HIDE_CATEGORIES |
        #Wx::PG::PG_LIMITED_EDITING |
        Wx::PG::PG_TOOLBAR |
        Wx::PG::PG_DESCRIPTION
    end
    if extraStyle == -1
        # default extra style
        extraStyle = Wx::PG::PG_EX_MODE_BUTTONS |
          Wx::PG::PG_EX_MULTIPLE_SELECTION
        #| Wx::PG::PG_EX_AUTO_UNSPECIFIED_VALUES
        #| Wx::PG::PG_EX_GREY_LABEL_WHEN_DISABLED
        #| Wx::PG::PG_EX_HELP_AS_TOOLTIPS
      if Wx.has_feature?(:ALWAYS_NATIVE_DOUBLE_BUFFER)
        extraStyle |= Wx::PG::PG_EX_NATIVE_DOUBLE_BUFFERING
      end # ALWAYS_NATIVE_DOUBLE_BUFFER
    end
    
    #
    # This shows how to combine two static choice descriptors
    @combinedFlags.add(FS_WINDOWSTYLE_LABELS, FS_WINDOWSTYLE_VALUES)
    @combinedFlags.add(FS_FRAMESTYLE_LABELS, FS_FRAMESTYLE_VALUES)

    pgman = @propGridManager =
      Wx::PG::PropertyGridManager.new(@panel,
                                      # Don't change this into wxID_ANY in the sample, or the
                                      # event handling will obviously be broken.
                                      ID::PGID, # wxID_ANY
                                      Wx::DEFAULT_POSITION,
                                      Wx::DEFAULT_SIZE,
                                      style)

    @propGrid = pgman.grid

    pgman.set_extra_style(extraStyle)

    # This is the default validation failure behaviour
    @propGridManager.set_validation_failure_behavior(Wx::PG::PG_VFB_MARK_CELL|Wx::PG::PG_VFB_SHOW_MESSAGEBOX)

    @propGridManager.grid.set_vertical_spacing(2)

    #
    # Set somewhat different unspecified value appearance
    cell = Wx::PG::PGCell.new
    cell.text = 'Unspecified'
    cell.set_fg_col(Wx::LIGHT_GREY)
    @propGrid.set_unspecified_value_appearance(cell)

    populate_grid

    @propGrid.make_column_editable(0, @labelEditingEnabled)
    @propGridManager.show_header(@hasHeader)
    @propGridManager.set_column_title(2, 'Units') if @hasHeader
  end

  def replace_grid(style, extraStyle)
    pgmanOld = @propGridManager;
    create_grid(style, extraStyle)
    @topSizer.replace(pgmanOld, @propGridManager)
    pgmanOld.destroy
    @propGridManager.set_focus
    @panel.layout
  end

  # These are used in CreateGrid(), and in tests to compose
  # grids for testing purposes.
  def populate_grid
    pgman = @propGridManager;
    pgman.add_page('Standard Items')

    populate_with_standard_items

    pgman.add_page('wxWidgets Library Config')

    populate_with_library_config

    myPage = WxMyPropertyGridPage.new
    myPage.append(Wx::PG::IntProperty.new("IntProperty", Wx::PG::PG_LABEL, 12345678))

    # Use WxMyPropertyGridPage (see above) to test the
    # custom wxPropertyGridPage feature.
    pgman.add_page("Examples", Wx::BitmapBundle.new, myPage)

    populate_with_examples
  end

  def populate_with_standard_items
    pgman = @propGridManager
    pg = pgman.get_page("Standard Items")

    # Append is ideal way to add items to wxPropertyGrid.
    pg.append(Wx::PG::PropertyCategory.new("Appearance", Wx::PG::PG_LABEL))

    pg.append(Wx::PG::StringProperty.new("Label", Wx::PG::PG_LABEL, get_title))
    pg.append(Wx::PG::FontProperty.new("Font", Wx::PG::PG_LABEL))
    pg.set_property_help_string("Font", "Editing this will change font used in the property grid.")

    pg.append(Wx::PG::SystemColourProperty.new("Margin Colour",Wx::PG::PG_LABEL,
                                               Wx::PG::ColourPropertyValue.new(pg.get_grid.get_margin_colour)))

    pg.append(Wx::PG::SystemColourProperty.new("Cell Colour",Wx::PG::PG_LABEL,
                                               pg.grid.get_cell_background_colour))
    pg.append(Wx::PG::SystemColourProperty.new("Cell Text Colour",Wx::PG::PG_LABEL,
                                               pg.grid.get_cell_text_colour))
    pg.append(Wx::PG::SystemColourProperty.new("Line Colour",Wx::PG::PG_LABEL,
                                               pg.grid.get_line_colour))
    pg.append(Wx::PG::FlagsProperty.new("Window Styles",Wx::PG::PG_LABEL,
                                        @combinedFlags, get_window_style))

    pg.append(Wx::PG::CursorProperty.new("Cursor",Wx::PG::PG_LABEL))

    pg.append(Wx::PG::PropertyCategory.new("Position","PositionCategory"))
    pg.set_property_help_string("PositionCategory", "Change in items in this category will cause respective changes in frame.")

    # Let's demonstrate 'Units' attribute here

    # Note that we use many attribute constants instead of strings here
    # (for instance, Wx::PG::PG_ATTR_MIN, instead of "min").
    # Using constant may reduce binary size.

    pg.append(Wx::PG::IntProperty.new("Height",Wx::PG::PG_LABEL,480))
    pg.set_property_attribute("Height", Wx::PG::PG_ATTR_MIN, 10)
    pg.set_property_attribute("Height", Wx::PG::PG_ATTR_MAX, 2048)
    pg.set_property_attribute("Height", Wx::PG::PG_ATTR_UNITS, "Pixels")

    # Set value to unspecified so that Hint attribute will be demonstrated
    pg.set_property_value_unspecified("Height")
    pg.set_property_attribute("Height", Wx::PG::PG_ATTR_HINT,
                             "Enter new height for window")

    # Difference between hint and help string is that the hint is shown in
    # an empty value cell, while help string is shown either in the
    # description text box, as a tool tip, or on the status bar.
    pg.set_property_help_string("Height",
        "This property uses attributes \"Units\" and \"Hint\".")

    pg.append(Wx::PG::IntProperty.new("Width",Wx::PG::PG_LABEL,640))
    pg.set_property_attribute("Width", Wx::PG::PG_ATTR_MIN, 10)
    pg.set_property_attribute("Width", Wx::PG::PG_ATTR_MAX, 2048)
    pg.set_property_attribute("Width", Wx::PG::PG_ATTR_UNITS, "Pixels")

    pg.set_property_value_unspecified("Width")
    pg.set_property_attribute("Width", Wx::PG::PG_ATTR_HINT,
                             "Enter new width for window")
    pg.set_property_help_string("Width",
        "This property uses attributes \"Units\" and \"Hint\".")

    pg.append(Wx::PG::IntProperty.new("X",Wx::PG::PG_LABEL,10))
    pg.set_property_attribute("X", Wx::PG::PG_ATTR_UNITS, "Pixels")
    pg.set_property_help_string("X", "This property uses \"Units\" attribute.")

    pg.append Wx::PG::IntProperty.new("Y",Wx::PG::PG_LABEL,10)
    pg.set_property_attribute("Y", Wx::PG::PG_ATTR_UNITS, "Pixels")
    pg.set_property_help_string("Y", "This property uses \"Units\" attribute.")

    disabledHelpString = "This property is simply disabled. In order to have label disabled as well, "+
      "you need to set Wx::PG::PG_EX_GREY_LABEL_WHEN_DISABLED using SetExtraStyle."

    pg.append(Wx::PG::PropertyCategory.new("Environment",Wx::PG::PG_LABEL))
    pg.append(Wx::PG::StringProperty.new("Operating System",Wx::PG::PG_LABEL, Wx.get_os_description))

    pg.append(Wx::PG::StringProperty.new("User Id",Wx::PG::PG_LABEL, Wx.get_user_id))
    pg.append(Wx::PG::DirProperty.new("User Home",Wx::PG::PG_LABEL, Wx.get_user_home))
    pg.append(Wx::PG::StringProperty.new("User Name",Wx::PG::PG_LABEL, Wx.get_user_name))

    # Disable some of them
    pg.disable_property("Operating System")
    pg.disable_property("User Id")
    pg.disable_property("User Name")

    pg.set_property_help_string("Operating System", disabledHelpString)
    pg.set_property_help_string("User Id", disabledHelpString)
    pg.set_property_help_string("User Name", disabledHelpString)

    pg.append(Wx::PG::PropertyCategory.new("More Examples",Wx::PG::PG_LABEL))

    pg.append(WxFontDataProperty.new("FontDataProperty", Wx::PG::PG_LABEL))
    pg.set_property_help_string("FontDataProperty",
        "This demonstrates Wx::PG::FontDataProperty class defined in this sample app. "+
        "It is exactly like Wx::PG::FontProperty from the library, but also has colour sub-property.")

    pg.append(WxDirsProperty.new("DirsProperty",Wx::PG::PG_LABEL))
    pg.set_property_help_string("DirsProperty",
        "This demonstrates Wx::PG::DirsProperty class defined in this sample app. "+
        "It is built with WX_PG_IMPLEMENT_ARRAYSTRING_PROPERTY_WITH_VALIDATOR macro, "+
        "with custom action (dir dialog popup) defined.")

    arrdbl = [
      -1.0,
      -0.5,
      0.0,
      0.5,
      1.0
    ]

    pg.append(WxArrayDoubleProperty.new("ArrayDoubleProperty",Wx::PG::PG_LABEL,arrdbl))
    pg.set_property_attribute("ArrayDoubleProperty",Wx::PG::PG_FLOAT_PRECISION,2)
    pg.set_property_help_string("ArrayDoubleProperty",
        "This demonstrates Wx::PG::ArrayDoubleProperty class defined in this sample app. "+
        "It is an example of a custom list editor property.")

    pg.append(Wx::PG::LongStringProperty.new("Information",Wx::PG::PG_LABEL,
        "Editing properties will have immediate effect on this window, "+
        "and vice versa (at least in most cases, that is)."))
    pg.set_property_help_string("Information",
                               "This property is read-only.")

    pg.set_property_read_only("Information", true)

    #
    # Set test information for cells in columns 3 and 4
    # (reserve column 2 for displaying units)
    bmp = Wx::ArtProvider.get_bitmap(Wx::ART_FOLDER)

    pg.grid.each_property do |p|
      continue if p.category?

      pg.set_property_cell(p, 3, "Cell 3", bmp)
      pg.set_property_cell(p, 4, "Cell 4", Wx::BitmapBundle.new, Wx::WHITE, Wx::BLACK)
    end
  end

  def populate_with_examples
    pgman = @propGridManager
    pg = pgman.get_page("Examples")

    if Wx.has_feature?(:USE_SPINBTN)
      pg.append(Wx::PG::IntProperty.new("SpinCtrl", Wx::PG::PG_LABEL, 0))

      pg.set_property_editor("SpinCtrl", Wx::PG::PG_EDITOR_SPIN_CTRL)
      pg.set_property_attribute("SpinCtrl", Wx::PG::PG_ATTR_MIN, -2)  # Use constants instead of string
      pg.set_property_attribute("SpinCtrl", Wx::PG::PG_ATTR_MAX, 16384)   # for reduced binary size.
      pg.set_property_attribute("SpinCtrl", Wx::PG::PG_ATTR_SPINCTRL_STEP, 2)
      pg.set_property_attribute("SpinCtrl", Wx::PG::PG_ATTR_SPINCTRL_MOTION, true)
      pg.set_property_attribute("SpinCtrl", Wx::PG::PG_ATTR_SPINCTRL_WRAP, true)
  
      pg.set_property_help_string("SpinCtrl",
                                 "This is regular Wx::PG::IntProperty, which editor has been "+
                                   "changed to Wx::PG::PGEditor_SpinCtrl. Note however that "+
                                   "static wxPropertyGrid::RegisterAdditionalEditors() "+
                                   "needs to be called prior to using it.")
    end

    # Add bool property
    pg.append(Wx::PG::BoolProperty.new("BoolProperty", Wx::PG::PG_LABEL, false))

    # Add bool property with check box
    pg.append(Wx::PG::BoolProperty.new("BoolProperty with CheckBox", Wx::PG::PG_LABEL, false))
    pg.set_property_attribute("BoolProperty with CheckBox",
                              Wx::PG::PG_BOOL_USE_CHECKBOX,
                              true)

    pg.set_property_help_string("BoolProperty with CheckBox",
                               "Property attribute Wx::PG::PG_BOOL_USE_CHECKBOX has been set to true.")

    prop = pg.append(Wx::PG::FloatProperty.new("FloatProperty",
                                           Wx::PG::PG_LABEL,
                                           1234500.23))
    prop.set_attribute(Wx::PG::PG_ATTR_MIN, -100.12)

    # A string property that can be edited in a separate editor dialog.
    pg.append(Wx::PG::LongStringProperty.new("LongStringProperty", "LongStringProp",
                                              "This is much longer string than the first one. Edit it by clicking the button."))

    # A property that edits a wxArrayString.
    example_array = [
      "String 1",
      "String 2",
      "String 3"
    ]
    pg.append(Wx::PG::ArrayStringProperty.new("ArrayStringProperty", Wx::PG::PG_LABEL,
                                           example_array))

    # A file selector property. Note that argument between name
    # and initial value is wildcard (format same as in wxFileDialog).
    prop = Wx::PG::FileProperty.new("FileProperty", "TextFile")
    pg.append(prop)

    prop.set_attribute(Wx::PG::PG_FILE_WILDCARD,"Text Files (*.txt)|*.txt")
    prop.set_attribute(Wx::PG::PG_DIALOG_TITLE,"Custom File Dialog Title")
    prop.set_attribute(Wx::PG::PG_FILE_SHOW_FULL_PATH,false)

    if Wx::PLATFORM == 'WXMSW'
      prop.set_attribute(Wx::PG::PG_FILE_SHOW_RELATIVE_PATH,"C:\\Windows")
      pg.set_property_value(prop,"C:\\Windows\\System32\\msvcrt71.dll")
    end

    if Wx.has_feature? :USE_IMAGE
      # An image file property. Arguments are just like for FileProperty, but
      # wildcard is missing (it is autogenerated from supported image formats).
      # If you really need to override it, create property separately, and call
      # its SetWildcard method.
      pg.append(Wx::PG::ImageFileProperty.new("ImageFile", Wx::PG::PG_LABEL))
    end

    pid = pg.append(Wx::PG::ColourProperty.new("ColourProperty",Wx::PG::PG_LABEL,Wx::RED))
    pg.set_property_editor("ColourProperty", Wx::PG::PG_EDITOR_COMBO_BOX)
    pg.get_property("ColourProperty").set_auto_unspecified(true)
    pg.set_property_help_string("ColourProperty",
                                "wxPropertyGrid::SetPropertyEditor method has been used to change "+
                                "editor of this property to Wx::PG::PGEditor_ComboBox)")

    pid = pg.append(Wx::PG::ColourProperty.new("ColourPropertyWithAlpha",
                                               Wx::PG::PG_LABEL,
                                               Wx::Colour.new(15, 200, 95, 128)))
    pg.set_property_attribute("ColourPropertyWithAlpha", Wx::PG::PG_COLOUR_HAS_ALPHA, true)
    pg.set_property_help_string("ColourPropertyWithAlpha",
                              "Attribute \"HasAlpha\" is set to true for this property.")

    #
    # This demonstrates using alternative editor for colour property
    # to trigger colour dialog directly from button.
    pg.append(Wx::PG::ColourProperty.new("ColourProperty2",Wx::PG::PG_LABEL,Wx::GREEN))

    #
    # Wx::PG::EnumProperty does not store strings or even list of strings
    # (so that's why they are static in function).
    enum_prop_labels = [
      "One Item",
      "Another Item",
      "One More",
      "This Is Last" ]

    # this value array would be optional if values matched string indexes
    enum_prop_values = [ 40, 80, 120, 160 ]

    # note that the initial value (the last argument) is the actual value,
    # not index or anything like that. Thus, our value selects "Another Item".
    pg.append(Wx::PG::EnumProperty.new("EnumProperty",Wx::PG::PG_LABEL,
                                       enum_prop_labels, enum_prop_values, 80))

    soc = Wx::PG::PGChoices.new

    # use basic table from our previous example
    # can also set/add wxArrayStrings and wxArrayInts directly.
    soc.set(enum_prop_labels, enum_prop_values)

    # add extra items
    soc.add("Look, it continues", 200)
    soc.add("Even More", 240)
    soc.add("And More", 280)
    soc.add('', 300)
    soc.add("True End of the List", 320)

    # Test custom colours ([] operator of Wx::PG::PGChoices returns
    # references to Wx::PG::PGChoiceEntry).
    soc[1].set_fg_col(Wx::RED)
    soc[1].set_bg_col(Wx::LIGHT_GREY)
    soc[2].set_fg_col(Wx::GREEN)
    soc[2].set_bg_col(Wx::LIGHT_GREY)
    soc[3].set_fg_col(Wx::BLUE)
    soc[3].set_bg_col(Wx::LIGHT_GREY)
    soc[4].set_bitmap(Wx::ArtProvider.get_bitmap(Wx::ART_FOLDER))

    pg.append(Wx::PG::EnumProperty.new("EnumProperty 2",
                                   Wx::PG::PG_LABEL,
                                   soc,
                                   240))
    pg.get_property("EnumProperty 2").add_choice("Testing Extra", 360)

    # Here we only display the original 'soc' choices
    pg.append(Wx::PG::EnumProperty.new("EnumProperty 3",Wx::PG::PG_LABEL,
        soc, 240))

    # Test Hint attribute in EnumProperty
    pg.get_property("EnumProperty 3").set_attribute(Wx::PG::PG_ATTR_HINT, "Dummy Hint")

    pg.set_property_help_string("EnumProperty 3",
        "This property uses \"Hint\" attribute.")

    # 'soc' plus one exclusive extra choice "4th only"
    pg.append(Wx::PG::EnumProperty.new("EnumProperty 4",Wx::PG::PG_LABEL,
        soc, 240))
    pg.get_property("EnumProperty 4").add_choice("4th only", 360)

    pg.set_property_help_string("EnumProperty 4",
        "Should have one extra item when compared to EnumProperty 3")

    # Plus property value bitmap
    pg.append(Wx::PG::EnumProperty.new("EnumProperty With Bitmap", "EnumProperty 5",
        soc, 280))
    pg.set_property_help_string("EnumProperty 5",
        "Should have bitmap in front of the displayed value")
    bmpVal = Wx::ArtProvider.get_bitmap(Wx::ART_REMOVABLE)
    pg.set_property_image("EnumProperty 5", bmpVal)

    # Password property example.
    pg.append(Wx::PG::StringProperty.new("Password",Wx::PG::PG_LABEL, "password"))
    pg.set_property_attribute("Password", Wx::PG::PG_STRING_PASSWORD, true)
    pg.set_property_help_string("Password",
        "Has attribute Wx::PG::PG_STRING_PASSWORD set to true")

    # String editor with dir selector button. Uses wxEmptyString as name, which
    # is allowed (naturally, in this case property cannot be accessed by name).
    pg.append(Wx::PG::DirProperty.new("DirProperty", Wx::PG::PG_LABEL, Wx.get_user_home))
    pg.set_property_attribute("DirProperty",
                              Wx::PG::PG_DIALOG_TITLE,
                              "This is a custom dir dialog title")

    # Add string property - first arg is label, second name, and third initial value
    pg.append(Wx::PG::StringProperty.new("StringProperty", Wx::PG::PG_LABEL))
    pg.set_property_max_length("StringProperty", 6)
    pg.set_property_help_string("StringProperty",
        "Max length of this text has been limited to 6, using wxPropertyGrid::SetPropertyMaxLength.")

    # Set value after limiting so that it will be applied
    pg.set_property_value("StringProperty", "some text")

    #
    # Demonstrate "AutoComplete" attribute
    pg.append(Wx::PG::StringProperty.new("StringProperty AutoComplete",
                                      Wx::PG::PG_LABEL))

    autoCompleteStrings = [
      "One choice",
      "Another choice",
      "Another choice, yeah",
      "Yet another choice",
      "Yet another choice, bear with me"
    ]
    pg.set_property_attribute("StringProperty AutoComplete",
                              Wx::PG::PG_ATTR_AUTOCOMPLETE,
                              autoCompleteStrings)

    pg.set_property_help_string("StringProperty AutoComplete",
        "AutoComplete attribute has been set for this property "+
        "(try writing something beginning with 'a', 'o' or 'y').")


    # Add string property with arbitrarily wide bitmap in front of it. We
    # intentionally lower-than-typical row height here so that the ugly
    # scaling code won't be run.
    pg.append(Wx::PG::StringProperty.new("StringPropertyWithBitmap",
                                      Wx::PG::PG_LABEL,
                                      "Test Text"))
    myTestBitmap1x = Wx::Bitmap.new(60, 15, 32)
    mdc = Wx::MemoryDC.new(myTestBitmap1x)
    mdc.set_background(Wx::WHITE_BRUSH)
    mdc.clear
    mdc.set_pen(Wx::BLACK_PEN)
    mdc.set_brush(Wx::WHITE_BRUSH)
    mdc.draw_rectangle(0, 0, 60, 15)
    mdc.draw_line(0, 0, 59, 14)
    mdc.set_text_foreground(Wx::BLACK)
    mdc.draw_text("x1", 0, 0)

    myTestBitmap2x = Wx::Bitmap.new(120, 30, 32)
    mdc = Wx::MemoryDC.new(myTestBitmap2x)
    mdc.set_background(Wx::WHITE_BRUSH)
    mdc.clear
    mdc.set_pen(Wx::Pen.new(Wx::BLUE, 2))
    mdc.set_brush(Wx::WHITE_BRUSH)
    mdc.draw_rectangle(0, 0, 120, 30)
    mdc.draw_line(0, 0, 119, 31)
    mdc.set_text_foreground(Wx::BLUE)
    f = mdc.font
    f.set_pixel_size(f.get_pixel_size * 2)
    mdc.set_font(f)
    mdc.draw_text("x2", 0, 0)

    myTestBitmap2x.set_scale_factor(2)
    pg.set_property_image("StringPropertyWithBitmap", Wx::BitmapBundle.from_bitmaps(myTestBitmap1x, myTestBitmap2x))

    # Multi choice dialog.
    tchoices = %w[Cabbage Carrot Onion Potato Strawberry]

    tchoicesValues = %w[Carrot Potato]

    pg.append(Wx::PG::EnumProperty.new("EnumProperty X",Wx::PG::PG_LABEL, tchoices))

    pg.append(Wx::PG::MultiChoiceProperty.new("MultiChoiceProperty", Wx::PG::PG_LABEL,
                                           tchoices, tchoicesValues))
    pg.set_property_attribute("MultiChoiceProperty", Wx::PG::PG_ATTR_MULTICHOICE_USERSTRINGMODE, 1)

    pg.append(WxSizeProperty.new("SizeProperty", "Size", get_size))
    pg.append(WxPointProperty.new("PointProperty", "Position", get_position))

    # UInt samples
    pg.append(Wx::PG::UIntProperty.new("UIntProperty", Wx::PG::PG_LABEL, 0xFEEEFEEEFEEE))
    pg.set_property_attribute("UIntProperty", Wx::PG::PG_UINT_PREFIX, Wx::PG::PG_PREFIX_NONE)
    pg.set_property_attribute("UIntProperty", Wx::PG::PG_UINT_BASE, Wx::PG::PG_BASE_HEX)
    #pg.set_property_attribute("UIntProperty", Wx::PG::PG_UINT_PREFIX, Wx::PG::PG_PREFIX_NONE)
    #pg.set_property_attribute("UIntProperty", Wx::PG::PG_UINT_BASE, Wx::PG::PG_BASE_OCT)

    #
    # Wx::PG::EditEnumProperty
    eech = Wx::PG::PGChoices.new([
      "Choice 1",
      "Choice 2",
      "Choice 3"
    ])
    pg.append(Wx::PG::EditEnumProperty.new("EditEnumProperty",
                                           Wx::PG::PG_LABEL,
                                           eech,
                                           "Choice not in the list"))

    # Test Hint attribute in EditEnumProperty
    pg.get_property("EditEnumProperty").set_attribute(Wx::PG::PG_ATTR_HINT, "Dummy Hint")

    #wxString v_;
    #wxTextValidator validator1(wxFILTER_NUMERIC,&v_)
    #pg.SetPropertyValidator("EditEnumProperty", validator1)

    if Wx.has_feature? :USE_DATETIME
      #
      # Wx::PG::DateTimeProperty
      pg.append(Wx::PG::DateProperty.new("DateProperty", Wx::PG::PG_LABEL, Time.now))

      if Wx.has_feature? :USE_DATEPICKCTRL
        pg.set_property_attribute("DateProperty", Wx::PG::PG_DATE_PICKER_STYLE,
                                  Wx::DP_DROPDOWN|Wx::DP_SHOWCENTURY|Wx::DP_ALLOWNONE)

        pg.set_property_help_string("DateProperty",
                                   "Attribute Wx::PG::PG_DATE_PICKER_STYLE has been set to (long)"+
                                     "(wxDP_DROPDOWN | wxDP_SHOWCENTURY | wxDP_ALLOWNONE).")
      end

    end

    #
    # Add Triangle properties as both Wx::PG::TriangleProperty and
    # a generic parent property (using Wx::PG::StringProperty).
    #
    topId = pg.append(Wx::PG::StringProperty.new("3D Object", Wx::PG::PG_LABEL, "<composed>"))

    pid = pg.append_in(topId, Wx::PG::StringProperty.new("Triangle 1", "Triangle 1", "<composed>"))
    pg.append_in(pid, WxVectorProperty.new("A", Wx::PG::PG_LABEL))
    pg.append_in(pid, WxVectorProperty.new("B", Wx::PG::PG_LABEL))
    pg.append_in(pid, WxVectorProperty.new("C", Wx::PG::PG_LABEL))

    pg.append_in(topId, WxTriangleProperty.new("Triangle 2", "Triangle 2"))

    pg.set_property_help_string("3D Object",
                               "3D Object is Wx::PG::StringProperty with value \"<composed>\". Two of its children are similar wxStringProperties with "+
                                 "three Wx::PG::VectorProperty children, and other two are custom wxTriangleProperties.")

    pid = pg.append_in(topId, Wx::PG::StringProperty.new("Triangle 3", "Triangle 3", "<composed>"))
    pg.append_in(pid, WxVectorProperty.new("A", Wx::PG::PG_LABEL))
    pg.append_in(pid, WxVectorProperty.new("B", Wx::PG::PG_LABEL))
    pg.append_in(pid, WxVectorProperty.new("C", Wx::PG::PG_LABEL))

    pg.append_in(topId, WxTriangleProperty.new("Triangle 4", "Triangle 4"))

    #
    # This snippet is a doc sample test
    #
    carProp = pg.append(Wx::PG::StringProperty.new("Car",
                                                   Wx::PG::PG_LABEL,
                                                   "<composed>"))

    pg.append_in(carProp, Wx::PG::StringProperty.new("Model",
                                               Wx::PG::PG_LABEL,
                                               "Lamborghini Diablo SV"))

    pg.append_in(carProp, Wx::PG::IntProperty.new("Engine Size (cc)",
                                            Wx::PG::PG_LABEL,
                                            5707))

    speedsProp = pg.append_in(carProp,
                              Wx::PG::StringProperty.new("Speeds",
                                                         Wx::PG::PG_LABEL,
                                                         "<composed>"))

    pg.append_in(speedsProp, Wx::PG::IntProperty.new("Max. Speed (mph)",
                                                Wx::PG::PG_LABEL,290))
    pg.append_in(speedsProp, Wx::PG::FloatProperty.new("0-100 mph (sec)",
                                                  Wx::PG::PG_LABEL,3.9))
    pg.append_in(speedsProp, Wx::PG::FloatProperty.new("1/4 mile (sec)",
                                                  Wx::PG::PG_LABEL,8.6))

    # This is how child property can be referred to by name
    pg.set_property_value("Car.Speeds.Max. Speed (mph)", 300)

    pg.append_in(carProp, Wx::PG::IntProperty.new("Price ($)",
                                            Wx::PG::PG_LABEL,
                                            300000))

    pg.append_in(carProp, Wx::PG::BoolProperty.new("Convertible",
                                             Wx::PG::PG_LABEL,
                                             false))

    # Displayed value of "Car" property is now very close to this:
    # "Lamborghini Diablo SV; 5707 [300; 3.9; 8.6] 300000"

    #
    # Test wxSampleMultiButtonEditor
    pg.append(Wx::PG::LongStringProperty.new("MultipleButtons", Wx::PG::PG_LABEL))
    pg.set_property_editor("MultipleButtons", @sampleMultiButtonEditor)

    # Test SingleChoiceProperty
    pg.append(SingleChoiceProperty.new("SingleChoiceProperty"))


    #
    # Test adding variable height bitmaps in Wx::PG::PGChoices
    bc = Wx::PG::PGChoices.new
    bc.add("Wee",
           Wx::ArtProvider.get_bitmap(Wx::ART_CDROM, Wx::ART_OTHER, [16, 16]))
    bc.add("Not so wee",
           Wx::ArtProvider.get_bitmap(Wx::ART_FLOPPY, Wx::ART_OTHER, [32, 32]))
    bc.add("Friggin' huge",
           Wx::ArtProvider.get_bitmap(Wx::ART_HARDDISK, Wx::ART_OTHER, [64, 64]))

    pg.append(Wx::PG::EnumProperty.new("Variable Height Bitmaps",
                                   Wx::PG::PG_LABEL,
                                   bc,
                                   0))

    #
    # Test how non-editable composite strings appear
    pid = Wx::PG::StringProperty.new("wxRuby Traits", Wx::PG::PG_LABEL, "<composed>")
    pg.set_property_read_only(pid)

    #
    # For testing purposes, combine two methods of adding children
    #

    pid.append_child(Wx::PG::StringProperty.new("Latest Release",
                                           Wx::PG::PG_LABEL,
                                           "3.0.0"))
    pid.append_child(Wx::PG::BoolProperty.new("Win API",
                                         Wx::PG::PG_LABEL,
                                         true))

    pg.append(pid)

    pg.append_in(pid, Wx::PG::BoolProperty.new("QT", Wx::PG::PG_LABEL, true))
    pg.append_in(pid, Wx::PG::BoolProperty.new("Cocoa", Wx::PG::PG_LABEL, true))
    pg.append_in(pid, Wx::PG::BoolProperty.new("Haiku", Wx::PG::PG_LABEL, false))
    pg.append_in(pid, Wx::PG::StringProperty.new("Trunk Version", Wx::PG::PG_LABEL, Wx::WXRUBY_VERSION))
    pg.append_in(pid, Wx::PG::BoolProperty.new("GTK+", Wx::PG::PG_LABEL, true))
    pg.append_in(pid, Wx::PG::BoolProperty.new("Android", Wx::PG::PG_LABEL, false))

    add_test_properties(pg)
  end

  def populate_with_library_config
    pgman = @propGridManager;
    pg = pgman.get_page("wxWidgets Library Config")

    # Set custom column proportions (here in the sample app we need
    # to check if the grid has wxPG_SPLITTER_AUTO_CENTER style. You usually
    # need not to do it in your application).
    if pgman.has_flag(Wx::PG::PG_SPLITTER_AUTO_CENTER)
      pg.set_column_proportion(0, 3)
      pg.set_column_proportion(1, 1)
    end

    bmp = Wx::ArtProvider.get_bitmap(Wx::ART_REPORT_VIEW)

    italicFont = pgman.grid.get_caption_font
    italicFont.set_style(Wx::FONTSTYLE_ITALIC)

    italicFontHelp = "Font of this property's wxPGCell has " +
      "been modified. Obtain property's cell " +
      "with wxPGProperty::" +
      "GetOrCreateCell(column)."

    pid = pg.append(Wx::PG::PropertyCategory.new("wxWidgets Library Configuration" ))
    pg.set_property_cell(pid, 0, Wx::PG::PG_LABEL, bmp)

    # Both of following lines would set a label for the second column
    pg.set_property_cell(pid, 1, "Is Enabled")
    pid.set_value("Is Enabled")

    _ADD_WX_LIB_CONF_GROUP = ->(label) {
      cat = pg.append_in(pid, Wx::PG::PropertyCategory.new(label))
      pg.set_property_cell(cat, 0, Wx::PG::PG_LABEL, bmp)
      cat.get_cell(0).set_font(italicFont)
      cat.set_help_string(italicFontHelp)
    }

    _ADD_WX_LIB_CONF = ->(sym) {
      pg.append(Wx::PG::BoolProperty.new(sym.to_s, Wx::PG::PG_LABEL, Wx.has_feature?(sym)))
    }

    _ADD_WX_LIB_CONF_NODEF = ->(sym) {
      pg.append(Wx::PG::BoolProperty.new(sym.to_s, Wx::PG::PG_LABEL, Wx.has_feature?(sym)))
      pg.disable_property(sym.to_s) unless Wx.has_feature?(sym)
    }

    _ADD_WX_LIB_CONF_GROUP.call("Global Settings")
    _ADD_WX_LIB_CONF.call(:USE_GUI)

    _ADD_WX_LIB_CONF_GROUP.call("Compatibility Settings")
    if Wx.has_feature?(:WXWIN_COMPATIBILITY_3_0)
      _ADD_WX_LIB_CONF.call(:WXWIN_COMPATIBILITY_3_0)
    end
    _ADD_WX_LIB_CONF_NODEF.call(:FONT_SIZE_COMPATIBILITY)
    _ADD_WX_LIB_CONF_NODEF.call(:DIALOG_UNIT_COMPATIBILITY)

    _ADD_WX_LIB_CONF_GROUP.call("Debugging Settings")
    _ADD_WX_LIB_CONF.call(:USE_DEBUG_CONTEXT)
    _ADD_WX_LIB_CONF.call(:USE_MEMORY_TRACING)
    _ADD_WX_LIB_CONF.call(:USE_GLOBAL_MEMORY_OPERATORS)
    _ADD_WX_LIB_CONF.call(:USE_DEBUG_NEW_ALWAYS)
    _ADD_WX_LIB_CONF.call(:USE_ON_FATAL_EXCEPTION)

    _ADD_WX_LIB_CONF_GROUP.call("Unicode Support")
    _ADD_WX_LIB_CONF.call(:USE_UNICODE)

    _ADD_WX_LIB_CONF_GROUP.call("Global Features")
    _ADD_WX_LIB_CONF.call(:USE_EXCEPTIONS)
    _ADD_WX_LIB_CONF.call(:USE_EXTENDED_RTTI)
    _ADD_WX_LIB_CONF.call(:USE_STL)
    _ADD_WX_LIB_CONF.call(:USE_LOG)
    _ADD_WX_LIB_CONF.call(:USE_LOGWINDOW)
    _ADD_WX_LIB_CONF.call(:USE_LOGGUI)
    _ADD_WX_LIB_CONF.call(:USE_LOG_DIALOG)
    _ADD_WX_LIB_CONF.call(:USE_CMDLINE_PARSER)
    _ADD_WX_LIB_CONF.call(:USE_THREADS)
    _ADD_WX_LIB_CONF.call(:USE_STREAMS)
    _ADD_WX_LIB_CONF.call(:USE_STD_IOSTREAM)

    _ADD_WX_LIB_CONF_GROUP.call("Non-GUI Features")
    _ADD_WX_LIB_CONF.call(:USE_LONGLONG)
    _ADD_WX_LIB_CONF.call(:USE_FILE)
    _ADD_WX_LIB_CONF.call(:USE_FFILE)
    _ADD_WX_LIB_CONF.call(:USE_FSVOLUME)
    _ADD_WX_LIB_CONF.call(:USE_TEXTBUFFER)
    _ADD_WX_LIB_CONF.call(:USE_TEXTFILE)
    _ADD_WX_LIB_CONF.call(:USE_INTL)
    _ADD_WX_LIB_CONF.call(:USE_DATETIME)
    _ADD_WX_LIB_CONF.call(:USE_TIMER)
    _ADD_WX_LIB_CONF.call(:USE_STOPWATCH)
    _ADD_WX_LIB_CONF.call(:USE_CONFIG)
    _ADD_WX_LIB_CONF_NODEF.call(:USE_CONFIG_NATIVE)
    _ADD_WX_LIB_CONF.call(:USE_DIALUP_MANAGER)
    _ADD_WX_LIB_CONF.call(:USE_DYNLIB_CLASS)
    _ADD_WX_LIB_CONF.call(:USE_DYNAMIC_LOADER)
    _ADD_WX_LIB_CONF.call(:USE_SOCKETS)
    _ADD_WX_LIB_CONF.call(:USE_FILESYSTEM)
    _ADD_WX_LIB_CONF.call(:USE_FS_ZIP)
    _ADD_WX_LIB_CONF.call(:USE_FS_INET)
    _ADD_WX_LIB_CONF.call(:USE_ZIPSTREAM)
    _ADD_WX_LIB_CONF.call(:USE_ZLIB)
    _ADD_WX_LIB_CONF.call(:USE_APPLE_IEEE)
    _ADD_WX_LIB_CONF.call(:USE_JOYSTICK)
    _ADD_WX_LIB_CONF.call(:USE_FONTMAP)
    _ADD_WX_LIB_CONF.call(:USE_MIMETYPE)
    _ADD_WX_LIB_CONF.call(:USE_PROTOCOL)
    _ADD_WX_LIB_CONF.call(:USE_PROTOCOL_FILE)
    _ADD_WX_LIB_CONF.call(:USE_PROTOCOL_FTP)
    _ADD_WX_LIB_CONF.call(:USE_PROTOCOL_HTTP)
    _ADD_WX_LIB_CONF.call(:USE_URL)
    _ADD_WX_LIB_CONF_NODEF.call(:USE_URL_NATIVE)
    _ADD_WX_LIB_CONF.call(:USE_REGEX)
    _ADD_WX_LIB_CONF.call(:USE_SYSTEM_OPTIONS)
    _ADD_WX_LIB_CONF.call(:USE_SOUND)
    _ADD_WX_LIB_CONF_NODEF.call(:USE_XRC)
    _ADD_WX_LIB_CONF.call(:USE_XML)

    # Set them to use check box.
    pg.set_property_attribute(pid, Wx::PG::PG_BOOL_USE_CHECKBOX, true, Wx::PG::PG_RECURSE)
  end

  def on_close_click(event)
    close(false)
  end

  def on_colour_scheme(event)
    id = event.id
    if id == ID::COLOURSCHEME1
      @propGridManager.grid.reset_colours
    elsif id == ID::COLOURSCHEME2
      # white
      my_grey_1 = Wx::Colour.new(212,208,200)
      my_grey_3 = Wx::Colour.new(113,111,100)
      @propGridManager.freeze
      @propGridManager.grid.set_margin_colour(Wx::WHITE)
      @propGridManager.grid.set_caption_background_colour(Wx::WHITE)
      @propGridManager.grid.set_cell_background_colour(Wx::WHITE)
      @propGridManager.grid.set_cell_text_colour(my_grey_3)
      @propGridManager.grid.set_line_colour(my_grey_1)
      @propGridManager.thaw
     elsif id == ID::COLOURSCHEME3
       # .NET
      my_grey_1 = Wx::Colour.new(212,208,200)
      my_grey_2 = Wx::Colour.new(236,233,216)
      @propGridManager.freeze
      @propGridManager.grid.set_margin_colour(my_grey_1)
      @propGridManager.grid.set_caption_background_colour(my_grey_1)
      @propGridManager.grid.set_line_colour(my_grey_1)
      @propGridManager.thaw
    elsif id == ID::COLOURSCHEME4
      # cream
      my_grey_1 = Wx::Colour.new(212,208,200)
      my_grey_2 = Wx::Colour.new(241,239,226)
      my_grey_3 = Wx::Colour.new(113,111,100)
       @propGridManager.freeze
       @propGridManager.grid.set_margin_colour(Wx::WHITE)
       @propGridManager.grid.set_caption_background_colour(Wx::WHITE)
       @propGridManager.grid.set_cell_background_colour(my_grey_2)
       @propGridManager.grid.set_cell_background_colour(my_grey_2)
       @propGridManager.grid.set_cell_text_colour(my_grey_3)
       @propGridManager.grid.set_line_colour(my_grey_1)
       @propGridManager.thaw
    end
  end

  def on_insert_prop_click(event) end

  def on_append_prop_click(event) end

  def on_clear_click(event) end

  def on_append_cat_click(event) end

  def on_insert_cat_click(event) end

  def on_del_prop_click(event) end

  def on_del_prop_r_click(event) end

  def on_context_menu(event) end

  def on_enable_disable(event) end

  def on_set_read_only(event) end

  def on_hide(event) end

  def on_bool_checkbox(evt) end

  def on_set_background_colour(event) end

  def on_clear_modify_status_click(event) end

  def on_freeze_click(event) end

  def on_enable_label_editing(event) end

  if Wx.has_feature?(:USE_HEADERCTRL)
    def on_show_header(event) end
  end

  def on_dump_list(event) end

  def on_cat_colours_update_ui(event) end

  def on_cat_colours(event) end

  def on_set_columns(event) end

  def on_set_virtual_width(evt) end

  def on_set_grid_disabled(evt) end

  def on_misc(event) end

  def on_populate_click(event) end

  def on_set_spin_ctrl_editor_click(event) end

  def on_test_replace_click(event) end

  def on_test_xrc(event) end

  def on_enable_common_values(event) end

  def on_select_style(event) end

  def on_fit_columns_click(event) end

  def on_change_flags_prop_items_click(event) end

  def on_save_to_file_click(event) end

  def on_load_from_file_click(event) end

  def on_set_property_value(event) end

  def on_insert_choice(event) end

  def on_delete_choice(event) end

  def on_insert_page(event) end

  def on_remove_page(event) end

  def on_save_state(event) end

  def on_restore_state(event) end

  def on_run_minimal_click(event) end

  def on_iterate1_click(event) end

  def on_iterate2_click(event) end

  def on_iterate3_click(event) end

  def on_iterate4_click(event) end

  def on_extended_key_nav(event) end

  def on_property_grid_change(event) end

  def on_property_grid_changing(event) end

  def on_property_grid_select(event) end

  def on_property_grid_highlight(event) end

  def on_property_grid_item_right_click(event) end

  def on_property_grid_item_double_click(event) end

  def on_property_grid_page_change(event) end

  def on_property_grid_button_click(event) end

  def on_property_grid_text_update(event) end

  def on_property_grid_key_event(event) end

  def on_property_grid_item_collapse(event) end

  def on_property_grid_item_expand(event) end

  def on_property_grid_label_edit_begin(event) end

  def on_property_grid_label_edit_ending(event) end

  def on_property_grid_col_begin_drag(event) end

  def on_property_grid_col_dragging(event) end

  def on_property_grid_col_end_drag(event) end

  def on_about(event)
    toolkit = "%s %i.%i.%i" % [Wx::PlatformInfo.get_port_id_name,
                               Wx::PlatformInfo.get_toolkit_major_version,
                               Wx::PlatformInfo.get_toolkit_minor_version,
                               Wx::PlatformInfo.get_toolkit_micro_version]
    msg = ("wxRuby PropertyGrid Sample" +
    if Wx.has_feature? :USE_UNICODE
      if Wx.has_feature?(:USE_UNICODE_UTF8) && Wx.has_feature?(:USE_UNICODE_UTF8)
        " <utf-8>"
      else
        " <unicode>"
      end
    else
      " <ansi>"
    end +
    if Wx::RB_DEBUG
      " <debug>"
    else
      " <release>"
    end +
    "\n\n" +
    "Programmed by %s\n\n" +
    "Using wxRuby %s (%s; %s)\n\n") %
      ["Martin Corino (C++ original by Jaakko Salli)", Wx::WXRUBY_VERSION, Wx::WXWIDGETS_VERSION_STRING, toolkit]

    Wx.message_box(msg, "About", Wx::OK | Wx::ICON_INFORMATION, self)
  end

  def on_move(event) end

  def on_resize(event) end

  def on_paint(event) end

  def on_close_event(event) end

  def on_idle(event) end

  def on_show_popup(event) end

  def add_test_properties(pg)
    pg.append(MyColourProperty.new("CustomColourProperty", Wx::PG::PG_LABEL, Wx::GREEN))
    pg.get_property("CustomColourProperty").set_auto_unspecified(true)
    pg.set_property_editor("CustomColourProperty", Wx::PG::PG_EDITOR_COMBO_BOX)

    pg.set_property_help_string("CustomColourProperty",
                             "This is a MyColourProperty from the sample app. "+
                               "It is built by subclassing wxColourProperty.")
  end

  def run_tests(fullTest, interactive = false) end

end

Wx::App.run do
  frameSize = Wx::Size.new((Wx::SystemSettings.get_metric(Wx::SYS_SCREEN_X) / 10) * 4,
                           (Wx::SystemSettings.get_metric(Wx::SYS_SCREEN_Y) / 10) * 8)
  frameSize.width = 500 if frameSize.width > 500

  frame = FormMain.new("wxPropertyGrid Sample", [0,0], frameSize)
  frame.show(true)

  #
  # Parse command-line
  if ARGV.size>0 && ARGV[0] == '--run-tests'
    #
    # Run tests
    return false if (testResult = frame.run_tests(true))
  end

  true
end
