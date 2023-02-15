#!/usr/bin/env ruby
# wxRuby Sample Code.
# Copyright (c) M.J.N. Corino, The Netherlands

begin
  require 'rubygems'
rescue LoadError
end
require 'wx'

require_relative './sample_props'

class MyStringProperty < Wx::PG::StringProperty

end

class MyBoolProperty < Wx::PG::BoolProperty

end

class MyFrame < Wx::Frame

  ID_ACTION = Wx::ID_HIGHEST+1

  def initialize(parent = nil)
    super(parent, Wx::ID_ANY, title: "PropertyGrid Test")
    menu = Wx::Menu.new
    menu.append(ID_ACTION, "Action");
    self.menu_bar = Wx::MenuBar.new
    self.menu_bar.append(menu, "Action");

    @pg = Wx::PG::PropertyGrid.new(self, Wx::ID_ANY, Wx::DEFAULT_POSITION, [400,400],
                                   Wx::PG::PG_SPLITTER_AUTO_CENTER | Wx::PG::PG_BOLD_MODIFIED)

    @pg.append(MyStringProperty.new("String Property", Wx::PG::PG_LABEL))
    @pg.append(ip = Wx::PG::IntProperty.new("Int Property", Wx::PG::PG_LABEL))
    ip.editor = 'SpinCtrl'
    @pg.append(Wx::PG::BoolProperty.new("Bool Property", Wx::PG::PG_LABEL))
    @pg.append(WxSizeProperty.new("Size Property", Wx::PG::PG_LABEL, self.size))
    @pg.append(WxArrayDoubleProperty.new('Double[] Property', Wx::PG::PG_LABEL, [1.23, 3.14]))
    @pg.append(WxFontDataProperty.new('FontData Property', Wx::PG::PG_LABEL))
    @pg.append(WxDirsProperty.new('Directory list Property', Wx::PG::PG_LABEL))
    @pg.set_property_attribute('Double[] Property', Wx::PG::PG_FLOAT_PRECISION, Wx::Variant.new(4))
    @pg.set_property_help_string('Double[] Property',
                               'This demonstrates wxArrayDoubleProperty class defined in this sample app. '+
                               'It is an example of a custom list editor property.')

    size = [400, 600]

    evt_menu ID_ACTION,:on_action

    evt_pg_changed Wx::ID_ANY, :on_property_grid_change
    evt_pg_changing Wx::ID_ANY, :on_property_grid_changing
  end

  def on_action(evt)

  end

  def on_property_grid_change(evt)
    p = evt.property

    if p
      Wx::log_message("OnPropertyGridChange(%s, value=%s)",
                   p.name, p.value_as_string)
    else
      Wx::log_message("OnPropertyGridChange(NULL)")
    end
  end

  def on_property_grid_changing(evt)
    p = evt.property

    Wx::log_message("OnPropertyGridChanging(%s)", p.name)
  end

end

Wx::App.run do
  self.app_name = 'Minimal PropertyGrid'
  Wx::Log::set_active_target(Wx::LogStderr.new)
  frame = MyFrame.new
  gc_stress
  frame.show
end
