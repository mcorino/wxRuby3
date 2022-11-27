#!/usr/bin/env ruby
# wxRuby2 Sample Code. Copyright (c) 2004-2008 wxRuby development team
# Freely reusable code: see SAMPLES-LICENSE.TXT for details
begin
  require 'rubygems' 
rescue LoadError
end
require 'wx'



class TestPanel < Wx::Panel
    def initialize(parent, log)
        super(parent, -1)
        @log = log
        panel = Wx::Panel.new(self, -1)
        
        # 1st group of controls
        @group1_ctrls = {}
        radio1 = Wx::RadioButton.new(panel, -1, "Radio1", Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::RB_GROUP)
        text1 = Wx::TextCtrl.new(panel, -1, "")
        radio2 = Wx::RadioButton.new(panel, -1, "Radio2")
        text2 = Wx::TextCtrl.new(panel, -1, "")
        radio3 = Wx::RadioButton.new(panel, -1, "Radio3")
        text3 = Wx::TextCtrl.new(panel, -1, "")
        @group1_ctrls["one"] = [radio1, text1]
        @group1_ctrls["two"] = [radio2, text2]
        @group1_ctrls["three"] = [radio3, text3]
        
        # 2nd group of controls
        #@group2_ctrls = {}
        #radio4 = Wx::RadioButton.new(panel, -1, "Radio1", Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::RB_GROUP)
        #text4 = Wx::TextCtrl.new(panel, -1, "")
        #radio5 = Wx::RadioButton.new(panel, -1, "Radio2")
        #text5 = Wx::TextCtrl.new(panel, -1, "")
        #radio6 = Wx::RadioButton.new(panel, -1, "Radio3")
        #text6 = Wx::TextCtrl.new(panel, -1, "")
        #@group2_ctrls["one"] = [radio4, text4]
        #@group2_ctrls["two"] = [radio5, text5]
        #@group2_ctrls["three"] = [radio6, text6]
        
        # Layout controls on panel
        vs = Wx::BoxSizer.new(Wx::VERTICAL)
        
        box1_title = Wx::StaticBox.new(panel, -1, "Group 1", Wx::DEFAULT_POSITION, Wx::Size.new(-1,-1))
        box1 = Wx::StaticBoxSizer.new(box1_title, Wx::HORIZONTAL)
        grid1 = Wx::FlexGridSizer.new(0,2,0,0)
    
        @group1_ctrls.each_value do |ctrl|
            grid1.add(ctrl[0], 0, Wx::ALIGN_CENTER, 5)
            grid1.add(ctrl[1], 0, Wx::ALIGN_CENTER, 5)
        end
        box1.add(grid1, 0, Wx::ALIGN_CENTER | Wx::ALL, 5)
        vs.add(box1, 0, Wx::ALL, 5)
        
        #box2_title = Wx::StaticBox.new(panel, -1, "Group 2")
        #box2 = Wx::StaticBoxSizer.new(box2_title, Wx::HORIZONTAL)
        #grid2 = Wx::FlexGridSizer.new(0,2,0,0)
        
        #@group2_ctrls.each_value do |ctrl|
            #grid2.add(ctrl[0], 0, Wx::ALIGN_CENTER, 5)
            #grid2.add(ctrl[1], 0, Wx::ALIGN_CENTER, 5)
        #end
        #box2.add(grid2, 0, Wx::ALIGN_CENTER | Wx::ALL, 5)
        #vs.add(box2, 0, Wx::ALIGN_CENTER | Wx::ALL, 5)
        
        panel.set_sizer(vs)
        vs.fit(panel)
        
        panel.move(Wx::Point.new(50,50))
        @panel = panel
        
        @group1_ctrls.each_value do |ctrl| 
            evt_radiobutton(ctrl[0].get_id()) {|event| on_group1_select(event)}
            ctrl[0].set_value(0)
            ctrl[1].enable(false)
        end
        #@group2_ctrls.each_value do |ctrl| 
        #    evt_radiobutton(ctrl[0].get_id()) {|event| on_group2_select(event)}
        #    ctrl[0].set_value(0)
        #    ctrl[1].enable(false)
        #end
    end
    
    def on_group1_select(event)
        @group1_ctrls.each_value do |ctrl|
            if ctrl[0].get_value() == true
                ctrl[1].enable(true)
                @log.write_text("Group 1 " + ctrl[0].get_label() + " selected")
            else
                ctrl[1].enable(false)
            end
        end
    end
    
    def on_group2_select(event)
        @group2_ctrls.each_value do |ctrl|
            if ctrl[0].get_value() == true
                ctrl[1].enable(true)
                @log.write_text("Group 2 " + ctrl[0].get_label() + " selected")
            else
                ctrl[1].enable(false)
            end
        end
    end
end

module Demo
    def Demo.run(frame,nb,log)
        win = TestPanel.new(nb, log)
        return win
    end
    
    def Demo.overview
        "This demo shows how individual radio buttons can be used to build more complicated selection mechanisms...\n" +
        "It uses 2 groups of wxRadioButtons, where the groups are defined by instantiation.  When a wxRadioButton is created with the Wx::RB_GROUP style, all subsequent wxRadioButtons created without it are implicitly added to that group by the framework."
    end
end


if __FILE__ == $0
  run_solo_lib = File.join( File.dirname(__FILE__), 'run.rb')
  load run_solo_lib
  run File.basename($0)
end
