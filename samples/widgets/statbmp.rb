# Copyright (c) 2023 M.J.N. Corino = self.next_id The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

module Widgets

  module StatBmp

    class StatBmpPage < Widgets::Page

      def initialize(book, images)
        super(book, images, :statbmp)
      end

      Info = Widgets::PageInfo.new(self, 'StaticBitmap')

      def create_content
        choices = %w[native generic]
        @radio = Wx::RadioBox.new(self, Wx::ID_ANY, 'Implementation',
                                  choices: choices)

        scaleChoices = ['None', 'Fill', 'Aspect Fit', 'Aspect Fill']
        @scaleRadio = Wx::RadioBox.new(self, Wx::ID_ANY, 'Scale Mode',
                                       choices: scaleChoices)

        testImage = ''
        if Wx.has_feature?(:USE_LIBPNG)
          fn = Wx::ArtLocator.find_art(:toucan, art_section: 'widgets', bmp_type: Wx::BitmapType::BITMAP_TYPE_PNG)
          testImage = fn if fn
        end
        @filepicker = Wx::FilePickerCtrl.new(self, Wx::ID_ANY, testImage)
    
        @sbsizer = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, 'wxStaticBitmap inside')
    
        leftsizer = Wx::VBoxSizer.new
        leftsizer.add(@radio, Wx::SizerFlags.new.expand.border)
        leftsizer.add(@scaleRadio, Wx::SizerFlags.new.expand.border)
        leftsizer.add(@filepicker, Wx::SizerFlags.new.expand.border)
        sizer = Wx::HBoxSizer.new
        sizer.add(leftsizer, Wx::SizerFlags.new.border)
        sizer.add(@sbsizer, Wx::SizerFlags.new.border)
        set_sizer(sizer)

        evt_filepicker_changed(Wx::ID_ANY, :on_file_change)
        evt_radiobox(Wx::ID_ANY, :on_radio_change)

        @statbmp = nil
        recreate_widget
      end

      def get_widget
        @statbmp
      end

      def recreate_widget
        if @statbmp
          @statbmp.destroy
        end

        bmp = Wx::Bitmap.new

        filepath = @filepicker.path
        unless filepath.empty?
          image = Wx::Image.new(filepath)
          if image.ok?
            bmp = image
          else
            Wx.log_message("Reading image from file '#{filepath}' failed.")
          end
        end
    
        unless bmp.ok?
          # Show at least something.
          bmp = Wx::ArtProvider.get_bitmap(Wx::ART_MISSING_IMAGE)
        end
    
        style = get_attrs.default_flags
    
        if @radio.selection == 0
          @statbmp = Wx::StaticBitmap.new(@sbsizer.get_static_box, Wx::ID_ANY, bmp,
                                          style: style)
        else
          @statbmp = Wx::GenericStaticBitmap.new(@sbsizer.get_static_box, Wx::ID_ANY, bmp,
                                                 style: style)
        end
    
        scaleMode = Wx::StaticBitmap::ScaleMode.new(@scaleRadio.selection)
        @statbmp.set_scale_mode(scaleMode)
        Wx.log_error('Scale mode not supported by current implementation') if @statbmp.get_scale_mode != scaleMode

        sbsizerItem = get_sizer.get_item(@sbsizer)
        if scaleMode == Wx::StaticBitmap::ScaleMode::Scale_None
          sbsizerItem.set_proportion(0)
          sbsizerItem.set_flag(Wx::CENTER)
        else
          sbsizerItem.set_proportion(1)
          sbsizerItem.set_flag(Wx::EXPAND)
        end
        @sbsizer.add(@statbmp, Wx::SizerFlags.new(1).expand)
        get_sizer.layout

        @statbmp.evt_left_down(method(:on_mouse_event))

        # When switching from generic to native control on wxMSW under Wine,
        # the explicit refresh is necessary
        @statbmp.refresh
      end
  
      protected

      def on_file_change(_ev)
        recreate_widget
      end

      def on_radio_change(_ev)
        recreate_widget
      end
  
      def on_mouse_event(_event)
        Wx.log_message('wxStaticBitmap clicked.')
      end

    end

  end

end
