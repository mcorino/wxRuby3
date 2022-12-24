#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems'
rescue LoadError
end
require 'wx'

include Wx

ID_CHOICE = 1000

class ChoiceDlg < Dialog
  def initialize
    super(nil, -1, "ChoiceDialog", DEFAULT_POSITION, Size.new(185, 185))

    list = ["ABS", "Airbag", "Air conditioning"]

    @m_pChoice = Choice.new(self, ID_CHOICE, DEFAULT_POSITION, DEFAULT_SIZE, list)
    @m_pChoice.append("Automatic gear", 100)

    @m_pLabel = StaticText.new(self, -1, "default")
    dlgSizer = BoxSizer.new(HORIZONTAL)
    choiceSizer = BoxSizer.new(VERTICAL)
    choiceSizer.add(@m_pChoice, 1, GROW)
    choiceSizer.add(@m_pLabel)
    dlgSizer.add(choiceSizer, 1, GROW)
    set_sizer(dlgSizer)
    set_auto_layout(true)
    layout

    evt_choice(ID_CHOICE) { |event| onChoice(event) }
    evt_close { onClose }
  end

  def onChoice(event)
    chose = event.get_selection
    data = event.get_client_data
    # NOTE: uninitialized client data will be false, not nil
    if (!data)
      data = 0
    end
    data += 1
    @m_pLabel.set_label(data.to_s)

    @m_pChoice.set_selection(chose)
    @m_pChoice.set_client_data(chose, data)
  end

  def onClose
    destroy
  end
end

class RbApp < App
  def on_init
    dlg = ChoiceDlg.new
    set_top_window(dlg)
    dlg.show(true)
  end

end

RbApp.new.run
