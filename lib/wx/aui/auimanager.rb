
class Wx::AUI::AuiManager
  def get_all_panes
    ::Enumerator.new { |y| each_pane { |p| y << p } }
  end
  alias :all_panes :get_all_panes

  unless Wx::EvtHandler.event_type_for_name(:evt_aui_find_manager)
    # missing from XML API refs
    Wx::EvtHandler.register_event_type Wx::EvtHandler::EventType[
      'evt_aui_find_manager', 0,
      Wx::AUI::EVT_AUI_FIND_MANAGER,
      Wx::AUI::AuiManagerEvent
    ] if Wx::AUI.const_defined?(:EVT_AUI_FIND_MANAGER)
  end

end
