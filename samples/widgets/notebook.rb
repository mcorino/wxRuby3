# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets widgets sample
# Copyright (c) 2001 Vadim Zeitlin

module Widgets

  module Book

    class BookPage < Widgets::Page

      module ID
        include Wx::IDHelper

        Reset = self.next_id(Widgets::Frame::ID::Last)
        SelectPage = self.next_id
        AddPage = self.next_id
        InsertPage = self.next_id
        RemovePage = self.next_id
        DeleteAll = self.next_id
        InsertText = self.next_id
        RemoveText = self.next_id
        SelectText = self.next_id
        NumPagesText = self.next_id
        CurSelectText = self.next_id
        Book = self.next_id

        Orient_Top = 0
        Orient_Bottom = 1
        Orient_Left = 2
        Orient_Right = 3
        Orient_Max = 4
      end

      def initialize(book, images, icon)
        super
        
        # init everything
        @chkImages = nil
        @imageList = nil
    
        @book = nil
        @radioOrient = nil
        @sizerBook = nil
      end
  
      def get_widget
        @book
      end
      
      def recreate_widget
        recreate_book
      end
  
      # lazy creation of the content
      def create_content
        sizerTop = Wx::HBoxSizer.new
    
        # left pane
        sizerLeft = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Set style')
        sizerLeftBox = sizerLeft.get_static_box
    
        # must be in sync with Orient enum
        orientations = %w[&top &bottom &left &right]
    
        @chkImages = Wx::CheckBox.new(sizerLeftBox, Wx::ID_ANY, 'Show &images')
        @radioOrient = Wx::RadioBox.new(sizerLeftBox, Wx::ID_ANY, '&Tab orientation',
                                        choices: orientations, 
                                        major_dimension: 1, 
                                        style: Wx::RA_SPECIFY_COLS)
    
        sizerLeft.add(@chkImages, 0, Wx::ALL, 5)
        sizerLeft.add(5, 5, 0, Wx::GROW | Wx::ALL, 5) # spacer
        sizerLeft.add(@radioOrient, 0, Wx::ALL, 5)
    
        btn = Wx::Button.new(sizerLeftBox, ID::Reset, '&Reset')
        sizerLeft.add(btn, 0, Wx::ALIGN_CENTRE_HORIZONTAL | Wx::ALL, 15)
    
        # middle pane
        sizerMiddle = Wx::StaticBoxSizer.new(Wx::VERTICAL, self, '&Contents')
        sizerMiddleBox = sizerMiddle.get_static_box

        sizerRow, text = create_sizer_with_text_and_label('Number of pages: ',
                                                          ID::NumPagesText,
                                                          sizerMiddleBox)
        text.set_editable(false)
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, text = create_sizer_with_text_and_label('Current selection: ',
                                                          ID::CurSelectText,
                                                          sizerMiddleBox)
        text.set_editable(false)
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, @textSelect = create_sizer_with_text_and_button(ID::SelectPage,
                                                                  '&Select page',
                                                                  ID::SelectText,
                                                                  sizerMiddleBox)
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::AddPage, '&Add page')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, @textInsert = create_sizer_with_text_and_button(ID::InsertPage,
                                                                  '&Insert page at',
                                                                  ID::InsertText,
                                                                  sizerMiddleBox)
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)

        sizerRow, @textRemove = create_sizer_with_text_and_button(ID::RemovePage,
                                                                  '&Remove page',
                                                                  ID::RemoveText,
                                                                  sizerMiddleBox)
        sizerMiddle.add(sizerRow, 0, Wx::ALL | Wx::GROW, 5)
    
        btn = Wx::Button.new(sizerMiddleBox, ID::DeleteAll, '&Delete All')
        sizerMiddle.add(btn, 0, Wx::ALL | Wx::GROW, 5)
    
        # right pane
        @sizerBook = Wx::HBoxSizer.new
    
        # the 3 panes compose the window
        sizerTop.add(sizerLeft, 0, Wx::GROW | (Wx::ALL & ~Wx::LEFT), 10)
        sizerTop.add(sizerMiddle, 0, Wx::GROW | Wx::ALL, 10)
        sizerTop.add(@sizerBook, 1, Wx::GROW | (Wx::ALL & ~Wx::RIGHT), 10)
    
        recreate_book
    
        # final initializations
        reset
        create_image_list
    
        set_sizer(sizerTop)
    
        # connect event handlers
        evt_button(ID::Reset, :on_button_reset)
        evt_button(ID::SelectPage, :on_button_select_page)
        evt_button(ID::AddPage, :on_button_add_page)
        evt_button(ID::InsertPage, :on_button_insert_page)
        evt_button(ID::RemovePage, :on_button_remove_page)
        evt_button(ID::DeleteAll, :on_button_delete_all)
    
        evt_update_ui(ID::NumPagesText, :on_update_ui_num_pages_text)
        evt_update_ui(ID::CurSelectText, :on_update_ui_cur_select_text)
    
        evt_update_ui(ID::SelectPage, :on_update_ui_select_button)
        evt_update_ui(ID::InsertPage, :on_update_ui_insert_button)
        evt_update_ui(ID::RemovePage, :on_update_ui_remove_button)
    
        evt_checkbox(Wx::ID_ANY, :on_check_or_radio_box)
        evt_radiobox(Wx::ID_ANY, :on_check_or_radio_box)
      end
  
      protected

      # event handlers
      def on_button_reset(event)
        reset

        recreate_book
      end

      def on_button_delete_all(event)
        @book.delete_all_pages
      end

      def on_button_select_page(event)
        pos = get_text_value(@textSelect)
        ::Kernel.raise RuntimeError, 'button should be disabled' unless is_valid_value(pos)

        @book.set_selection(pos)
      end

      def on_button_add_page(event)
        @book.add_page(create_new_page, 'Added page', false, get_icon_index)
      end

      def on_button_insert_page(event)
        pos = get_text_value(@textInsert)
        ::Kernel.raise RuntimeError, 'button should be disabled' unless is_valid_value(pos)

        @book.insert_page(pos, create_new_page, 'Inserted page', false, get_icon_index)
      end

      def on_button_remove_page(event)
        pos = get_text_value(@textRemove)
        ::Kernel.raise RuntimeError, 'button should be disabled' unless is_valid_value(pos)

        @book.delete_page(pos)
      end
  
      def on_check_or_radio_box(event)
        recreate_book
      end
  
      def on_update_ui_num_pages_text(event)
        event.set_text(@book.page_count.to_s) if @book
      end

      def on_update_ui_cur_select_text(event)
        event.set_text(@book.selection.to_s) if @book
      end
  
      def on_update_ui_select_button(event)
        event.enable(is_valid_value(get_text_value(@textSelect)))
      end

      def on_update_ui_insert_button(event)
        event.enable(is_valid_value(get_text_value(@textInsert)))
      end

      def on_update_ui_remove_button(event)
        event.enable(is_valid_value(get_text_value(@textRemove)))
      end
  
      def on_update_ui_reset_button(event)
        if @chkImages && @radioOrient
            event.enable(!@chkImages.value || @radioOrient.selection != Wx::BK_TOP)
        end
      end
  
      # reset book parameters
      def reset
        @chkImages.set_value(true)
        @radioOrient.set_selection(ID::Orient_Top)
      end
  
      # (re)create book
      def recreate_book
        # do not recreate anything in case page content was not prepared yet
        return unless @radioOrient
    
        flags = get_attrs.default_flags
    
        case @radioOrient.selection
        when ID::Orient_Top
          flags |= Wx::BK_TOP
        when ID::Orient_Bottom
          flags |= Wx::BK_BOTTOM
        when ID::Orient_Left
          flags |= Wx::BK_LEFT
        when ID::Orient_Right
          flags |= Wx::BK_RIGHT
        else
          ::Kernel.raise RuntimeError, 'unknown orientation'
        end
    
        oldBook = @book
    
        @book = create_book(flags)
    
        create_image_list
    
        if oldBook
          sel = oldBook.selection

          count = oldBook.page_count

          # recreate the pages
          count.times do |n|
            @book.add_page(create_new_page,
                           oldBook.get_page_text(n),
                           false,
                           @chkImages.value ? get_icon_index : -1)
          end

          @sizerBook.detach(oldBook)
          oldBook.destroy

          # restore selection
          @book.set_selection(sel) if sel != -1
        end
    
        @sizerBook.add(@book, 1, Wx::GROW | Wx::ALL, 5)
        @sizerBook.set_min_size(150, 0)
        @sizerBook.layout
      end

      def create_book(flags)
        ::Kernel.raise NotImplementedError
      end
  
      # create or destroy the image list
      def create_image_list
        if @chkImages.value
          unless @imageList
            # create a dummy image list with a few icons
            @imageList = []
            # wxSize size(32, 32);
            @imageList << Wx::BitmapBundle.new(Wx::ArtProvider.get_icon(Wx::ART_INFORMATION, Wx::ART_OTHER,[32,32]))
            @imageList << Wx::BitmapBundle.new(Wx::ArtProvider.get_icon(Wx::ART_QUESTION, Wx::ART_OTHER,[32,32]))
            @imageList << Wx::BitmapBundle.new(Wx::ArtProvider.get_icon(Wx::ART_WARNING, Wx::ART_OTHER,[32,32]))
            @imageList << Wx::BitmapBundle.new(Wx::ArtProvider.get_icon(Wx::ART_ERROR, Wx::ART_OTHER,[32,32]))
          end

          @book.set_images(@imageList) if @book
        else # no images
          @book.set_images([]) if @book
        end
      end
  
      # create a new page
      def create_new_page
        Wx::TextCtrl.new(@book, Wx::ID_ANY, "I'm a book page")
      end
  
      # get the image index for the new page
      def get_icon_index
        if @book
          nImages = @book.get_image_count
          return (@book.get_page_count % nImages) if nImages > 0
        end
    
        -1
      end
  
      # get the numeric value of text ctrl
      def get_text_value(text)
        if text.nil? || text.value.empty?
          -1
        else
          Integer(text.value) rescue -1
        end
      end
  
      # is the value in range?
      def is_valid_value(val)
        (val >= 0) && (val < @book.get_page_count)
      end
      
    end

    if Wx.has_feature?(:USE_NOTEBOOK)

      class NotebookPage < BookPage

        def initialize(book, images)
          super(book, images, :notebook)
          recreate_book
        end

        Info = Widgets::PageInfo.new(self, 'Notebook',
                                     NATIVE_CTRLS |
                                       BOOK_CTRLS)

        def create_content
          super
          # connect Notebook event handlers
          evt_notebook_page_changing(Wx::ID_ANY, :on_page_changing)
          evt_notebook_page_changed(Wx::ID_ANY, :on_page_changed)
        end

        protected

        # event handlers
        def on_page_changing(event)
          Wx.log_message("Notebook page changing from %d to %d (currently %d).",
                         event.old_selection,
                         event.selection,
                         @book.selection)

          event.skip
        end

        def on_page_changed(event)
          Wx.log_message("Notebook page changed from %d to %d (currently %d).",
                         event.old_selection,
                         event.selection,
                         @book.selection)

          event.skip
        end

        # (re)create book
        def create_book(flags)
          Wx::Notebook.new(self, ID::Book,
                           style: flags)
        end
      end

    end

    if Wx.has_feature?(:USE_LISTBOOK)

      class ListbookPage < BookPage

        def initialize(book, images)
          super(book, images, :listbook)
          recreate_book
        end

        Info = Widgets::PageInfo.new(self, 'Listbook',
                                     GENERIC_CTRLS |
                                       BOOK_CTRLS)

        def create_content
          super
          # connect Notebook event handlers
          evt_listbook_page_changing(Wx::ID_ANY, :on_page_changing)
          evt_listbook_page_changed(Wx::ID_ANY, :on_page_changed)
        end

        protected

        # event handlers
        def on_page_changing(event)
          Wx.log_message("Listbook page changing from %d to %d (currently %d).",
                         event.old_selection,
                         event.selection,
                         @book.selection)

          event.skip
        end

        def on_page_changed(event)
          Wx.log_message("Listbook page changed from %d to %d (currently %d).",
                         event.old_selection,
                         event.selection,
                         @book.selection)

          event.skip
        end

        # (re)create book
        def create_book(flags)
          Wx::Listbook.new(self, ID::Book,
                           style: flags)
        end

      end

    end

    if Wx.has_feature?(:USE_CHOICEBOOK)

      class ChoicebookPage < BookPage

        def initialize(book, images)
          super(book, images, :choicebk)
          recreate_book
        end

        Info = Widgets::PageInfo.new(self, 'Choicebook',
                                     GENERIC_CTRLS |
                                       BOOK_CTRLS)

        def create_content
          super
          # connect Notebook event handlers
          evt_listbook_page_changing(Wx::ID_ANY, :on_page_changing)
          evt_listbook_page_changed(Wx::ID_ANY, :on_page_changed)
        end

        protected

        # event handlers
        def on_page_changing(event)
          Wx.log_message("Choicebook page changing from %d to %d (currently %d).",
                         event.old_selection,
                         event.selection,
                         @book.selection)

          event.skip
        end

        def on_page_changed(event)
          Wx.log_message("Choicebook page changed from %d to %d (currently %d).",
                         event.old_selection,
                         event.selection,
                         @book.selection)

          event.skip
        end

        # (re)create book
        def create_book(flags)
          Wx::Choicebook.new(self, ID::Book,
                             style: flags)
        end

      end

    end
  end

end
