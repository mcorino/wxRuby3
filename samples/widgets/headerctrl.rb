# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

module Widgets

  module HeaderCtrl

    class HeaderCtrlPage < Widgets::Page

      NUMBER_OF_COLUMNS = 4

      COL_ALIGNMENTS = %w{none left centre right}
      COL_ALIGN_FLAGS = [Wx::ALIGN_NOT, Wx::ALIGN_LEFT, Wx::ALIGN_CENTRE, Wx::ALIGN_RIGHT]
      COL_WITH_BITMAP_DEFAULT = false
      COL_ALIGNMENT_FLAG_DEFAULT = Wx::ALIGN_NOT
      COL_ALIGNMENT_INDEX_DEFAULT = 0

      ColSettings = Struct.new(:chkAllowResize,
                               :chkAllowReorder,
                               :chkAllowSort,
                               :chkAllowHide,
                               :chkWithBitmap,
                               :rbAlignments)

      def initialize(book, images)
        super(book, images, :header)
        
        @header = nil
        @sizerHeader = nil
      end

      Info = Widgets::PageInfo.new(self, 'Header',
                                   if Wx::PLATFORM == 'WXMSW'
                                     NATIVE_CTRLS
                                   else
                                     GENERIC_CTRLS
                                   end)

      def get_widget
        @header
      end
      
      def recreate_widget
        @sizerHeader.clear(true) # delete windows
    
        flags = get_attrs.default_flags | get_header_style_flags
    
        @header = Wx::HeaderCtrlSimple.new(@sizerHeader.get_static_box, Wx::ID_ANY,
                                           style: flags)
    
        @header.evt_header_resizing(Wx::ID_ANY, self.method(:on_resizing))
        @header.evt_header_begin_resize(Wx::ID_ANY, self.method(:on_begin_resize))
        @header.evt_header_end_resize(Wx::ID_ANY, self.method(:on_end_resize))

        @colSettings.each_with_index do |cs, i|
          col = Wx::HeaderColumnSimple.new("Column #{i + 1}",
                                           from_dip(100),
                                           get_column_alignment_flag(i),
                                           get_column_style_flags(i))
          if cs.chkWithBitmap.is_checked
            icons = [ Wx::ART_ERROR, Wx::ART_QUESTION, Wx::ART_WARNING, Wx::ART_INFORMATION ]
            col.set_bitmap(Wx::ArtProvider.get_bitmap_bundle(icons[i % icons.size], Wx::ART_BUTTON))
          end
          @header.append_column(col)
        end
    
        @sizerHeader.add_stretch_spacer
        @sizerHeader.add(@header, Wx::SizerFlags.new.expand)
        @sizerHeader.add_stretch_spacer
        @sizerHeader.layout
      end
  
      # lazy creation of the content
      def create_content
        # top pane
        sizerTop = Wx::HBoxSizer.new
    
        # header style
        styleSizer = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Header style')
        styleSizerBox = styleSizer.get_static_box
    
        @chkAllowReorder = create_check_box_and_add_to_sizer(styleSizer, 'Allow &reorder', Wx::ID_ANY, styleSizerBox)
        @chkAllowHide = create_check_box_and_add_to_sizer(styleSizer, 'Allow &hide', Wx::ID_ANY, styleSizerBox)
        @chkBitmapOnRight = create_check_box_and_add_to_sizer(styleSizer, '&Bitmap on right', Wx::ID_ANY, styleSizerBox)
        reset_header_style
    
        styleSizer.add_stretch_spacer
        btnReset = Wx::Button.new(styleSizerBox, Wx::ID_ANY, '&Reset')
        styleSizer.add(btnReset, Wx::SizerFlags.new.center_horizontal.border)
        sizerTop.add(styleSizer, Wx::SizerFlags.new.expand)
    
        # column flags
        @colSettings = []
        NUMBER_OF_COLUMNS.times do |i|
          sizerCol = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, "Column #{i+1} style")
          sizerColBox = sizerCol.get_static_box

          @colSettings << ColSettings.new(create_check_box_and_add_to_sizer(sizerCol, 'Allow resize', Wx::ID_ANY, sizerColBox),
                                          create_check_box_and_add_to_sizer(sizerCol, 'Allow reorder', Wx::ID_ANY, sizerColBox),
                                          create_check_box_and_add_to_sizer(sizerCol, 'Allow sort', Wx::ID_ANY, sizerColBox),
                                          create_check_box_and_add_to_sizer(sizerCol, 'Hidden', Wx::ID_ANY, sizerColBox),
                                          create_check_box_and_add_to_sizer(sizerCol, 'With bitmap', Wx::ID_ANY, sizerColBox),
                                          Wx::RadioBox.new(sizerColBox, Wx::ID_ANY, 'Alignment',
                                                           choices: COL_ALIGNMENTS,
                                                           major_dimension: 2,
                                                           style: Wx::RA_SPECIFY_COLS))
          sizerCol.add(@colSettings.last.rbAlignments, Wx::SizerFlags.new.expand.border)
          reset_column_style(i)
          sizerTop.add_spacer(15)
          sizerTop.add(sizerCol, Wx::SizerFlags.new.expand)
        end
    
        # bottom pane
        @sizerHeader = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, 'Header')
        recreate_widget
    
        # the 2 panes compose the window
        sizerAll = Wx::VBoxSizer.new
        sizerAll.add(sizerTop, Wx::SizerFlags.new.expand.border)
        sizerAll.add(@sizerHeader, Wx::SizerFlags.new(1).expand.border)
    
        set_sizer(sizerAll)
    
        # connect event handlers
        @chkAllowReorder.evt_checkbox(Wx::ID_ANY, self.method(:on_style_check_or_radio_box))
        @chkAllowHide.evt_checkbox(Wx::ID_ANY, self.method(:on_style_check_or_radio_box))
        @chkBitmapOnRight.evt_checkbox(Wx::ID_ANY, self.method(:on_style_check_or_radio_box))
        @colSettings.each do |cs|
          cs.chkAllowResize.evt_checkbox(Wx::ID_ANY, self.method(:on_style_check_or_radio_box))
          cs.chkAllowReorder.evt_checkbox(Wx::ID_ANY, self.method(:on_style_check_or_radio_box))
          cs.chkAllowSort.evt_checkbox(Wx::ID_ANY, self.method(:on_style_check_or_radio_box))
          cs.chkAllowHide.evt_checkbox(Wx::ID_ANY, self.method(:on_style_check_or_radio_box))
          cs.chkWithBitmap.evt_checkbox(Wx::ID_ANY, self.method(:on_style_check_or_radio_box))
          cs.rbAlignments.evt_radiobox(Wx::ID_ANY, self.method(:on_style_check_or_radio_box))
        end
        btnReset.evt_button(btnReset, self.method(:on_reset_button))
        btnReset.evt_update_ui(btnReset, self.method(:on_update_ui_reset_button))
      end
  
      protected
      
      # event handlers
      def on_style_check_or_radio_box(_event)
        recreate_widget
      end

      def on_reset_button(_event)
        reset_header_style

        @colSettings.size.times { |i| reset_column_style(i) }

        recreate_widget
      end

      def on_update_ui_reset_button(event)
        enable = get_header_style_flags != Wx::HD_DEFAULT_STYLE
        @colSettings.each_with_index do |cs, i|
          enable = enable ||
            (get_column_style_flags(i) != Wx::COL_DEFAULT_FLAGS) ||
            (cs.chkWithBitmap.is_checked != COL_WITH_BITMAP_DEFAULT) ||
            (cs.rbAlignments.selection != COL_ALIGNMENT_INDEX_DEFAULT)
          break if enable
        end
        event.enable(enable)
      end

      def on_resizing(event)
        Wx.log_message('Column %i resizing, width = %i', event.column + 1, event.width)
        event.skip
      end

      def on_begin_resize(event)
        Wx.log_message('Column %i resize began, width = %i', event.column + 1, event.width)
        event.skip
      end

      def on_end_resize(event)
        Wx.log_message('Column %i resize ended, width = %i', event.column + 1, event.width)
        event.skip
      end
  
      # reset the header style
      def reset_header_style
        @chkAllowReorder.set_value(Wx::HD_DEFAULT_STYLE.allbits?(Wx::HD_ALLOW_REORDER))
        @chkAllowHide.set_value(Wx::HD_DEFAULT_STYLE.allbits?(Wx::HD_ALLOW_HIDE))
        @chkBitmapOnRight.set_value(Wx::HD_DEFAULT_STYLE.allbits?(Wx::HD_BITMAP_ON_RIGHT))
      end

      # compose header style flags based on selections
      def get_header_style_flags
        flags = 0

        flags |= Wx::HD_ALLOW_REORDER if @chkAllowReorder.is_checked
        flags |= Wx::HD_ALLOW_HIDE if @chkAllowHide.is_checked
        flags |= Wx::HD_BITMAP_ON_RIGHT if @chkBitmapOnRight.is_checked

        flags
      end

      # reset column style
      def reset_column_style(col)
        @colSettings[col].chkAllowResize.set_value(Wx::COL_DEFAULT_FLAGS.allbits?(Wx::COL_RESIZABLE))
        @colSettings[col].chkAllowReorder.set_value(Wx::COL_DEFAULT_FLAGS.allbits?(Wx::COL_REORDERABLE))
        @colSettings[col].chkAllowSort.set_value(Wx::COL_DEFAULT_FLAGS.allbits?(Wx::COL_SORTABLE))
        @colSettings[col].chkAllowHide.set_value(Wx::COL_DEFAULT_FLAGS.allbits?(Wx::COL_HIDDEN))
        @colSettings[col].chkWithBitmap.set_value(COL_WITH_BITMAP_DEFAULT)
        @colSettings[col].rbAlignments.set_selection(COL_ALIGNMENT_INDEX_DEFAULT)
      end

      # compose column style flags based on selections
      def get_column_style_flags(col)
        flags = 0

        flags |= Wx::COL_RESIZABLE if @colSettings[col].chkAllowResize.is_checked
        flags |= Wx::COL_REORDERABLE if @colSettings[col].chkAllowReorder.is_checked
        flags |= Wx::COL_SORTABLE if @colSettings[col].chkAllowSort.is_checked
        flags |= Wx::COL_HIDDEN if @colSettings[col].chkAllowHide.is_checked

        flags
      end

      # get column alignment flags based on selection
      def get_column_alignment_flag(col)
        sel = @colSettings[col].rbAlignments.selection
        sel == Wx::NOT_FOUND ? COL_ALIGNMENT_FLAG_DEFAULT : COL_ALIGN_FLAGS[sel]
      end
      
    end

  end

end
