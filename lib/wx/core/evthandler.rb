# All classes which are capable of handling events inherit from
# EvtHandler. This includes all Wx::Window subclasses and Wx::App.

class Wx::EvtHandler
  # EventType is an internal class that's used to set up event handlers
  # and mappings.
  # * 'name' is the name of the event handler method in ruby
  # * 'arity' is the number of id arguments that method should accept
  # * 'const' is the Wx EventType constant that identifies the event
  # * 'evt_class' is the WxRuby event class which is passed to the event
  #    handler block
  #
  # NB: Some event types currently pass a Wx::Event into the event
  # handler block; when the appropriate classes are added to wxRuby, the
  # binding can be updated here.
  EventType = Struct.new(:name, :arity, :const, :evt_class)

  # Fast look-up hash to map event type ids to ruby event classes
  EVENT_TYPE_CLASS_MAP = {}
  # Hash to look up EVT constants from symbol names of evt handler
  # methods; used internally by disconnect (see EvtHandler.i)
  EVENT_NAME_TYPE_MAP = {}

  # Given a Wx EventType id (eg Wx::EVT_MENU), returns a WxRuby Event
  # class which should be passed to event handler blocks. The actual
  # EVT_XXX constants themselves are in the compiled library, defined in
  # swig/classes/Event.i
  def self.event_class_for_type(id)
    if evt_klass = EVENT_TYPE_CLASS_MAP[id]
      return evt_klass
    else
      if Wx::DEBUG
        warn "No event class defined for event type #{id}"
      end
      return Wx::Event
    end
  end

  # Given the symbol name of an evt_xxx handler method, returns the
  # Integer Wx::EVT_XXX constant associated with that handler.
  def self.event_type_for_name(name)
    EVENT_NAME_TYPE_MAP[name]
  end

  # Given the Integer constant Wx::EVT_XXX, returns the convenience
  # handler method name associated with that type of event.
  def self.event_name_for_type(name)
    EVENT_NAME_TYPE_MAP.index(name)
  end

  # Given an integer value +int_val+, returns the name of the EVT_xxx
  # constant which points to it. Mainly useful for debugging.
  def self.const_to_name(int_val)
    Wx::constants.grep(/^EVT/).find do | c_name |
      Wx::const_get(c_name) == int_val
    end
  end

  # Public method to register the mapping of a custom event type
  # +konstant+ (which should be a unique integer; one will be created if
  # not supplied) to a custom event class +klass+. If +meth+ and +arity+
  # are given, a convenience evt_handler method called +meth+ will be
  # created, which accepts +arity+ arguments.
  def self.register_class( klass, konstant = nil,
                           meth = nil, arity = nil)
    konstant ||= Wx::Event.new_event_type
    unless klass < Wx::Event
      Kernel.raise TypeError, "Event class should be a subclass of Wx::Event"
    end
    ev_type = EventType.new(meth, arity, konstant, klass)
    register_event_type(ev_type)
    return konstant
  end

  # Registers the event type +ev_type+, which should be an instance of
  # the Struct class +Wx::EvtHandler::EventType+. This sets up the
  # mapping of events of that type (identified by integer id) to the
  # appropriate ruby event class, and defines a convenience evt_xxx
  # instance method in the class EvtHandler.
  def self.register_event_type(ev_type)
    # set up the event type mapping
    EVENT_TYPE_CLASS_MAP[ev_type.const] = ev_type.evt_class
    EVENT_NAME_TYPE_MAP[ev_type.name.intern] = ev_type.const

    unless ev_type.arity and ev_type.name
      return
    end

    # set up the evt_xxx method
    case ev_type.arity
    when 0 # events without an id
      class_eval %Q|
        def #{ev_type.name}(meth = nil, &block)
          handler = acquire_handler(meth, block)
          connect(Wx::ID_ANY, Wx::ID_ANY, #{ev_type.const}, handler)
        end |
    when 1 # events with an id
      class_eval %Q|
        def #{ev_type.name}(id, meth = nil, &block)
          handler = acquire_handler(meth, block)
          id  = acquire_id(id)
          connect(id, Wx::ID_ANY, #{ev_type.const}, handler)
        end |
    when 2 # events with id range
      class_eval %Q|
        def #{ev_type.name}(first_id, last_id, meth = nil, &block)
          handler  = acquire_handler(meth, block)
          first_id = acquire_id(first_id)
          last_id  = acquire_id(last_id)
          connect(first_id, last_id, #{ev_type.const}, handler)
        end |
    end
  end

  # Not for external use; determines whether to use a block or call a
  # method in self to handle an event, passed to connect. Makes evt_xxx
  # liberal about what it accepts - aside from a block, it can be a
  # method name (as Symbol or String), a (bound) method object, or a
  # Proc object
  def acquire_handler(meth, block)
    if block and not meth
      return block
    elsif meth and not block
      h_meth = case meth
               when Symbol, String then self.method(meth)
               when Proc then meth
               when Method then meth
               end
      # check arity <= 1
      if h_meth.arity>1
        Kernel.raise ArgumentError,
                     "Event handler should not accept more than at most a single argument"
                     caller
      end
      # wrap method without any argument in anonymous proc to prevent strict argument checking
      if Method === h_meth && h_meth.arity == 0
        Proc.new { h_meth.call }
      else
        h_meth
      end
    else
      Kernel.raise ArgumentError,
                  "Specify event handler with a method, name, proc OR block"
                  caller
    end
  end

  # Not for external use; acquires an id either from an explicit Fixnum
  # parameter or by calling the wx_id method of a passed Window.
  def acquire_id(window_or_id)
    case window_or_id
    when ::Integer
      window_or_id
    when Wx::Window, Wx::MenuItem, Wx::ToolBarTool, Wx::Timer
      window_or_id.wx_id
    else
      Kernel.raise ArgumentError,
                   "Must specify Wx::Window event source or its Wx id, " +
                   "not '#{window_or_id.inspect}'",
                   caller
    end
  end
  private :acquire_id, :acquire_handler

  # Definitions for all event types that are part by core wxRuby. Events
  # that are mapped to class Wx::Event are TODO as they are not
  # currently wrapped by the correct class.

=begin
  # All StyledTextCtrl (Scintilla) events with prefix EVT_STC are dealt
  # with in the separate styledtextctrl.rb file.
  #
  # All MediaCtrl events with prefix EVT_MEDIA are dealt with in the
  # separate mediactrl.rb file
  EVENT_DEFINITIONS = [
    # EventType['evt_activate', 0,
    #           Wx::EVT_ACTIVATE,
    #           Wx::ActivateEvent],
    # EventType['evt_activate_app', 0,
    #           Wx::EVT_ACTIVATE_APP,
    #           Wx::ActivateEvent],
    # EventType['evt_auinotebook_allow_dnd', 1,
    #           Wx::EVT_COMMAND_AUINOTEBOOK_ALLOW_DND,
    #           Wx::AuiNotebookEvent],
    # EventType['evt_auinotebook_begin_drag', 1,
    #           Wx::EVT_COMMAND_AUINOTEBOOK_BEGIN_DRAG,
    #           Wx::AuiNotebookEvent],
    # EventType['evt_auinotebook_bg_dclick', 1,
    #           Wx::EVT_COMMAND_AUINOTEBOOK_BG_DCLICK,
    #           Wx::AuiNotebookEvent],
    # EventType['evt_auinotebook_button', 1,
    #           Wx::EVT_COMMAND_AUINOTEBOOK_BUTTON,
    #           Wx::AuiNotebookEvent],
    # EventType['evt_auinotebook_drag_motion', 1,
    #           Wx::EVT_COMMAND_AUINOTEBOOK_DRAG_MOTION,
    #           Wx::AuiNotebookEvent],
    # EventType['evt_auinotebook_drag_done', 1,
    #           Wx::EVT_COMMAND_AUINOTEBOOK_DRAG_DONE,
    #           Wx::AuiNotebookEvent],
    # EventType['evt_auinotebook_end_drag', 1,
    #           Wx::EVT_COMMAND_AUINOTEBOOK_END_DRAG,
    #           Wx::AuiNotebookEvent],
    # EventType['evt_auinotebook_page_changed', 1,
    #           Wx::EVT_COMMAND_AUINOTEBOOK_PAGE_CHANGED,
    #           Wx::AuiNotebookEvent],
    # EventType['evt_auinotebook_page_changing', 1,
    #           Wx::EVT_COMMAND_AUINOTEBOOK_PAGE_CHANGING,
    #           Wx::AuiNotebookEvent],
    # EventType['evt_auinotebook_page_close', 1,
    #           Wx::EVT_COMMAND_AUINOTEBOOK_PAGE_CLOSE,
    #           Wx::AuiNotebookEvent],
    # EventType['evt_auinotebook_page_closed', 1,
    #           Wx::EVT_COMMAND_AUINOTEBOOK_PAGE_CLOSED,
    #           Wx::AuiNotebookEvent],
    # EventType['evt_auinotebook_tab_middle_down', 1,
    #           Wx::EVT_COMMAND_AUINOTEBOOK_TAB_MIDDLE_DOWN,
    #           Wx::AuiNotebookEvent],
    # EventType['evt_auinotebook_tab_middle_up', 1,
    #           Wx::EVT_COMMAND_AUINOTEBOOK_TAB_MIDDLE_UP,
    #           Wx::AuiNotebookEvent],
    # EventType['evt_auinotebook_tab_right_down', 1,
    #           Wx::EVT_COMMAND_AUINOTEBOOK_TAB_RIGHT_DOWN,
    #           Wx::AuiNotebookEvent],
    # EventType['evt_auinotebook_tab_right_up', 1,
    #           Wx::EVT_COMMAND_AUINOTEBOOK_TAB_RIGHT_UP,
    #           Wx::AuiNotebookEvent],
    # EventType['evt_aui_find_manager', 0,
    #           Wx::EVT_AUI_FIND_MANAGER,
    #           Wx::AuiManagerEvent],
    # EventType['evt_aui_pane_button', 0,
    #           Wx::EVT_AUI_PANE_BUTTON,
    #           Wx::AuiManagerEvent],
    # EventType['evt_aui_pane_close', 0,
    #           Wx::EVT_AUI_PANE_CLOSE,
    #           Wx::AuiManagerEvent],
    # EventType['evt_aui_pane_maximize', 0,
    #           Wx::EVT_AUI_PANE_MAXIMIZE,
    #           Wx::AuiManagerEvent],
    # EventType['evt_aui_pane_restore', 0,
    #           Wx::EVT_AUI_PANE_RESTORE,
    #           Wx::AuiManagerEvent],
    # EventType['evt_aui_render', 0,
    #           Wx::EVT_AUI_RENDER,
    #           Wx::AuiManagerEvent],
    # EventType['evt_bookctrl_page_changed', 1,
    #           Wx::EVT_COMMAND_BOOKCTRL_PAGE_CHANGED,
    #           Wx::BookCtrlBaseEvent],
    # EventType['evt_bookctrl_page_changing', 1,
    #           Wx::EVT_COMMAND_BOOKCTRL_PAGE_CHANGING,
    #           Wx::BookCtrlBaseEvent],
    EventType['evt_button', 1,
              Wx::EVT_COMMAND_BUTTON_CLICKED,
              Wx::CommandEvent],
    # EventType['evt_calculate_layout', 0,
    #           Wx::EVT_CALCULATE_LAYOUT,
    #           Wx::CalculateLayoutEvent],
    # EventType['evt_calendar', 1,
    #           Wx::EVT_CALENDAR_DOUBLECLICKED,
    #           Wx::CalendarEvent],
    # EventType['evt_calendar_day', 1,
    #           Wx::EVT_CALENDAR_DAY_CHANGED,
    #           Wx::CalendarEvent],
    # EventType['evt_calendar_month', 1,
    #           Wx::EVT_CALENDAR_MONTH_CHANGED,
    #           Wx::CalendarEvent],
    # EventType['evt_calendar_sel_changed', 1,
    #           Wx::EVT_CALENDAR_SEL_CHANGED,
    #           Wx::CalendarEvent],
    # EventType['evt_calendar_weekday_clicked', 1,
    #           Wx::EVT_CALENDAR_WEEKDAY_CLICKED,
    #           Wx::CalendarEvent],
    # EventType['evt_calendar_year', 1,
    #           Wx::EVT_CALENDAR_YEAR_CHANGED,
    #           Wx::CalendarEvent],
    # EventType['evt_char', 0,
    #           Wx::EVT_CHAR,
    #           Wx::KeyEvent],
    # EventType['evt_char_hook', 0,
    #           Wx::EVT_CHAR_HOOK,
    #           Wx::KeyEvent],
    EventType['evt_checkbox', 1,
              Wx::EVT_COMMAND_CHECKBOX_CLICKED,
              Wx::CommandEvent],
    EventType['evt_checklistbox', 1,
              Wx::EVT_COMMAND_CHECKLISTBOX_TOGGLED,
              Wx::CommandEvent],
    # EventType['evt_child_focus', 0,
    #           Wx::EVT_CHILD_FOCUS,
    #           Wx::ChildFocusEvent],
    EventType['evt_choice', 1,
              Wx::EVT_COMMAND_CHOICE_SELECTED,
              Wx::CommandEvent],
    # EventType['evt_choicebook_page_changed', 1,
    #           Wx::EVT_COMMAND_CHOICEBOOK_PAGE_CHANGED,
    #           Wx::ChoicebookEvent],
    # EventType['evt_choicebook_page_changing', 1,
    #           Wx::EVT_COMMAND_CHOICEBOOK_PAGE_CHANGING,
    #           Wx::ChoicebookEvent],
    # EventType['evt_close', 0,
    #           Wx::EVT_CLOSE_WINDOW,
    #           Wx::CloseEvent],
    # EventType['evt_collapsiblepane_changed', 1,
    #           Wx::EVT_COMMAND_COLLPANE_CHANGED,
    #           Wx::CollapsiblePaneEvent],
    EventType['evt_combobox', 1,
              Wx::EVT_COMMAND_COMBOBOX_SELECTED,
              Wx::CommandEvent],
    EventType['evt_command_enter', 1,
              Wx::EVT_COMMAND_ENTER,
              Wx::CommandEvent],
    EventType['evt_command_kill_focus', 1,
              Wx::EVT_COMMAND_KILL_FOCUS,
              Wx::CommandEvent],
    EventType['evt_command_left_click', 1,
              Wx::EVT_COMMAND_LEFT_CLICK,
              Wx::CommandEvent],
    EventType['evt_command_left_dclick', 1,
              Wx::EVT_COMMAND_LEFT_DCLICK,
              Wx::CommandEvent],
    EventType['evt_command_right_click', 1,
              Wx::EVT_COMMAND_RIGHT_CLICK,
              Wx::CommandEvent],
    EventType['evt_command_set_focus', 1,
              Wx::EVT_COMMAND_SET_FOCUS,
              Wx::CommandEvent],
    # EventType['evt_context_menu', 0,
    #           Wx::EVT_CONTEXT_MENU,
    #           Wx::ContextMenuEvent],
    # EventType['evt_date_changed', 1,
    #           Wx::EVT_DATE_CHANGED,
    #           Wx::DateEvent],
    # EventType['evt_detailed_help', 1,
    #           Wx::EVT_DETAILED_HELP,
    #           Wx::HelpEvent],
    # EventType['evt_detailed_help_range', 2,
    #           Wx::EVT_DETAILED_HELP,
    #           Wx::HelpEvent],
    EventType['evt_drop_files', 0,
              Wx::EVT_DROP_FILES,
              Wx::Event],
    # EventType['evt_end_process', 1,
    #           Wx::EVT_END_PROCESS,
    #           Wx::Event],
    EventType['evt_end_session', 0,
              Wx::EVT_END_SESSION,
              Wx::Event],
    # EventType['evt_enter_window', 0,
    #           Wx::EVT_ENTER_WINDOW,
    #           Wx::MouseEvent],
    # EventType['evt_erase_background', 0,
    #           Wx::EVT_ERASE_BACKGROUND,
    #           Wx::EraseEvent],
    # EventType['evt_find', 1,
    #           Wx::EVT_COMMAND_FIND,
    #           Wx::FindDialogEvent],
    # EventType['evt_find_close', 1,
    #           Wx::EVT_COMMAND_FIND_CLOSE,
    #           Wx::FindDialogEvent],
    # EventType['evt_find_next', 1,
    #           Wx::EVT_COMMAND_FIND_NEXT,
    #           Wx::FindDialogEvent],
    # EventType['evt_find_replace', 1,
    #           Wx::EVT_COMMAND_FIND_REPLACE,
    #           Wx::FindDialogEvent],
    # EventType['evt_find_replace_all', 1,
    #           Wx::EVT_COMMAND_FIND_REPLACE_ALL,
    #           Wx::FindDialogEvent],
    # EventType['evt_grid_cell_change', 0,
    #           Wx::EVT_GRID_CELL_CHANGE,
    #           Wx::GridEvent],
    # EventType['evt_grid_cell_left_click', 0,
    #           Wx::EVT_GRID_CELL_LEFT_CLICK,
    #           Wx::GridEvent],
    # EventType['evt_grid_cell_left_dclick', 0,
    #           Wx::EVT_GRID_CELL_LEFT_DCLICK,
    #           Wx::GridEvent],
    # EventType['evt_grid_cell_right_click', 0,
    #           Wx::EVT_GRID_CELL_RIGHT_CLICK,
    #           Wx::GridEvent],
    # EventType['evt_grid_cell_right_dclick', 0,
    #           Wx::EVT_GRID_CELL_RIGHT_DCLICK,
    #           Wx::GridEvent],
    # EventType['evt_grid_cmd_cell_change', 1,
    #           Wx::EVT_GRID_CELL_CHANGE,
    #           Wx::GridEvent],
    # EventType['evt_grid_cmd_cell_left_click', 1,
    #           Wx::EVT_GRID_CELL_LEFT_CLICK,
    #           Wx::GridEvent],
    # EventType['evt_grid_cmd_cell_left_dclick', 1,
    #           Wx::EVT_GRID_CELL_LEFT_DCLICK,
    #           Wx::GridEvent],
    # EventType['evt_grid_cmd_cell_right_click', 1,
    #           Wx::EVT_GRID_CELL_RIGHT_CLICK,
    #           Wx::GridEvent],
    # EventType['evt_grid_cmd_cell_right_dclick', 1,
    #           Wx::EVT_GRID_CELL_RIGHT_DCLICK,
    #           Wx::GridEvent],
    # EventType['evt_grid_cmd_col_size', 1,
    #           Wx::EVT_GRID_COL_SIZE,
    #           Wx::GridSizeEvent],
    # EventType['evt_grid_cmd_editor_created', 1,
    #           Wx::EVT_GRID_EDITOR_CREATED,
    #           Wx::GridEditorCreatedEvent],
    # EventType['evt_grid_cmd_editor_hidden', 1,
    #           Wx::EVT_GRID_EDITOR_HIDDEN,
    #           Wx::GridEvent],
    # EventType['evt_grid_cmd_editor_shown', 1,
    #           Wx::EVT_GRID_EDITOR_SHOWN,
    #           Wx::GridEvent],
    # EventType['evt_grid_cmd_label_left_click', 1,
    #           Wx::EVT_GRID_LABEL_LEFT_CLICK,
    #           Wx::GridEvent],
    # EventType['evt_grid_cmd_label_left_dclick', 1,
    #           Wx::EVT_GRID_LABEL_LEFT_DCLICK,
    #           Wx::GridEvent],
    # EventType['evt_grid_cmd_label_right_click', 1,
    #           Wx::EVT_GRID_LABEL_RIGHT_CLICK,
    #           Wx::GridEvent],
    # EventType['evt_grid_cmd_label_right_dclick', 1,
    #           Wx::EVT_GRID_LABEL_RIGHT_DCLICK,
    #           Wx::GridEvent],
    # EventType['evt_grid_cmd_range_select', 1,
    #           Wx::EVT_GRID_RANGE_SELECT,
    #           Wx::GridRangeSelectEvent],
    # EventType['evt_grid_cmd_row_size', 1,
    #           Wx::EVT_GRID_ROW_SIZE,
    #           Wx::GridSizeEvent],
    # EventType['evt_grid_cmd_select_cell', 1,
    #           Wx::EVT_GRID_SELECT_CELL,
    #           Wx::GridEvent],
    # EventType['evt_grid_col_size', 0,
    #           Wx::EVT_GRID_COL_SIZE,
    #           Wx::GridSizeEvent],
    # EventType['evt_grid_editor_created', 0,
    #           Wx::EVT_GRID_EDITOR_CREATED,
    #           Wx::GridEditorCreatedEvent],
    # EventType['evt_grid_editor_hidden', 0,
    #           Wx::EVT_GRID_EDITOR_HIDDEN,
    #           Wx::GridEvent],
    # EventType['evt_grid_editor_shown', 0,
    #           Wx::EVT_GRID_EDITOR_SHOWN,
    #           Wx::GridEvent],
    # EventType['evt_grid_label_left_click', 0,
    #           Wx::EVT_GRID_LABEL_LEFT_CLICK,
    #           Wx::GridEvent],
    # EventType['evt_grid_label_left_dclick', 0,
    #           Wx::EVT_GRID_LABEL_LEFT_DCLICK,
    #           Wx::GridEvent],
    # EventType['evt_grid_label_right_click', 0,
    #           Wx::EVT_GRID_LABEL_RIGHT_CLICK,
    #           Wx::GridEvent],
    # EventType['evt_grid_label_right_dclick', 0,
    #           Wx::EVT_GRID_LABEL_RIGHT_DCLICK,
    #           Wx::GridEvent],
    # EventType['evt_grid_range_select', 0,
    #           Wx::EVT_GRID_RANGE_SELECT,
    #           Wx::GridRangeSelectEvent],
    # EventType['evt_grid_row_size', 0,
    #           Wx::EVT_GRID_ROW_SIZE,
    #           Wx::GridSizeEvent],
    # EventType['evt_grid_select_cell', 0,
    #           Wx::EVT_GRID_SELECT_CELL,
    #           Wx::GridEvent],
    # EventType['evt_help', 1,
    #           Wx::EVT_HELP,
    #           Wx::HelpEvent],
    # EventType['evt_help_range', 2,
    #           Wx::EVT_HELP,
    #           Wx::HelpEvent],
    # EventType['evt_hibernate', 2,
    #           Wx::EVT_HIBERNATE,
    #           Wx::ActivateEvent],
    # EventType['evt_html_cell_clicked', 1,
    #           Wx::EVT_COMMAND_HTML_CELL_CLICKED,
    #           Wx::HtmlCellEvent],
    # EventType['evt_html_cell_hover', 1,
    #           Wx::EVT_COMMAND_HTML_CELL_HOVER,
    #           Wx::HtmlCellEvent],
    # EventType['evt_html_link_clicked', 1,
    #           Wx::EVT_COMMAND_HTML_LINK_CLICKED,
    #           Wx::HtmlLinkEvent],
    # EventType['evt_hyperlink', 1,
    #           Wx::EVT_COMMAND_HYPERLINK,
    #           Wx::HyperlinkEvent],
    # EventType['evt_iconize', 0,
    #           Wx::EVT_ICONIZE,
    #           Wx::IconizeEvent],
    # EventType['evt_idle', 0,
    #           Wx::EVT_IDLE,
    #           Wx::IdleEvent],
    EventType['evt_init_dialog', 0,
              Wx::EVT_INIT_DIALOG,
              Wx::Event],
    EventType['evt_joy_button_down', 0,
              Wx::EVT_JOY_BUTTON_DOWN,
              Wx::Event],
    EventType['evt_joy_button_up', 0,
              Wx::EVT_JOY_BUTTON_UP,
              Wx::Event],
    EventType['evt_joy_move', 0,
              Wx::EVT_JOY_MOVE,
              Wx::Event],
    EventType['evt_joy_zmove', 0,
              Wx::EVT_JOY_ZMOVE,
              Wx::Event],
    # EventType['evt_key_down', 0,
    #           Wx::EVT_KEY_DOWN,
    #           Wx::KeyEvent],
    # EventType['evt_key_up', 0,
    #           Wx::EVT_KEY_UP,
    #           Wx::KeyEvent],
    # EventType['evt_kill_focus', 0,
    #           Wx::EVT_KILL_FOCUS,
    #           Wx::FocusEvent],
    # EventType['evt_leave_window', 0,
    #           Wx::EVT_LEAVE_WINDOW,
    #           Wx::MouseEvent],
    # EventType['evt_left_dclick', 0,
    #           Wx::EVT_LEFT_DCLICK,
    #           Wx::MouseEvent],
    # EventType['evt_left_down', 0,
    #           Wx::EVT_LEFT_DOWN,
    #           Wx::MouseEvent],
    # EventType['evt_left_up', 0,
    #           Wx::EVT_LEFT_UP,
    #           Wx::MouseEvent],
    # EventType['evt_listbook_page_changed', 1,
    #           Wx::EVT_COMMAND_LISTBOOK_PAGE_CHANGED,
    #           Wx::ListbookEvent],
    # EventType['evt_listbook_page_changing', 1,
    #           Wx::EVT_COMMAND_LISTBOOK_PAGE_CHANGING,
    #           Wx::ListbookEvent],
    # EventType['evt_listbox', 1,
    #           Wx::EVT_COMMAND_LISTBOX_SELECTED,
    #           Wx::CommandEvent],
    # EventType['evt_listbox_dclick', 1,
    #           Wx::EVT_COMMAND_LISTBOX_DOUBLECLICKED,
    #           Wx::CommandEvent],
    # EventType['evt_list_begin_drag', 1,
    #           Wx::EVT_COMMAND_LIST_BEGIN_DRAG,
    #           Wx::ListEvent],
    # EventType['evt_list_begin_label_edit', 1,
    #           Wx::EVT_COMMAND_LIST_BEGIN_LABEL_EDIT,
    #           Wx::ListEvent],
    # EventType['evt_list_begin_rdrag', 1,
    #           Wx::EVT_COMMAND_LIST_BEGIN_RDRAG,
    #           Wx::ListEvent],
    # EventType['evt_list_cache_hint', 1,
    #           Wx::EVT_COMMAND_LIST_CACHE_HINT,
    #           Wx::ListEvent],
    # EventType['evt_list_col_begin_drag', 1,
    #           Wx::EVT_COMMAND_LIST_COL_BEGIN_DRAG,
    #           Wx::ListEvent],
    # EventType['evt_list_col_click', 1,
    #           Wx::EVT_COMMAND_LIST_COL_CLICK,
    #           Wx::ListEvent],
    # EventType['evt_list_col_dragging', 1,
    #           Wx::EVT_COMMAND_LIST_COL_DRAGGING,
    #           Wx::ListEvent],
    # EventType['evt_list_col_end_drag', 1,
    #           Wx::EVT_COMMAND_LIST_COL_END_DRAG,
    #           Wx::ListEvent],
    # EventType['evt_list_col_right_click', 1,
    #           Wx::EVT_COMMAND_LIST_COL_RIGHT_CLICK,
    #           Wx::ListEvent],
    # EventType['evt_list_delete_all_items', 1,
    #           Wx::EVT_COMMAND_LIST_DELETE_ALL_ITEMS,
    #           Wx::ListEvent],
    # EventType['evt_list_delete_item', 1,
    #           Wx::EVT_COMMAND_LIST_DELETE_ITEM,
    #           Wx::ListEvent],
    # EventType['evt_list_end_label_edit', 1,
    #           Wx::EVT_COMMAND_LIST_END_LABEL_EDIT,
    #           Wx::ListEvent],
    # EventType['evt_list_insert_item', 1,
    #           Wx::EVT_COMMAND_LIST_INSERT_ITEM,
    #           Wx::ListEvent],
    # EventType['evt_list_item_activated', 1,
    #           Wx::EVT_COMMAND_LIST_ITEM_ACTIVATED,
    #           Wx::ListEvent],
    # EventType['evt_list_item_deselected', 1,
    #           Wx::EVT_COMMAND_LIST_ITEM_DESELECTED,
    #           Wx::ListEvent],
    # EventType['evt_list_item_focused', 1,
    #           Wx::EVT_COMMAND_LIST_ITEM_FOCUSED,
    #           Wx::ListEvent],
    # EventType['evt_list_item_middle_click', 1,
    #           Wx::EVT_COMMAND_LIST_ITEM_MIDDLE_CLICK,
    #           Wx::ListEvent],
    # EventType['evt_list_item_right_click', 1,
    #           Wx::EVT_COMMAND_LIST_ITEM_RIGHT_CLICK,
    #           Wx::ListEvent],
    # EventType['evt_list_item_selected', 1,
    #           Wx::EVT_COMMAND_LIST_ITEM_SELECTED,
    #           Wx::ListEvent],
    # EventType['evt_list_key_down', 1,
    #           Wx::EVT_COMMAND_LIST_KEY_DOWN,
    #           Wx::ListEvent],
    EventType['evt_maximize', 0,
              Wx::EVT_MAXIMIZE,
              Wx::Event],
    EventType['evt_menu', 1,
              Wx::EVT_COMMAND_MENU_SELECTED,
              Wx::CommandEvent],
    # EventType['evt_menu_close', 0,
    #           Wx::EVT_MENU_CLOSE,
    #           Wx::MenuEvent],
    # EventType['evt_menu_highlight', 1,
    #           Wx::EVT_MENU_HIGHLIGHT,
    #           Wx::MenuEvent],
    # EventType['evt_menu_highlight_all', 0,
    #           Wx::EVT_MENU_HIGHLIGHT,
    #           Wx::MenuEvent],
    # EventType['evt_menu_open', 0,
    #           Wx::EVT_MENU_OPEN,
    #           Wx::MenuEvent],
    EventType['evt_menu_range', 2,
              Wx::EVT_COMMAND_MENU_SELECTED,
              Wx::CommandEvent],
    # EventType['evt_middle_dclick', 0,
    #           Wx::EVT_MIDDLE_DCLICK,
    #           Wx::MouseEvent],
    # EventType['evt_middle_down', 0,
    #           Wx::EVT_MIDDLE_DOWN,
    #           Wx::MouseEvent],
    # EventType['evt_middle_up', 0,
    #           Wx::EVT_MIDDLE_UP,
    #           Wx::MouseEvent],
    # EventType['evt_motion', 0,
    #           Wx::EVT_MOTION,
    #           Wx::MouseEvent],
    # EventType['evt_mousewheel', 0,
    #           Wx::EVT_MOUSEWHEEL,
    #           Wx::MouseEvent],
    EventType['evt_mouse_capture_changed', 0,
              Wx::EVT_MOUSE_CAPTURE_CHANGED,
              Wx::Event],
    # EventType['evt_move', 0,
    #           Wx::EVT_MOVE,
    #           Wx::MoveEvent],
    # EventType['evt_moving', 0,
    #           Wx::EVT_MOVING,
    #           Wx::MoveEvent],
    # EventType['evt_navigation_key', 0,
    #           Wx::EVT_NAVIGATION_KEY,
    #           Wx::NavigationKeyEvent],
    EventType['evt_nc_paint', 0,
              Wx::EVT_NC_PAINT,
              Wx::Event],
    # EventType['evt_notebook_page_changed', 1,
    #           Wx::EVT_COMMAND_NOTEBOOK_PAGE_CHANGED,
    #           Wx::NotebookEvent],
    # EventType['evt_notebook_page_changing', 1,
    #           Wx::EVT_COMMAND_NOTEBOOK_PAGE_CHANGING,
    #           Wx::NotebookEvent],
    EventType['evt_paint', 0,
              Wx::EVT_PAINT,
              Wx::PaintEvent],
    EventType['evt_query_end_session', 0,
              Wx::EVT_QUERY_END_SESSION,
              Wx::Event],
    # EventType['evt_query_layout_info', 0,
    #           Wx::EVT_QUERY_LAYOUT_INFO,
    #           Wx::QueryLayoutInfoEvent],
    # EventType['evt_radiobox', 1,
    #           Wx::EVT_COMMAND_RADIOBOX_SELECTED,
    #           Wx::CommandEvent],
    # EventType['evt_radiobutton', 1,
    #           Wx::EVT_COMMAND_RADIOBUTTON_SELECTED,
    #           Wx::CommandEvent],
    # EventType['evt_richtext_character', 1,
    #           Wx::EVT_COMMAND_RICHTEXT_CHARACTER,
    #           Wx::RichTextEvent],
    # EventType['evt_richtext_content_inserted', 1,
    #           Wx::EVT_COMMAND_RICHTEXT_CONTENT_INSERTED,
    #           Wx::RichTextEvent],
    # EventType['evt_richtext_content_deleted', 1,
    #           Wx::EVT_COMMAND_RICHTEXT_CONTENT_DELETED,
    #           Wx::RichTextEvent],
    # EventType['evt_richtext_delete', 1,
    #           Wx::EVT_COMMAND_RICHTEXT_DELETE,
    #           Wx::RichTextEvent],
    # EventType['evt_richtext_left_click', 1,
    #           Wx::EVT_COMMAND_RICHTEXT_LEFT_CLICK,
    #           Wx::RichTextEvent],
    # EventType['evt_richtext_left_dclick', 1,
    #           Wx::EVT_COMMAND_RICHTEXT_LEFT_DCLICK,
    #           Wx::RichTextEvent],
    # EventType['evt_richtext_middle_click', 1,
    #           Wx::EVT_COMMAND_RICHTEXT_MIDDLE_CLICK,
    #           Wx::RichTextEvent],
    # EventType['evt_richtext_return', 1,
    #           Wx::EVT_COMMAND_RICHTEXT_RETURN,
    #           Wx::RichTextEvent],
    # EventType['evt_richtext_right_click', 1,
    #           Wx::EVT_COMMAND_RICHTEXT_RIGHT_CLICK,
    #           Wx::RichTextEvent],
    # EventType['evt_richtext_selection_changed', 1,
    #           Wx::EVT_COMMAND_RICHTEXT_SELECTION_CHANGED,
    #           Wx::RichTextEvent],
    # EventType['evt_richtext_style_changed', 1,
    #           Wx::EVT_COMMAND_RICHTEXT_STYLE_CHANGED,
    #           Wx::RichTextEvent],
    # EventType['evt_richtext_stylesheet_changed', 1,
    #           Wx::EVT_COMMAND_RICHTEXT_STYLESHEET_CHANGED,
    #           Wx::RichTextEvent],
    # EventType['evt_richtext_stylesheet_changing', 1,
    #           Wx::EVT_COMMAND_RICHTEXT_STYLESHEET_CHANGING,
    #           Wx::RichTextEvent],
    # EventType['evt_richtext_stylesheet_replaced', 1,
    #           Wx::EVT_COMMAND_RICHTEXT_STYLESHEET_REPLACED,
    #           Wx::RichTextEvent],
    # EventType['evt_richtext_stylesheet_replacing', 1,
    #           Wx::EVT_COMMAND_RICHTEXT_STYLESHEET_REPLACING,
    #           Wx::RichTextEvent],
    # EventType['evt_right_dclick', 0,
    #           Wx::EVT_RIGHT_DCLICK,
    #           Wx::MouseEvent],
    # EventType['evt_right_down', 0,
    #           Wx::EVT_RIGHT_DOWN,
    #           Wx::MouseEvent],
    # EventType['evt_right_up', 0,
    #           Wx::EVT_RIGHT_UP,
    #           Wx::MouseEvent],
    # EventType['evt_sash_dragged', 1,
    #           Wx::EVT_SASH_DRAGGED,
    #           Wx::SashEvent],
    # EventType['evt_sash_dragged_range', 2,
    #           Wx::EVT_SASH_DRAGGED,
    #           Wx::SashEvent],
    EventType['evt_scrollbar', 1,
              Wx::EVT_COMMAND_SCROLLBAR_UPDATED,
              Wx::CommandEvent],
    # EventType['evt_scrollwin_bottom', 0,
    #           Wx::EVT_SCROLLWIN_TOP,
    #           Wx::ScrollWinEvent],
    # EventType['evt_scrollwin_linedown', 0,
    #           Wx::EVT_SCROLLWIN_LINEDOWN,
    #           Wx::ScrollWinEvent],
    # EventType['evt_scrollwin_lineup', 0,
    #           Wx::EVT_SCROLLWIN_LINEUP,
    #           Wx::ScrollWinEvent],
    # EventType['evt_scrollwin_pagedown', 0,
    #           Wx::EVT_SCROLLWIN_PAGEDOWN,
    #           Wx::ScrollWinEvent],
    # EventType['evt_scrollwin_pageup', 0,
    #           Wx::EVT_SCROLLWIN_PAGEUP,
    #           Wx::ScrollWinEvent],
    # EventType['evt_scrollwin_thumbrelease', 0,
    #           Wx::EVT_SCROLLWIN_THUMBRELEASE,
    #           Wx::ScrollWinEvent],
    # EventType['evt_scrollwin_thumbtrack', 0,
    #           Wx::EVT_SCROLLWIN_THUMBTRACK,
    #           Wx::ScrollWinEvent],
    # EventType['evt_scrollwin_top', 0,
    #           Wx::EVT_SCROLLWIN_TOP,
    #           Wx::ScrollWinEvent],
    # EventType['evt_scroll_bottom', 0,
    #           Wx::EVT_SCROLL_BOTTOM,
    #           Wx::ScrollEvent],
    # EventType['evt_scroll_linedown', 0,
    #           Wx::EVT_SCROLL_LINEDOWN,
    #           Wx::ScrollEvent],
    # EventType['evt_scroll_lineup', 0,
    #           Wx::EVT_SCROLL_LINEUP,
    #           Wx::ScrollEvent],
    # EventType['evt_scroll_pagedown', 0,
    #           Wx::EVT_SCROLL_PAGEDOWN,
    #           Wx::ScrollEvent],
    # EventType['evt_scroll_pageup', 0,
    #           Wx::EVT_SCROLL_PAGEUP,
    #           Wx::ScrollEvent],
    # EventType['evt_scroll_thumbrelease', 0,
    #           Wx::EVT_SCROLL_THUMBRELEASE,
    #           Wx::ScrollEvent],
    # EventType['evt_scroll_thumbtrack', 0,
    #           Wx::EVT_SCROLL_THUMBTRACK,
    #           Wx::ScrollEvent],
    # EventType['evt_scroll_top', 0,
    #           Wx::EVT_SCROLL_TOP,
    #           Wx::ScrollEvent],
    # EventType['evt_searchctrl_cancel_btn', 1,
    #           Wx::EVT_COMMAND_SEARCHCTRL_CANCEL_BTN,
    #           Wx::CommandEvent],
    # EventType['evt_searchctrl_search_btn', 1,
    #           Wx::EVT_COMMAND_SEARCHCTRL_SEARCH_BTN,
    #           Wx::CommandEvent],
    # EventType['evt_set_cursor', 0,
    #           Wx::EVT_SET_CURSOR,
    #           Wx::SetCursorEvent],
    # EventType['evt_set_focus', 0,
    #           Wx::EVT_SET_FOCUS,
    #           Wx::FocusEvent],
    # EventType['evt_show', 1,
    #           Wx::EVT_SHOW,
    #           Wx::ShowEvent],
    # EventType['evt_size', 0,
    #           Wx::EVT_SIZE,
    #           Wx::SizeEvent],
    # EventType['evt_sizing', 0,
    #           Wx::EVT_SIZING,
    #           Wx::SizeEvent],
    EventType['evt_slider', 1,
              Wx::EVT_COMMAND_SLIDER_UPDATED,
              Wx::CommandEvent],
    # EventType['evt_socket', 1,
    #           Wx::EVT_SOCKET,
    #           Wx::Event],
    # EventType['evt_spin', 1,
    #           Wx::EVT_SCROLL_THUMBTRACK,
    #           Wx::ScrollEvent],
    # EventType['evt_spinctrl', 1,
    #           Wx::EVT_COMMAND_SPINCTRL_UPDATED,
    #           Wx::SpinEvent],
    # EventType['evt_spin_down', 1,
    #           Wx::EVT_SCROLL_LINEDOWN,
    #           Wx::ScrollEvent],
    # EventType['evt_spin_up', 1,
    #           Wx::EVT_SCROLL_LINEUP,
    #           Wx::ScrollEvent],
    # EventType['evt_splitter_dclick', 1,
    #           Wx::EVT_COMMAND_SPLITTER_DOUBLECLICKED,
    #           Wx::SplitterEvent],
    # EventType['evt_splitter_sash_pos_changed', 1,
    #           Wx::EVT_COMMAND_SPLITTER_SASH_POS_CHANGED,
    #           Wx::SplitterEvent],
    # EventType['evt_splitter_sash_pos_changing', 1,
    #           Wx::EVT_COMMAND_SPLITTER_SASH_POS_CHANGING,
    #           Wx::SplitterEvent],
    # EventType['evt_splitter_unsplit', 1,
    #           Wx::EVT_COMMAND_SPLITTER_UNSPLIT,
    #           Wx::SplitterEvent],
    EventType['evt_sys_colour_changed', 0,
              Wx::EVT_SYS_COLOUR_CHANGED,
              Wx::Event],
    # EventType['evt_taskbar_left_dclick', 0,
    #           Wx::EVT_TASKBAR_LEFT_DCLICK,
    #           Wx::Event],
    # EventType['evt_taskbar_left_down', 0,
    #           Wx::EVT_TASKBAR_LEFT_DOWN,
    #           Wx::Event],
    # EventType['evt_taskbar_left_up', 0,
    #           Wx::EVT_TASKBAR_LEFT_UP,
    #           Wx::Event],
    # EventType['evt_taskbar_move', 0,
    #           Wx::EVT_TASKBAR_MOVE,
    #           Wx::Event],
    # EventType['evt_taskbar_right_dclick', 0,
    #           Wx::EVT_TASKBAR_RIGHT_DCLICK,
    #           Wx::Event],
    # EventType['evt_taskbar_right_down', 0,
    #           Wx::EVT_TASKBAR_RIGHT_DOWN,
    #           Wx::Event],
    # EventType['evt_taskbar_right_up', 0,
    #           Wx::EVT_TASKBAR_RIGHT_UP,
    #           Wx::Event],
    EventType['evt_text', 1,
              Wx::EVT_COMMAND_TEXT_UPDATED,
              Wx::CommandEvent],
    # EventType['evt_text_copy', 1,
    #           Wx::EVT_COMMAND_TEXT_COPY,
    #           Wx::ClipboardTextEvent],
    # EventType['evt_text_cut', 1,
    #           Wx::EVT_COMMAND_TEXT_CUT,
    #           Wx::ClipboardTextEvent],
    EventType['evt_text_enter', 1,
              Wx::EVT_COMMAND_TEXT_ENTER,
              Wx::CommandEvent],
    EventType['evt_text_maxlen', 1,
              Wx::EVT_COMMAND_TEXT_MAXLEN,
              Wx::CommandEvent],
    # EventType['evt_text_paste', 1,
    #           Wx::EVT_COMMAND_TEXT_PASTE,
    #           Wx::ClipboardTextEvent],
    # EventType['evt_text_url', 1,
    #           Wx::EVT_COMMAND_TEXT_URL,
    #           Wx::TextUrlEvent],
    # EventType['evt_timer', 1,
    #           Wx::EVT_TIMER,
    #           Wx::TimerEvent],
    # EventType['evt_togglebutton', 1,
    #           Wx::EVT_COMMAND_TOGGLEBUTTON_CLICKED,
    #           Wx::CommandEvent],
    # EventType['evt_tool', 1,
    #           Wx::EVT_COMMAND_TOOL_CLICKED,
    #           Wx::CommandEvent],
    # EventType['evt_toolbook_page_changed', 1,
    #           Wx::EVT_COMMAND_TOOLBOOK_PAGE_CHANGED,
    #           Wx::ToolbookEvent],
    # EventType['evt_toolbook_page_changing', 1,
    #           Wx::EVT_COMMAND_TOOLBOOK_PAGE_CHANGING,
    #           Wx::ToolbookEvent],
    # EventType['evt_tool_enter', 1,
    #           Wx::EVT_COMMAND_TOOL_ENTER,
    #           Wx::CommandEvent],
    # EventType['evt_tool_range', 2,
    #           Wx::EVT_COMMAND_TOOL_CLICKED,
    #           Wx::CommandEvent],
    # EventType['evt_tool_rclicked', 1,
    #           Wx::EVT_COMMAND_TOOL_RCLICKED,
    #           Wx::CommandEvent],
    # EventType['evt_tool_rclicked_range', 2,
    #           Wx::EVT_COMMAND_TOOL_RCLICKED,
    #           Wx::CommandEvent],
    # EventType['evt_tree_begin_drag', 1,
    #           Wx::EVT_COMMAND_TREE_BEGIN_DRAG,
    #           Wx::TreeEvent],
    # EventType['evt_tree_begin_label_edit', 1,
    #           Wx::EVT_COMMAND_TREE_BEGIN_LABEL_EDIT,
    #           Wx::TreeEvent],
    # EventType['evt_tree_begin_rdrag', 1,
    #           Wx::EVT_COMMAND_TREE_BEGIN_RDRAG,
    #           Wx::TreeEvent],
    # EventType['evt_tree_delete_item', 1,
    #           Wx::EVT_COMMAND_TREE_DELETE_ITEM,
    #           Wx::TreeEvent],
    # EventType['evt_tree_end_drag', 1,
    #           Wx::EVT_COMMAND_TREE_END_DRAG,
    #           Wx::TreeEvent],
    # EventType['evt_tree_end_label_edit', 1,
    #           Wx::EVT_COMMAND_TREE_END_LABEL_EDIT,
    #           Wx::TreeEvent],
    # EventType['evt_tree_get_info', 1,
    #           Wx::EVT_COMMAND_TREE_GET_INFO,
    #           Wx::TreeEvent],
    # EventType['evt_tree_item_activated', 1,
    #           Wx::EVT_COMMAND_TREE_ITEM_ACTIVATED,
    #           Wx::TreeEvent],
    # EventType['evt_tree_item_collapsed', 1,
    #           Wx::EVT_COMMAND_TREE_ITEM_COLLAPSED,
    #           Wx::TreeEvent],
    # EventType['evt_tree_item_collapsing', 1,
    #           Wx::EVT_COMMAND_TREE_ITEM_COLLAPSING,
    #           Wx::TreeEvent],
    # EventType['evt_tree_item_expanded', 1,
    #           Wx::EVT_COMMAND_TREE_ITEM_EXPANDED,
    #           Wx::TreeEvent],
    # EventType['evt_tree_item_expanding', 1,
    #           Wx::EVT_COMMAND_TREE_ITEM_EXPANDING,
    #           Wx::TreeEvent],
    # EventType['evt_tree_item_gettooltip', 1,
    #           Wx::EVT_COMMAND_TREE_ITEM_GETTOOLTIP,
    #           Wx::TreeEvent],
    # EventType['evt_tree_item_menu', 1,
    #           Wx::EVT_COMMAND_TREE_ITEM_MENU,
    #           Wx::TreeEvent],
    # EventType['evt_tree_item_middle_click', 1,
    #           Wx::EVT_COMMAND_TREE_ITEM_MIDDLE_CLICK,
    #           Wx::TreeEvent],
    # EventType['evt_tree_item_right_click', 1,
    #           Wx::EVT_COMMAND_TREE_ITEM_RIGHT_CLICK,
    #           Wx::TreeEvent],
    # EventType['evt_tree_key_down', 1,
    #           Wx::EVT_COMMAND_TREE_KEY_DOWN,
    #           Wx::TreeEvent],
    # EventType['evt_tree_sel_changed', 1,
    #           Wx::EVT_COMMAND_TREE_SEL_CHANGED,
    #           Wx::TreeEvent],
    # EventType['evt_tree_sel_changing', 1,
    #           Wx::EVT_COMMAND_TREE_SEL_CHANGING,
    #           Wx::TreeEvent],
    # EventType['evt_tree_set_info', 1,
    #           Wx::EVT_COMMAND_TREE_SET_INFO,
    #           Wx::TreeEvent],
    # EventType['evt_tree_state_image_click', 1,
    #           Wx::EVT_COMMAND_TREE_STATE_IMAGE_CLICK,
    #           Wx::TreeEvent],
    # EventType['evt_treebook_node_collapsed', 1,
    #           Wx::EVT_COMMAND_TREEBOOK_NODE_COLLAPSED,
    #           Wx::TreebookEvent],
    # EventType['evt_treebook_node_expanded', 1,
    #           Wx::EVT_COMMAND_TREEBOOK_NODE_EXPANDED,
    #           Wx::TreebookEvent],
    # EventType['evt_treebook_page_changed', 1,
    #           Wx::EVT_COMMAND_TREEBOOK_PAGE_CHANGED,
    #           Wx::TreebookEvent],
    # EventType['evt_treebook_page_changing', 1,
    #           Wx::EVT_COMMAND_TREEBOOK_PAGE_CHANGING,
    #           Wx::TreebookEvent],
    # EventType['evt_update_ui', 1,
    #           Wx::EVT_UPDATE_UI,
    #           Wx::UpdateUIEvent],
    # EventType['evt_update_ui_range', 2,
    #           Wx::EVT_UPDATE_UI,
    #           Wx::UpdateUIEvent],
    EventType['evt_window_create', 0,
              Wx::EVT_CREATE,
              Wx::WindowCreateEvent],
    EventType['evt_window_destroy', 0,
              Wx::EVT_DESTROY,
              Wx::WindowDestroyEvent],
    # EventType['evt_wizard_cancel', 1,
    #           Wx::EVT_WIZARD_CANCEL,
    #           Wx::WizardEvent],
    # EventType['evt_wizard_finished', 1,
    #           Wx::EVT_WIZARD_FINISHED,
    #           Wx::WizardEvent],
    # EventType['evt_wizard_help', 1,
    #           Wx::EVT_WIZARD_HELP,
    #           Wx::WizardEvent],
    # EventType['evt_wizard_page_changed', 1,
    #           Wx::EVT_WIZARD_PAGE_CHANGED,
    #           Wx::WizardEvent],
    # EventType['evt_wizard_page_changing', 1,
    #           Wx::EVT_WIZARD_PAGE_CHANGING,
    #           Wx::WizardEvent]
  ]

  # Loop over the event definitions to set up two things:
  # 1) A hash mapping Event Type ids to event classes, used when events
  #    are fired to quickly look up the right type to yield
  # 2) EvtHandler instance methods like evt_xxx to conveniently set
  #    up event handlers
  EVENT_DEFINITIONS.each { | ev_type | register_event_type(ev_type) }
=end

  # convenience evt_handler to listen to all mouse events
  def evt_mouse_events(&block)
    evt_left_down(&block)
    evt_left_up(&block)
    evt_middle_down(&block)
    evt_middle_up(&block)
    evt_right_down(&block)
    evt_right_up(&block)
    evt_motion(&block)
    evt_left_dclick(&block)
    evt_middle_dclick(&block)
    evt_right_dclick(&block)
    evt_leave_window(&block)
    evt_enter_window(&block)
    evt_mousewheel(&block)
  end

  # convenience evt handler to listen to all scrollwin events
  def evt_scrollwin(&block)
    evt_scrollwin_top(&block)
    evt_scrollwin_bottom(&block)
    evt_scrollwin_lineup(&block)
    evt_scrollwin_linedown(&block)
    evt_scrollwin_pageup(&block)
    evt_scrollwin_pagedown(&block)
    evt_scrollwin_thumbtrack(&block)
    evt_scrollwin_thumbrelease(&block)
  end

  # missing from XML docs so we add this here manually
  self.register_event_type EventType[
    'evt_window_destroy', 0,
    Wx::EVT_DESTROY,
    Wx::WindowDestroyEvent
  ] if Wx.const_defined?(:EVT_DESTROY)
end

# Definitions for all event types that are part by core wxRuby. Events
# that are mapped to class Wx::Event are TODO as they are not
# currently wrapped by the correct class.

require_relative './events/evt_list'
