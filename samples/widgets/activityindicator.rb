# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets richtext sample
# Copyright (c) 2001 Vadim Zeitlin

module Widgets

  module ActivityIndicator

    class ActivityIndicatorPage < Widgets::Page

      module ID
        include Wx::IDHelper

        Start = self.next_id(Widgets::Frame::ID::Last)
        Stop = self.next_id
        IsRunning = self.next_id
      end

      def initialize(book, images)
        super(book, images, :activityindicator)
        @indicator = nil
        @sizerIndicator = nil
      end

      Info = Widgets::PageInfo.new(self, 'ActivityIndicator', Widgets::ALL_CTRLS | Widgets::NATIVE_CTRLS)

      def get_widget
        @indicator
      end

      def recreate_widget
        @sizerIndicator.clear(true) # delete windows
    
        @indicator = Wx::ActivityIndicator.new(@sizerIndicator.get_static_box,
                                               style: get_attrs.default_flags)
    
        @sizerIndicator.add_stretch_spacer
        @sizerIndicator.add(@indicator, Wx::SizerFlags.new.centre)
        @sizerIndicator.add_stretch_spacer
        @sizerIndicator.layout
      end

      # lazy creation of the content
      def create_content
        sizerOper = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Operations')
        sizerOperBox = sizerOper.get_static_box
    
        sizerOper.add(Wx::Button.new(sizerOperBox, ID::Start, '&Start'),
                      Wx::SizerFlags.new.expand.border)
        sizerOper.add(Wx::Button.new(sizerOperBox, ID::Stop, '&Stop'),
                      Wx::SizerFlags.new.expand.border)
    
        sizerOper.add(Wx::StaticText.new(sizerOperBox, ID::IsRunning, 'Indicator is initializing...'),
                      Wx::SizerFlags.new.expand.border)
    
    
        @sizerIndicator = Wx::StaticBoxSizer.new(Wx::HORIZONTAL, self,
                                                 'Activity Indicator')
        recreate_widget

        sizerTop = Wx::HBoxSizer.new
        sizerTop.add(sizerOper, Wx::SizerFlags.new.expand.double_border)
        sizerTop.add(@sizerIndicator, Wx::SizerFlags.new(1).expand.double_border)
    
        set_sizer(sizerTop)

        # connect event handlers
        evt_button(ID::Start, :on_button_start)
        evt_button(ID::Stop, :on_button_stop)

        evt_update_ui(ID::IsRunning, :on_update_is_running)
      end

      protected

      def on_button_start(_)
        @indicator.start
      end

      def on_button_stop(_)
        @indicator.stop
      end

      def on_update_is_running(event)
        event.set_text(@indicator&.is_running ? 'Indicator is running' : 'Indicator is stopped')
      end

    end

  end

end
