# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.


module Wx

=begin
  These constants are not documented in the wxWidgets interface headers
  although they are referenced in various argument defaults which *are*
  in the interface header declarations so.
=end

  DEFAULT_DATE_TIME_FORMAT = '%c'
  DEFAULT_TIME_SPAN_FORMAT = '%H:%M:%S'

  CHOICE_NAME_STR = 'choice'
  COLOUR_PICKER_CTRL_NAME_STR = 'colourpicker'
  COLOUR_PICKER_WIDGET_NAME_STR = 'colourpickerwidget'
  HYPERLINK_CTRL_NAME_STR = 'hyperlink'
  PANEL_NAME_STR = 'panel'
  LIST_BOX_NAME_STR = 'listBox'
  FRAME_NAME_STR = 'frame'
  STATUS_LINE_NAME_STR = 'status_line'
  STATIC_BITMAP_NAME_STR = 'staticBitmap'
  WEB_VIEW_NAME_STR = 'wxWebView'
  ANIMATION_CTRL_NAME_STR = 'animationctrl'
  TOOL_BAR_NAME_STR = 'toolbar'
  TEXT_CTRL_NAME_STR = 'text'
  LIST_CTRL_NAME_STR = 'listCtrl'
  FILE_PICKER_CTRL_NAME_STR = 'filepicker'
  FILE_PICKER_WIDGET_NAME_STR = 'filepickerwidget'
  DIR_PICKER_CTRL_NAME_STR = 'dirpicker'
  DIR_PICKER_WIDGET_NAME_STR = 'dirpickerwidget'
  FILE_CTRL_NAME_STR = 'wxfilectrl'
  FILE_SELECTOR_PROMPT_STR = 'Select a file'
  STATIC_BOX_NAME_STR = 'groupBox'
  BUTTON_NAME_STR = 'button'
  RADIO_BOX_NAME_STR = 'radioBox'
  STATIC_LINE_NAME_STR = 'staticLine'
  RADIO_BUTTON_NAME_STR = 'radioButton'
  BITMAP_RADIO_BUTTON_NAME_STR = 'radioButton'
  GAUGE_NAME_STR = 'gauge'
  DATA_VIEW_CTRL_NAME_STR = 'dataviewCtrl'
  FONT_PICKER_CTRL_NAME_STR = 'fontpicker'
  FONT_PICKER_WIDGET_NAME_STR = 'fontpickerwidget'
  REARRANGE_LIST_NAME_STR = 'wxRearrangeList'
  REARRANGE_DIALOG_NAME_STR = 'wxRearrangeDlg'
  NOTEBOOK_NAME_STR = 'notebook'
  CONTROL_NAME_STR = 'control'
  SCROLL_BAR_NAME_STR = 'scrollBar'
  STATUS_BAR_NAME_STR = 'statusBar'
  SLIDER_NAME_STR = 'slider'
  HEADER_CTRL_NAME_STR = 'wxHeaderCtrl'
  BITMAP_COMBO_BOX_NAME_STR = 'bitmapComboBox'
  CHECK_BOX_NAME_STR = 'check'
  FILE_DIALOG_NAME_STR = 'filedlg'
  ADD_REMOVE_CTRL_NAME_STR = 'wxAddRemoveCtrl'
  STATIC_TEXT_NAME_STR = 'staticText'
  COMBO_BOX_NAME_STR = 'comboBox'
  SEARCH_CTRL_NAME_STR = 'searchCtrl'
  TREE_CTRL_NAME_STR = 'treeCtrl'
  DIALOG_NAME_STR = 'dialog'
  COLLAPSIBLE_HEADER_CTRL_NAME_STR = 'collapsibleHeader'
  COLLAPSIBLE_PANE_NAME_STR = 'collapsiblePane'
  BANNER_WINDOW_NAME_STR = 'bannerwindow'
  GRID_NAME_STR = 'grid'
  TREE_LIST_CTRL_NAME_STR = 'wxTreeListCtrl'
  HTML_LIST_BOX_NAME_STR = 'htmlListBox'
  SIMPLE_HTML_LIST_BOX_NAME_STR = 'simpleHtmlListBox'
  EDITABLE_LIST_BOX_NAME_STR = 'editableListBox'
  V_LIST_BOX_NAME_STR = 'wxVListBox'

  if Wx::PLATFORM == 'WXMSW'
    # wxMSW only
    MSW_HEADER_CTRL_NAME_STR = 'wxMSWHeaderCtrl'
  end

  PROPERTY_GRID_MANAGER_NAME_STR = 'wxPropertyGridManager'
  PROPERTY_GRID_NAME_STR = 'wxPropertyGrid'
  STC_NAME_STR = 'stcwindow'

end
