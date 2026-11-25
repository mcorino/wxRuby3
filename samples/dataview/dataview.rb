# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Adapted for Wx::Ruby3
###

require 'wx'

module DataView

  # ----------------------------------------------------------------------------
  # MyMusicTreeModelNode: a node inside MyMusicTreeModel
  # ----------------------------------------------------------------------------
  
  class MyMusicTreeModelNode
    def initialize(parent, title_or_branch, *rest)
      @parent = parent

      @title = title_or_branch
      @artist, @year = *rest
      @quality = rest.empty? ? nil : 'good'
      @container = rest.empty?
      @children = []
    end

    attr_reader :parent, :children
    attr_accessor :title, :artist, :year, :quality

    # TODO/FIXME:
    # the GTK version of wxDVC (in particular wxDataViewCtrlInternal::ItemAdded)
    # needs to know in advance if a node is or _will be_ a container.
    # Thus implementing:
    #   bool IsContainer() const
    #    { return !m_children.empty(); }
    # doesn't work with wxGTK when MyMusicTreeModel::AddToClassical is called
    # AND the classical node was removed (a new node temporary without children
    # would be added to the control)

    def container?
      @container
    end

    def get_nth_child(n)
      @children.at(n)
    end

    def insert(child, n)
      @children.insert(n, child)
    end

    def append(child)
      @children << child
    end

    def child_count
      @children.size
    end
  end

  # ----------------------------------------------------------------------------
  # MyMusicTreeModel
  # ----------------------------------------------------------------------------

  # Implement this data model
  #             Title               Artist               Year        Judgement
  # --------------------------------------------------------------------------
  # 1: My Music:
  #     2:  Pop music
  #         3:  You are not alone   Michael Jackson      1995        good
  #         4:  Take a bow          Madonna              1994        good
  #     5:  Classical music
  #         6:  Ninth Symphony      Ludwig v. Beethoven  1824        good
  #         7:  German Requiem      Johannes Brahms      1868        good

  class MyMusicTreeModel < Wx::DVW::DataViewModel

    def initialize
      super
      @root = MyMusicTreeModelNode.new(nil, 'My Music')
  
      # setup pop music
      @pop = MyMusicTreeModelNode.new(@root, 'Pop music')
      @pop.append(MyMusicTreeModelNode.new(@pop, 'You are not alone', 'Michael Jackson', 1995))
      @pop.append(MyMusicTreeModelNode.new(@pop, 'Yesterday', 'The Beatles')) # year not specified
      @pop.append(MyMusicTreeModelNode.new(@pop, 'Take a bow', "Madonna", 1994))
      @root.append(@pop)
  
      # setup classical music
      @classical = MyMusicTreeModelNode.new(@root, 'Classical music')
      @ninth = MyMusicTreeModelNode.new(@classical, 'Ninth symphony','Ludwig van Beethoven', 1824)
      @classical.append(@ninth)
      @classical.append(MyMusicTreeModelNode.new(@classical, 'German Requiem','Johannes Brahms', 1868))
      @root.append(@classical)
    end

    # @return [MyMusicTreeModelNode, nil]
    def _id2node(id)
      node = id ? ::ObjectSpace._id2ref(id) : nil
      raise ArgumentError, 'invalid node id' unless node.nil? || MyMusicTreeModelNode === node
      node
    end
    private :_id2node

    # @return [::Integer]
    def _node2id(node)
      MyMusicTreeModelNode === node ? node.object_id : 0
    end
    private :_node2id

    # helper method for wxLog

    def get_title(item)
      node = _id2node(item) rescue nil
      node ? node.title : ''
    end

    def get_artist(item)
      node = _id2node(item) rescue nil
      node ? node.artist : ''
    end

    def get_year(item)
      node = _id2node(item) rescue nil
      node ? node.year : 2000
    end

    # helper methods to change the model

    def add_to_classical(title, artist, year)
      unless @classical
        # it was removed: restore it
        @classical = MyMusicTreeModelNode.new(@root, 'Classical music')
        @root.append(@classical)

        # notify control
        item_added(_node2id(@root), _node2id(@classical))
      end
  
      # add to the classical music node a new node:
      child_node = MyMusicTreeModelNode.new(@classical, title, artist, year)
      @classical.append(child_node)
  
      # notify control
      item_added(_node2id(@classical), _node2id(child_node))
    end

    def delete(item)
      node = _id2node(item) rescue return

      unless node.parent
          # don't make the control completely empty:
          Wx.log_error('Cannot remove the root item!')
          return
      end
  
      # is the node one of those we keep stored in special pointers?
      if node == @pop
        @pop = nil
      elsif node == @classical
        @classical = nil
      elsif node == @ninth
        @ninth = nil
      end
  
      # first remove the node from the parent's array of children
      siblings = node.parent.children
      siblings.delete(node)

      # notify control
      item_deleted(_node2id(node.parent), item)
    end

    def clear
      @pop = @classical = @ninth = nil

      @root.children.clear

      cleared
    end

    def get_ninth_item
      _node2id(@ninth)
    end

    # override sorting to always sort branches ascendingly

    def compare(item1, item2, column, ascending)
      node1 = _id2node(item1)
      node2 = _id2node(item2)

      unless MyMusicTreeModelNode === node1 && MyMusicTreeModelNode === node2
        raise ArgumentError, 'invalid node ids'
      end
      # should never happen

      if node1.container? && node2.container?
        value1 = _get_node_value(node1, 0)
        value2 = _get_node_value(node2, 0)

        res = value1.to_s <=> value2.to_s
        return res unless res == 0

        # items must be different
        return item1 <=> item2
      end

      super(item1, item2, column, ascending)
    end

    # implementation of base class virtuals to define model

    def _get_node_value(node, col)
      case col
      when 0
        node.title
      when 1
        node.artist
      when 2
        node.year
      when 3
        node.quality
      when 4
        80  # all music is very 80% popular
      when 5
        if node.year.nil?
          'n/a'
        elsif node.year < 1900
          'old'
        else
          'new'
        end
  
      else
        Wx.log_error( "MyMusicTreeModel#get_value: wrong column %d", col )
        nil
      end
    end
    protected :_get_node_value

    def get_value(item, col)
      Wx::Variant.new(_get_node_value(_id2node(item), col))
    end
    alias :value :get_value

    def set_value(variant, item, col)
      node = _id2node(item)
      case col
      when 0
        node.title = variant.to_s
      when 1
        node.artist = variant.to_s
      when 2
        node.year = variant.to_i
      when 3
        node.quality = variant.to_s
      else
        Wx.log_error( "MyMusicTreeModel::SetValue: wrong column" )
        return false
      end
      true
    end
    alias :value= :set_value

    def is_enabled(item, col)
      node = _id2node(item)
      # disable Beethoven's ratings, his pieces can only be good
      return false if col == 3 && node.artist.end_with?('Beethoven')

      # also disable editing the year when it's not specified, this doesn't work
      # because the editor needs some initial value
      return false if col == 2 && node.year.nil?

      # otherwise allow editing
      true
    end
    alias :enabled? :is_enabled

    def get_parent(item)
      node = _id2node(item)
      node ? _node2id(node.parent) : 0
    end
    alias :parent :get_parent

    def is_container(item)
      node = _id2node(item)
      node ? node.container? : true
    end
    alias :container? :is_container

    def get_children(parent)
      node = _id2node(parent)
      if node
        node.children.collect { |c| _node2id(c) }
      else
        [_node2id(@root)]
      end
    end
    alias :children :get_children

  end


  # ----------------------------------------------------------------------------
  # MyLongMusicTreeModel
  # ----------------------------------------------------------------------------

  class MyLongMusicTreeModel <  MyMusicTreeModel

    def initialize
      super
      50.times do
        add_to_classical("The Four Seasons", "Antonio Vivaldi", 1721)
        add_to_classical("La costanza trionfante degl'amori e de gl'odii", "Antonio Vivaldi", 1716)
      end
    end

  end

  # ----------------------------------------------------------------------------
  # MyListModel
  # ----------------------------------------------------------------------------

  # ModelFlags
  MODEL_USE_TALL_ROWS = 1 << 0
  MODEL_KEEP_LOGO_SMALL = 1 << 1
  MODEL_USE_MULTI_LINE_TEXT = 1 << 2

  def self.get_icon_size_from_model_flags(model_flags)
    size = [16, 16]
    size.map! {|e| e*2 } if (model_flags & MODEL_USE_TALL_ROWS) && !(model_flags & MODEL_KEEP_LOGO_SMALL)
    size
  end

  class MyListModel < Wx::DVW::DataViewVirtualListModel

    Col_ToggleIconText = 0
    Col_EditableText = 1
    Col_Date = 2
    Col_TextWithAttr = 3
    Col_Custom = 4

    INITIAL_NUMBER_OF_ITEMS = 10000
  
    def initialize(model_flags)
      super(INITIAL_NUMBER_OF_ITEMS)
      multi_line_text = "top (\u1ED6)\ncentre\nbottom (g)"
      use_multi_line = (model_flags & MODEL_USE_MULTI_LINE_TEXT) != 0
  
      # the first 100 items are really stored in this model
      # all the others are synthesized on request
      number_real_items = 100
  
      @toggle_col_values = [false]
      @text_col_values = [use_multi_line ? multi_line_text : 'first row with long label to test ellipsization']
      (number_real_items-1).times do |i|
        @toggle_col_values << false
        @text_col_values << "real row #{i+1}"
      end
  
      @icon_col_values = ::Array.new(number_real_items, use_multi_line ? multi_line_text : 'test')

      size = DataView.get_icon_size_from_model_flags(model_flags)
  
      @icon = [
        Wx::ArtProvider.get_bitmap_bundle(Wx::ART_QUESTION, Wx::ART_LIST, size),
        Wx::ArtProvider.get_bitmap_bundle(Wx::ART_WX_LOGO, Wx::ART_LIST, size) ]

      @custom_col_values = {}
    end

    # helper methods to change the model

    def prepend(text)
      @toggle_col_values.prepend(false)
      @text_col_values.prepend(text)
      row_prepended
    end

    def delete_item(item)
      row = get_row(item)
  
      return if row >= @toggle_col_values.size
      @toggle_col_values.delete_at(row)
  
      return if row >= @text_col_values.size
      @text_col_values.delete_at(row)

      row_deleted(row)
    end

    def delete_items(*items)
      items.flatten!
      rows = items.collect do |itm|
        row = get_row(itm)
        if row < @text_col_values.size
          raise 'inconsistent model' unless row < @toggle_col_values.size
          row
        else
          nil
        end
      end.compact

      if rows.empty?
          # none of the selected items were in the range of the items
          # which we store... for simplicity, don't allow removing them
          Wx.log_error( "Cannot remove rows with an index greater than #{@text_col_values.size}")
          return
      end
  
      # Sort in descending order so that the last
      # row will be deleted first. Otherwise the
      # remaining indices would all be wrong.
      rows.sort { |a,b| b <=> a }
      rows.each do |row|
          @toggle_col_values.delete_at(row)
          @text_col_values.delete_at(row)
      end
  
      # This is just to test if wxDataViewCtrl can
      # cope with removing rows not sorted in
      # descending order
      rows.sort
      rows_deleted(rows)
    end

    def add_many
      reset(get_count+1000)
    end

    # implementation of base class virtuals to define model

    def get_value_by_row(row, col)
      case col
      when Col_EditableText
        if row >= @text_col_values.size
          "virtual row #{row}"
        else
          @text_col_values[row]
        end

      when Col_ToggleIconText
        if row >= @icon_col_values.size
          text = "virtual icon"
          state = Wx::CHK_UNDETERMINED
        else
          text = @icon_col_values[row]
          state = @toggle_col_values[row] ? Wx::CHK_CHECKED : Wx::CHK_UNCHECKED
        end

        Wx::DVW::DataViewCheckIconText.new(text, @icon[row % 2], state)

      when Col_Date
        Time.new(2000, 1, 1) + (row * 3600)

      when Col_TextWithAttr
        labels = [
            # These strings will look wrong without Wx::USE_MARKUP, but
            # it's just a sample, so we don't care.
            ("<span color=\"#87ceeb\">light</span> and "
                "<span color=\"#000080\">dark</span> blue"),
            "<big>growing green</big>",
            "<i>emphatic &amp red</i>",
            "<b>bold &amp&amp cyan</b>",
            "<small><tt>dull default</tt></small>",
        ]
        labels[row % 5]

      when Col_Custom
        @custom_col_values[row] || (row % 100).to_s
      else
        return nil
      end
    end

    def get_attr_by_row(row, col)
      attr = Wx::DVW::DataViewItemAttr.new
      case col
      when Col_EditableText, Col_Date
        if row < @toggle_col_values.size
            if @toggle_col_values[row]
              attr.set_colour(Wx::LIGHT_GREY)
              attr.set_strikethrough(true)
              return attr
            end
        end

      when Col_ToggleIconText
        unless (row % 2) == 0
          attr.set_colour(Wx::YELLOW)
          attr.set_background_colour(Wx::LIGHT_GREY)
          return attr
        end

      when Col_TextWithAttr, Col_Custom
        if col == Col_TextWithAttr && row < @toggle_col_values.size
          if @toggle_col_values[row]
            attr.set_colour(Wx::LIGHT_GREY)
            attr.set_strikethrough(true)
            return attr
          end
        end

        # do what the labels defined in GetValueByRow() hint at
        case (row % 5)
        when 0
          attr.set_colour(Wx::BLUE)
        when 1
          attr.set_colour(Wx::GREEN)
        when 2
          attr.set_colour(Wx::RED)
        when 3
          attr.set_colour(Wx::CYAN)
          attr.set_bold(true)
        else
          return nil
        end
        return attr
      else
        return attr
      end
  
      nil
    end

    def set_value_by_row(variant, row, col)
      case col
      when Col_EditableText, Col_ToggleIconText
        if row >= @text_col_values.size
            # the item is not in the range of the items
            # which we store... for simplicity, don't allow editing it
            Wx.log_error( "Cannot edit rows with an index greater than #{@text_col_values.size}")
            return false
        end

        if col == Col_EditableText
          @text_col_values[row] = variant.to_s
        else # col == Col_ToggleIconText
          check_icon_text = variant.data_view_check_icon_text
          @toggle_col_values[row] = (check_icon_text.get_checked_state == Wx::CHK_CHECKED)
          @icon_col_values[row] = check_icon_text.get_text
        end

      when Col_Date, Col_TextWithAttr
        Wx.log_error("Cannot edit the column #{col}")
        return false

      when Col_Custom
        @custom_col_values[row] = variant.to_s
      else
        return false
      end
  
      true
    end
  end

  # ----------------------------------------------------------------------------
  # MyListStoreDerivedModel
  # ----------------------------------------------------------------------------
  
  class MyListStoreDerivedModel < Wx::DVW::DataViewListStore

    def is_enabled_by_row(row, col)
      # disabled the last two checkboxes
      !(col == 0 && 8 <= row && row <= 9)
    end

  end

  # ----------------------------------------------------------------------------
  # MyListStoreHasValueModel
  # ----------------------------------------------------------------------------
  
  class MyListStoreHasValueModel < MyListStoreDerivedModel

    def has_value(item, col)
      row = get_row(item)
      # the diagonal entries don't have values. This is just a silly example to demonstrate the
      # usage of overriding HasValue to specify that some columns don't have values for some items
      row != col
    end

  end
  
  # ----------------------------------------------------------------------------
  # MyIndexListModel
  # ----------------------------------------------------------------------------
  
  class MyIndexListModel < Wx::DVW::DataViewIndexListModel

    def initialize
      super
    end

    def fill(strings)
      @strings = strings

      reset(@strings.size)
    end

    # Implement base class pure virtual methods.
    def get_count
      @strings.size
    end
    alias :count :get_count

    def get_value_by_row(row, _)
      @strings[row]
    end

    def set_value_by_row(_, _, _)
      false
    end
  
  end

  # ----------------------------------------------------------------------------
  # MyCustomRenderer
  # ----------------------------------------------------------------------------
  
  class MyCustomRenderer < Wx::DVW::DataViewCustomRenderer
    # This renderer can be either activatable or editable, for demonstration
    # purposes. In real programs, you should select whether the user should be
    # able to activate or edit the cell and it doesn't make sense to switch
    # between the two -- but this is just an example, so it doesn't stop us.
    def initialize(mode)
      super("string", mode, Wx::ALIGN_CENTER)
    end

    def render(rect, dc, state)
      dc.set_brush(Wx::LIGHT_GREY_BRUSH)
      dc.set_pen(Wx::TRANSPARENT_PEN)

      rect.deflate(2)
      dc.draw_rounded_rectangle(rect, 5)

      render_text(@value,
                 0, # no offset
                  Wx::Rect.new(*dc.get_text_extent(@value)).centre_in(rect),
                  dc,
                  state)
      true
    end

    def activate_cell(_,
                      _,
                      _,
                      _,
                      mouse_event)
      position = if mouse_event
          "via mouse at #{mouse_event.x}, #{mouse_event.y}"
      else
          "from keyboard"
      end
      Wx.log_message("MyCustomRenderer activate_cell() #{position}")
      false
    end

    def get_size
      get_view.from_dip([60, 20].to_size)
    end

    def set_value(value)
      @value = value.to_s
      true
    end

    def get_value
      @value
    end

    if Wx.has_feature?(:USE_ACCESSIBILITY)
      def get_accessible_description
        @value
      end
    end # USE_ACCESSIBILITY

    def has_editor_ctrl
      true
    end

    def create_editor_ctrl(parent,
                           label_rect,
                           value)
        text = Wx::TextCtrl.new(parent, Wx::ID_ANY, value.to_s,
                                label_rect.position,
                                label_rect.size,
                                Wx::TE_PROCESS_ENTER)
        text.set_insertion_point_end

        text
    end

    def get_value_from_editor_ctrl(ctrl, value)
      return nil unless Wx::TextCtrl === text

      text.value
    end
  end
  
  
  # ----------------------------------------------------------------------------
  # MultiLineCustomRenderer
  # ----------------------------------------------------------------------------
  
  class MultiLineCustomRenderer < Wx::DVW::DataViewCustomRenderer
    # a simple renderer that wraps each word on a new line
    def initialize
      super("string", Wx::DVW::DATAVIEW_CELL_INERT, 0)
    end

    def render(rect, dc, state)
      render_text(@value, 0, rect, dc, state)
      true
    end

    def get_size
      txtSize = get_text_extent(@value)
      lines = @value.count("\n") + 1
      txtSize.set_height(txtSize.get_height * lines)
      txtSize
    end

    def set_value(value)
      @value = value.to_s
      @value.gsub!(" ", "\n")
      true
    end

    def get_value
      @value
    end

    if Wx.has_feature?(:USE_ACCESSIBILITY)
      def get_accessible_description
        @value
      end
    end # USE_ACCESSIBILITY
  end

  # ============================================================================
  # implementation
  # ============================================================================

  Wx::ArtLocator.add_search_path(File.dirname(__dir__))

  class DVFrame < Wx::Frame

    module ID
      include Wx::IDHelper
      
      CLEARLOG = self.next_id
      GET_PAGE_INFO = self.next_id
      HIT_TEST = self.next_id
      DISABLE = self.next_id
      CLEAR_MODEL = self.next_id
      BACKGROUND_COLOUR = self.next_id
      FOREGROUND_COLOUR = self.next_id
      CUSTOM_HEADER_ATTR = self.next_id
      if Wx::DVW::HAS_GENERIC_DATAVIEWCTRL
      CUSTOM_HEADER_HEIGHT = self.next_id
      end # HAS_GENERIC_DATAVIEWCTRL
      STYLE_MENU = self.next_id
      INC_INDENT = self.next_id
      DEC_INDENT = self.next_id
      LAYOUT_DIR = self.next_id
  
      # file menu
      #SINGLE = self.next_id        wxDV_SINGLE==0 so it's always present
      MULTIPLE = self.next_id
      ROW_LINES = self.next_id
      HORIZ_RULES = self.next_id
      VERT_RULES = self.next_id
  
      ALIGN_LEFT = self.next_id
      ALIGN_CENTRE_H = self.next_id
      ALIGN_RIGHT = self.next_id
  
      ALIGN_TOP = self.next_id
      ALIGN_CENTRE_V = self.next_id
      ALIGN_BOTTOM = self.next_id
  
      TOGGLE_USE_TALL_ROWS = self.next_id
      TOGGLE_KEEP_LOGO_SMALL = self.next_id
      TOGGLE_USE_MULTI_LINE_TEXT = self.next_id
  
      EXIT = Wx::ID_EXIT
  
      # about menu
      ABOUT = Wx::ID_ABOUT
  
      # control IDs
  
      MUSIC_CTRL       = 50
      ATTR_CTRL        = 51
  
      ADD_MOZART       = 100
      DELETE_SEL       = 101
      DELETE_YEAR      = 102
      SELECT_NINTH     = 103
      COLLAPSE         = 104
      EXPAND           = 105
      SHOW_CURRENT      = 106
      SET_NINTH_CURRENT = 107
      CHANGE_NINTH_TITLE = 108
      ENSURE_NINTH_SECOND_COLUMN = 109
  
      PREPEND_LIST     = 200
      DELETE_LIST      = 201
      GOTO             = 202
      ADD_MANY         = 203
      HIDE_ATTRIBUTES  = 204
      SHOW_ATTRIBUTES  = 205
      MULTIPLE_SORT    = 206
      SORT_BY_FIRST_COLUMN = 207
  
      # Fourth page.
      DELETE_TREE_ITEM = 400
      DELETE_ALL_TREE_ITEMS = 401
      ADD_TREE_ITEM = 402
      ADD_TREE_CONTAINER_ITEM = 403
      TREE_ITEM_IS_EXPANDED = 404
      TREE_ITEM_COLLAPSE = 405
      TREE_ITEM_EXPAND = 406
  
      # Index list model page
      INDEX_LIST_USE_ENGLISH = 500
      INDEX_LIST_USE_FRENCH = 501
      INDEX_LIST_RESET_MODEL = 502
    end
    
    def initialize
      super(nil, Wx::ID_ANY, 'Wx::DVW::DataViewCtrl sample')

      @log = nil
      @col = nil

      @ctrl = ::Array.new(Page_Max)
      @model_flags = ::Array.new(Page_Max, 0)

      @event_from_program = false

      set_icon(Wx::Icon(:sample))
  
      # build the menus
      # ----------------
  
      style_menu = Wx::Menu.new
      #style_menu.AppendCheckItem(ID::SINGLE, "Single selection"))
      style_menu.append_check_item(ID::MULTIPLE, "Multiple selection")
      style_menu.append_check_item(ID::ROW_LINES, "Alternating colours")
      style_menu.append_check_item(ID::HORIZ_RULES, "Display horizontal rules")
      style_menu.append_check_item(ID::VERT_RULES, "Display vertical rules")
  
      align_menu = Wx::Menu.new
      align_menu.append_radio_item(ID::ALIGN_LEFT, "Left\tCtrl-1")
      align_menu.append_radio_item(ID::ALIGN_CENTRE_H, "Centre Horizontal\tCtrl-2")
      align_menu.append_radio_item(ID::ALIGN_RIGHT, "Right\tCtrl-3")
      align_menu.append_separator
      align_menu.append_radio_item(ID::ALIGN_TOP, "Top\tCtrl-4")
      align_menu.append_radio_item(ID::ALIGN_CENTRE_V, "Centre Vertical\tCtrl-5")
      align_menu.append_radio_item(ID::ALIGN_BOTTOM, "Bottom\tCtrl-6")
  
      size_menu = Wx::Menu.new
      size_menu.append_check_item(ID::TOGGLE_USE_TALL_ROWS,
          "Use Tall Rows\tCtrl-7")
      size_menu.append_check_item(ID::TOGGLE_KEEP_LOGO_SMALL,
          "Keep Logo Size Small\tCtrl-8")
      size_menu.append_check_item(ID::TOGGLE_USE_MULTI_LINE_TEXT,
          "Use Multi-line Text\tCtrl-9")
  
      file_menu = Wx::Menu.new
      file_menu.append(ID::CLEARLOG, "&Clear log\tCtrl-L")
      file_menu.append(ID::GET_PAGE_INFO, "Show current &page info")
      file_menu.append(ID::HIT_TEST, "Show item under mouse\tCtrl-M")
      file_menu.append_check_item(ID::DISABLE, "&Disable\tCtrl-D")
      file_menu.append(ID::CLEAR_MODEL, "&Clear MyMusicTreeModel\tCtrl-W")
      file_menu.append(ID::FOREGROUND_COLOUR, "Set &foreground colour...\tCtrl-S")
      file_menu.append(ID::BACKGROUND_COLOUR, "Set &background colour...\tCtrl-B")
      file_menu.append_check_item(ID::CUSTOM_HEADER_ATTR, "C&ustom header attributes")
      if Wx::DVW::HAS_GENERIC_DATAVIEWCTRL
        file_menu.append_check_item(ID::CUSTOM_HEADER_HEIGHT, "Custom header &height")
      end # HAS_GENERIC_DATAVIEWCTRL
      file_menu.append_sub_menu(style_menu, "&Style")
      file_menu.append_sub_menu(align_menu, "&Alignment")
      file_menu.append_sub_menu(size_menu, "Si&ze")
      file_menu.append(ID::INC_INDENT, "&Increase indent\tCtrl-I")
      file_menu.append(ID::DEC_INDENT, "&Decrease indent\tShift-Ctrl-I")
      file_menu.append_separator
      file_menu.append_check_item(ID::LAYOUT_DIR, "Toggle &layout direction\tShift-Ctrl-L")
      file_menu.check(ID::LAYOUT_DIR, get_layout_direction == Wx::Layout_RightToLeft)
      file_menu.append_separator
      file_menu.append(ID::EXIT, "E&xit")
  
      about_menu = Wx::Menu.new
      about_menu.append(ID::ABOUT, "&About")
  
      menu_bar = Wx::MenuBar.new
      menu_bar.append(file_menu, "&File")
      menu_bar.append(about_menu, "&About")
  
      set_menu_bar(menu_bar)
      create_status_bar
  
  
      # redirect logs from our event handlers to text control
      @log = Wx::TextCtrl.new(self, Wx::ID_ANY, style: Wx::TE_MULTILINE)
      @log.set_min_size([-1, from_dip(100)])
      @log_old = Wx::Log.set_active_target(Wx::LogTextCtrl.new(@log))
      Wx.log_message("This is the log window")
  
      double_border = Wx::SizerFlags.new.double_border
  
      # first page of the notebook
      # --------------------------
  
      @notebook = Wx::Notebook.new(self, Wx::ID_ANY)
  
      first_panel = Wx::Panel.new(@notebook, Wx::ID_ANY)
  
      build_data_view_ctrl(first_panel, Page_Music)
  
      border = Wx::SizerFlags.new.double_border
  
      button_sizer = Wx::HBoxSizer.new
      button_sizer.add( Wx::Button.new( first_panel, ID::ADD_MOZART,  "Add Mozart"),             border )
      button_sizer.add( Wx::Button.new( first_panel, ID::DELETE_SEL,  "Delete selected"),        border )
      button_sizer.add( Wx::Button.new( first_panel, ID::DELETE_YEAR, "Delete \"Year\" column"), border )
      button_sizer.add( Wx::Button.new( first_panel, ID::SELECT_NINTH,"Select ninth symphony"),  border )
      button_sizer.add( Wx::Button.new( first_panel, ID::COLLAPSE,    "Collapse"),               border )
      button_sizer.add( Wx::Button.new( first_panel, ID::EXPAND,      "Expand"),                 border )
  
      sizer_current = Wx::HBoxSizer.new
      sizer_current.add(Wx::Button.new(first_panel, ID::SHOW_CURRENT,
                                     "&Show current"), border)
      sizer_current.add(Wx::Button.new(first_panel, ID::SET_NINTH_CURRENT,
                                     "Make &ninth symphony current"), border)
      sizer_current.add(Wx::Button.new(first_panel, ID::CHANGE_NINTH_TITLE,
                                     "Change ninth &title"), border)
  
      first_panel_sz = Wx::VBoxSizer.new
      @ctrl[Page_Music].set_min_size([-1, from_dip(200)])
      first_panel_sz.add(@ctrl[Page_Music], Wx::SizerFlags.new(1).expand.border)
      first_panel_sz.add(button_sizer)
      first_panel_sz.add(sizer_current)
      first_panel.set_sizer_and_fit(first_panel_sz)
  
      # second page of the notebook
      # ---------------------------
  
      second_panel = Wx::Panel.new(@notebook, Wx::ID_ANY)
  
      build_data_view_ctrl(second_panel, Page_List)
  
      button_sizer2 = Wx::HBoxSizer.new
      button_sizer2.add( Wx::Button.new( second_panel, ID::PREPEND_LIST,"Prepend"),                double_border )
      button_sizer2.add( Wx::Button.new( second_panel, ID::DELETE_LIST, "Delete selected"),        double_border )
      button_sizer2.add( Wx::Button.new( second_panel, ID::GOTO,        "Goto 50"),                double_border )
      button_sizer2.add( Wx::Button.new( second_panel, ID::ADD_MANY,    "Add 1000"),               double_border )
      button_sizer2.add( Wx::Button.new( second_panel, ID::HIDE_ATTRIBUTES,    "Hide attributes"), double_border )
      button_sizer2.add( Wx::Button.new( second_panel, ID::SHOW_ATTRIBUTES,    "Show attributes"), double_border )
  
      sort_sizer = Wx::HBoxSizer.new
      sort_sizer.add(Wx::CheckBox.new(second_panel, ID::SORT_BY_FIRST_COLUMN, "Sort by first column"),
                     Wx::SizerFlags.new.centre.double_border)
      sort_sizer.add(Wx::CheckBox.new(second_panel, ID::MULTIPLE_SORT, "Allow multisort"),
                     Wx::SizerFlags.new.centre.double_border)
  
      second_panel_sz = Wx::VBoxSizer.new
      second_panel_sz.add(@ctrl[Page_List], Wx::SizerFlags.new(1).expand.border)
      second_panel_sz.add(button_sizer2)
      second_panel_sz.add(sort_sizer)
      second_panel.set_sizer_and_fit(second_panel_sz)
  
      # third page of the notebook
      # ---------------------------
  
      third_panel = Wx::Panel.new(@notebook, Wx::ID_ANY)
  
      build_data_view_ctrl(third_panel, Page_ListStore)
  
      third_panel_sz = Wx::VBoxSizer.new
      third_panel_sz.add(@ctrl[Page_ListStore], Wx::SizerFlags.new(1).expand.border)
      third_panel.set_sizer_and_fit(third_panel_sz)
  
      # fourth page of the notebook
      # ---------------------------
  
      fourth_panel = Wx::Panel.new(@notebook, Wx::ID_ANY)
  
      build_data_view_ctrl(fourth_panel, Page_TreeStore)
      # Buttons
      button_sizer4 = Wx::HBoxSizer.new
      button_sizer4.add( Wx::Button.new( fourth_panel, ID::DELETE_TREE_ITEM, "Delete Selected"), double_border )
      button_sizer4.add( Wx::Button.new( fourth_panel, ID::DELETE_ALL_TREE_ITEMS, "Delete All"), double_border )
      button_sizer4.add( Wx::Button.new( fourth_panel, ID::ADD_TREE_ITEM, "Add Item"), double_border )
      button_sizer4.add( Wx::Button.new( fourth_panel, ID::ADD_TREE_CONTAINER_ITEM, "Add Container"), double_border )
      button_sizer4.add( Wx::Button.new( fourth_panel, ID::TREE_ITEM_IS_EXPANDED, "IsExpanded"), double_border )
      button_sizer4.add( Wx::Button.new( fourth_panel, ID::TREE_ITEM_COLLAPSE, "Collapse"), double_border )
      button_sizer4.add( Wx::Button.new( fourth_panel, ID::TREE_ITEM_EXPAND, "Expand"), double_border )
  
      fourth_panel_sz = Wx::VBoxSizer.new
      fourth_panel_sz.add(@ctrl[Page_TreeStore], Wx::SizerFlags.new(1).expand.border)
      fourth_panel_sz.add(button_sizer4)
      fourth_panel.set_sizer_and_fit(fourth_panel_sz)
  
      # fifth page of the notebook
      # ---------------------------
  
      fifth_panel = Wx::Panel.new(@notebook, Wx::ID_ANY)
  
      build_data_view_ctrl(fifth_panel, Page_VarHeight)
  
      button_sizer5 = Wx::HBoxSizer.new
      button_sizer5.add(
          Wx::Button.new(fifth_panel, ID::ENSURE_NINTH_SECOND_COLUMN,
              "Make ninth symphony and second column visible"),
          Wx::SizerFlags.new.double_border)
  
      fifth_panel_sz = Wx::VBoxSizer.new
      fifth_panel_sz.add(@ctrl[Page_VarHeight], Wx::SizerFlags.new(1).expand.border)
      fifth_panel_sz.add(button_sizer5)
      fifth_panel.set_sizer_and_fit(fifth_panel_sz)
  
      # page showing the indexed list model
      # -----------------------------------
  
      sixth_panel = Wx::Panel.new(@notebook, Wx::ID_ANY)
  
      build_data_view_ctrl(sixth_panel, Page_IndexList)
  
      button_sizer6 = Wx::HBoxSizer.new
      button_sizer6.add(Wx::Button.new(sixth_panel, ID::INDEX_LIST_USE_ENGLISH, "&English"),
                         Wx::SizerFlags.new.double_border)
      button_sizer6.add(Wx::Button.new(sixth_panel, ID::INDEX_LIST_USE_FRENCH, "&French"),
                         Wx::SizerFlags.new.double_border)
      button_sizer6.add(Wx::Button.new(sixth_panel, ID::INDEX_LIST_RESET_MODEL, "Reset &model"),
                         Wx::SizerFlags.new.double_border)
  
      sixth_panel_sz = Wx::VBoxSizer.new
      sixth_panel_sz.add(@ctrl[Page_IndexList], Wx::SizerFlags.new(1).expand.border)
      sixth_panel_sz.add(button_sizer6)
      sixth_panel.set_sizer_and_fit(sixth_panel_sz)
  
      # page showing that some columns don't have values for some items
      # ---------------------------------------------------------------
  
      seventh_panel = Wx::Panel.new(@notebook, Wx::ID_ANY)
  
      build_data_view_ctrl(seventh_panel, Page_HasValue)
  
      seventh_panel_sz = Wx::VBoxSizer.new
      seventh_panel_sz.add(@ctrl[Page_HasValue], Wx::SizerFlags.new(1).expand.border)
      seventh_panel.set_sizer_and_fit(seventh_panel_sz)
  
      # complete GUI
      # ------------
  
      @notebook.add_page(first_panel, "MyMusicTreeModel")
      @notebook.add_page(second_panel, "MyListModel")
      @notebook.add_page(third_panel, "wxDataViewListCtrl")
      @notebook.add_page(fourth_panel, "wxDataViewTreeCtrl")
      @notebook.add_page(fifth_panel, "Variable line height")
      @notebook.add_page(sixth_panel, "MyIndexListModel")
      @notebook.add_page(seventh_panel, "MyDataViewHasValue")
  
      main_sizer = Wx::VBoxSizer.new
  
      main_sizer.add(@notebook, Wx::SizerFlags.new(1).expand)
      main_sizer.add( @log, Wx::SizerFlags.new.expand)
  
      set_sizer_and_fit(main_sizer)
  
      # Allow using the control from keyboard on startup.
      @ctrl[Page_Music].set_focus

      # event handlers
      evt_close :on_close
      
      evt_menu_range( ID::MULTIPLE, ID::TOGGLE_USE_MULTI_LINE_TEXT,
          :on_style_change )
      evt_menu( ID::EXIT, :on_quit )
      evt_menu( ID::ABOUT, :on_about )
      evt_menu( ID::CLEARLOG, :on_clear_log )
  
      evt_menu( ID::GET_PAGE_INFO, :on_get_page_info )
      evt_menu( ID::HIT_TEST, :on_hit_test )
      evt_menu( ID::DISABLE, :on_disable )
      evt_menu( ID::CLEAR_MODEL, :on_clear_my_music_tree_model )
      evt_menu( ID::FOREGROUND_COLOUR, :on_set_foreground_colour )
      evt_menu( ID::BACKGROUND_COLOUR, :on_set_background_colour )
      evt_menu( ID::CUSTOM_HEADER_ATTR, :on_custom_header_attr )
      if Wx::DVW::HAS_GENERIC_DATAVIEWCTRL
        evt_menu( ID::CUSTOM_HEADER_HEIGHT, :on_custom_header_height )
      end # HAS_GENERIC_DATAVIEWCTRL
      evt_menu( ID::INC_INDENT, :on_inc_indent )
      evt_menu( ID::DEC_INDENT, :on_dec_indent )
      evt_menu( ID::LAYOUT_DIR, :on_toggle_layout_direction)
  
      evt_notebook_page_changed( Wx::ID_ANY, :on_page_changed )
  
      evt_button( ID::ADD_MOZART, :on_add_mozart )
      evt_button( ID::DELETE_SEL, :on_delete_selected )
      evt_button( ID::DELETE_YEAR, :on_delete_year )
      evt_button( ID::SELECT_NINTH, :on_select_ninth )
      evt_button( ID::COLLAPSE, :on_collapse )
      evt_button( ID::EXPAND, :on_expand )
      evt_button( ID::SHOW_CURRENT, :on_show_current )
      evt_button( ID::SET_NINTH_CURRENT, :on_set_ninth_current )
      evt_button( ID::CHANGE_NINTH_TITLE, :on_change_ninth_title )
      evt_button( ID::ENSURE_NINTH_SECOND_COLUMN, :on_ensure_ninth_and_second_column )
  
      evt_button( ID::PREPEND_LIST, :on_prepend_list )
      evt_button( ID::DELETE_LIST, :on_delete_list )
      evt_button( ID::GOTO, :on_goto)
      evt_button( ID::ADD_MANY, :on_add_many)
      evt_button( ID::HIDE_ATTRIBUTES, :on_hide_attributes)
      evt_button( ID::SHOW_ATTRIBUTES, :on_show_attributes)
      evt_checkbox( ID::MULTIPLE_SORT, :on_multiple_sort)
      evt_checkbox( ID::SORT_BY_FIRST_COLUMN, :on_sort_by_first_column)
  
      # Fourth page.
      evt_button( ID::DELETE_TREE_ITEM, :on_delete_tree_item )
      evt_button( ID::DELETE_ALL_TREE_ITEMS, :on_delete_all_tree_items )
      evt_button( ID::ADD_TREE_ITEM, :on_add_tree_item )
      evt_button( ID::ADD_TREE_CONTAINER_ITEM, :on_add_tree_container_item )
      evt_button( ID::TREE_ITEM_IS_EXPANDED, :on_tree_item_is_expanded )
      evt_button( ID::TREE_ITEM_EXPAND, :on_tree_item_expand )
      evt_button( ID::TREE_ITEM_COLLAPSE, :on_tree_item_collapse )
  
      evt_button( ID::INDEX_LIST_USE_ENGLISH, :on_index_list_use_english )
      evt_button( ID::INDEX_LIST_USE_FRENCH, :on_index_list_use_french )
      evt_button( ID::INDEX_LIST_RESET_MODEL, :on_index_list_reset_model )
  
      evt_dataview_item_value_changed( ID::MUSIC_CTRL, :on_value_changed )
  
      evt_dataview_item_activated(ID::MUSIC_CTRL, :on_activated )
      evt_dataview_item_expanding(ID::MUSIC_CTRL, :on_expanding)
      evt_dataview_item_expanded(ID::MUSIC_CTRL, :on_expanded)
      evt_dataview_item_collapsing(ID::MUSIC_CTRL, :on_collapsing)
      evt_dataview_item_collapsed(ID::MUSIC_CTRL, :on_collapsed)
      evt_dataview_selection_changed(ID::MUSIC_CTRL, :on_selection_changed)
  
      evt_dataview_item_start_editing(ID::MUSIC_CTRL, :on_start_editing)
      evt_dataview_item_editing_started(Wx::ID_ANY, :on_editing_started)
      evt_dataview_item_editing_done(Wx::ID_ANY, :on_editing_done)
  
      evt_dataview_column_header_click(ID::MUSIC_CTRL, :on_header_click)
      evt_dataview_column_header_right_click(ID::MUSIC_CTRL, :on_header_right_click)
      evt_dataview_column_sorted(ID::MUSIC_CTRL, :on_sorted)
      evt_dataview_column_sorted(ID::ATTR_CTRL, :on_sorted_list)
      evt_dataview_column_reordered(Wx::ID_ANY, :on_column_reordered)
      evt_dataview_column_header_click(ID::ATTR_CTRL, :on_header_click_list)
  
      evt_dataview_item_context_menu(ID::MUSIC_CTRL, :on_context_menu)
  
      if Wx.has_feature?(:USE_DRAG_AND_DROP)
        evt_dataview_item_begin_drag( ID::MUSIC_CTRL, :on_begin_drag )
        evt_dataview_item_drop_possible( ID::MUSIC_CTRL, :on_drop_possible )
        evt_dataview_item_drop( ID::MUSIC_CTRL, :on_drop )
      end # USE_DRAG_AND_DROP
  
      evt_dataview_column_header_click(ID::ATTR_CTRL, :on_attr_header_click)
    end

    def build_data_view_ctrl(parent, n_panel,
                             style = 0,
                             model_flags = Wx::ALIGN_CENTRE)
      @current_panel = n_panel
      @model_flags[n_panel] = model_flags
  
      case n_panel
      when Page_Music
        @ctrl[Page_Music] =
          Wx::DVW::DataViewCtrl.new(parent, ID::MUSIC_CTRL, style: style)
        @ctrl[Page_Music].evt_char(self.method(:on_data_view_char))

        @music_model = MyMusicTreeModel.new
        @ctrl[Page_Music].associate_model(@music_model)

        if Wx.has_feature?(:USE_DRAG_AND_DROP)
          @ctrl[Page_Music].enable_drag_source(Wx::DF_UNICODETEXT)
          @ctrl[Page_Music].enable_drop_target(Wx::DF_UNICODETEXT)
        end # USE_DRAG_AND_DROP

        # column 0 of the view control:

        tr = Wx::DVW::DataViewTextRenderer.new("string", Wx::DVW::DATAVIEW_CELL_INERT)
        column0 = Wx::DVW::DataViewColumn.new("title", tr, 0, from_dip(200), Wx::ALIGN_LEFT,
                                              Wx::DVW::DATAVIEW_COL_SORTABLE | Wx::DVW::DATAVIEW_COL_RESIZABLE)
        @ctrl[Page_Music].append_column(column0)
        if false
          # Call this and sorting is enabled
          # immediately upon start up.
          column0.set_sort_order(true)
        end

        # column 1 of the view control:

        tr = Wx::DVW::DataViewTextRenderer.new("string", Wx::DVW::DATAVIEW_CELL_EDITABLE)
        column1 = Wx::DVW::DataViewColumn.new("artist", tr, 1, from_dip(150), Wx::ALIGN_LEFT,
                                              Wx::DVW::DATAVIEW_COL_SORTABLE | Wx::DVW::DATAVIEW_COL_REORDERABLE |
                                              Wx::DVW::DATAVIEW_COL_RESIZABLE)
        column1.set_min_width(from_dip(150)) # this column can't be resized to be smaller
        @ctrl[Page_Music].append_column( column1 )

        # column 2 of the view control:

        sr = Wx::DVW::DataViewSpinRenderer.new(0, 2010, Wx::DVW::DATAVIEW_CELL_EDITABLE,
                                               Wx::ALIGN_RIGHT | Wx::ALIGN_CENTRE_VERTICAL)
        column2 = Wx::DVW::DataViewColumn.new("year", sr, 2, from_dip(60), Wx::ALIGN_LEFT,
                                              Wx::DVW::DATAVIEW_COL_SORTABLE | Wx::DVW::DATAVIEW_COL_REORDERABLE )
        @ctrl[Page_Music].append_column( column2 )

        # column 3 of the view control:

        choices  = %w[good bad lousy]
        c = Wx::DVW::DataViewChoiceRenderer.new(choices, Wx::DVW::DATAVIEW_CELL_EDITABLE,
                                                Wx::ALIGN_RIGHT | Wx::ALIGN_CENTRE_VERTICAL)
        column3 = Wx::DVW::DataViewColumn.new("rating", c, 3, from_dip(100), Wx::ALIGN_LEFT,
                                              Wx::DVW::DATAVIEW_COL_REORDERABLE | Wx::DVW::DATAVIEW_COL_RESIZABLE )
        @ctrl[Page_Music].append_column( column3 )

        # column 4 of the view control:

        @ctrl[Page_Music].append_progress_column("popularity", 4, Wx::DVW::DATAVIEW_CELL_INERT, from_dip(80))

        # column 5 of the view control:

        cr = MyCustomRenderer.new(Wx::DVW::DATAVIEW_CELL_ACTIVATABLE)
        column5 = Wx::DVW::DataViewColumn.new("custom", cr, 5, Wx::COL_WIDTH_DEFAULT, Wx::ALIGN_LEFT,
                                              Wx::DVW::DATAVIEW_COL_RESIZABLE )
        column5.set_bitmap(Wx::ArtProvider.get_bitmap_bundle(Wx::ART_INFORMATION, Wx::ART_MENU))
        @ctrl[Page_Music].append_column( column5 )

        # select initially the ninth symphony:
        @ctrl[Page_Music].select(@music_model.get_ninth_item)

        @ctrl[Page_Music].set_tool_tip("You may edit most of the cells here!")
  
      when Page_List
        @ctrl[Page_List] = Wx::DVW::DataViewCtrl.new(parent, ID::ATTR_CTRL, style: style)

        @list_model = MyListModel.new(model_flags)
        @ctrl[Page_List].associate_model(@list_model)

        col_check_icon_text = Wx::DVW::DataViewColumn.new("\u2714 + icon + text",
                                                          Wx::DVW::DataViewCheckIconTextRenderer.new,
                                                          MyListModel::Col_ToggleIconText,
                                                          Wx::COL_WIDTH_AUTOSIZE)
        @ctrl[Page_List].append_column(col_check_icon_text)
        alignment = model_flags & Wx::ALIGN_MASK
        col_check_icon_text.get_renderer.set_alignment(alignment)

        col_editable = @ctrl[Page_List].append_text_column("editable string",
                                                           MyListModel::Col_EditableText,
                                                           Wx::DVW::DATAVIEW_CELL_EDITABLE,
                                                           Wx::COL_WIDTH_AUTOSIZE,
                                                           Wx::ALIGN_NOT,
                                                           Wx::DVW::DATAVIEW_COL_SORTABLE)
        col_editable.get_renderer.set_alignment(alignment)

        @ctrl[Page_List].append_date_column("date", MyListModel::Col_Date)

        markup_renderer = Wx::DVW::DataViewTextRenderer.new
        if Wx.has_feature?(:USE_MARKUP)
          markup_renderer.enable_markup
        end # USE_MARKUP
        @attributes = Wx::DVW::DataViewColumn.new("attributes",
                                 markup_renderer,
                                 MyListModel::Col_TextWithAttr,
                                 Wx::COL_WIDTH_AUTOSIZE,
                                 Wx::ALIGN_RIGHT,
                                 Wx::DVW::DATAVIEW_COL_REORDERABLE | Wx::DVW::DATAVIEW_COL_RESIZABLE | Wx::DVW::DATAVIEW_COL_SORTABLE)
        @ctrl[Page_List].append_column(@attributes)

        @ctrl[Page_List].append_column(Wx::DVW::DataViewColumn.new("custom renderer",
                                                                   MyCustomRenderer.new(Wx::DVW::DATAVIEW_CELL_EDITABLE),
                                                                   MyListModel::Col_Custom))

      when Page_ListStore
        lc = Wx::DVW::DataViewListCtrl.new(parent, Wx::ID_ANY, style: style)
        @ctrl[Page_ListStore] = lc

        page2_model = MyListStoreDerivedModel.new
        lc.associate_model(page2_model)

        lc.append_toggle_column("Toggle")

        # We're not limited to convenience column-appending functions, it
        # can also be done fully manually, which allows us to customize
        # the renderer being used.
        renderer_radio = Wx::DVW::DataViewToggleRenderer.new("bool", Wx::DVW::DATAVIEW_CELL_ACTIVATABLE)
        renderer_radio.show_as_radio
        col_radio = Wx::DVW::DataViewColumn.new("Radio", renderer_radio, 1)
        lc.append_column(col_radio, "bool")

        lc.append_text_column( "Text" )
        lc.append_progress_column( "Progress" ).set_min_width(from_dip(100))

        10.times do |i|
            data = [ ((i%3) == 0),
                     (i == 7),  # select a single (random) radio item
                     "row #{i}",
                     (5*i) ]

            lc.append_item( data )
        end

        lc.evt_dataview_item_value_changed(Wx::ID_ANY, self.method(:on_list_value_changed))
  
      when Page_TreeStore
        tc = Wx::DVW::DataViewTreeCtrl.new(parent, Wx::ID_ANY, style: style | Wx::DVW::DV_NO_HEADER )
        @ctrl[Page_TreeStore] = tc

        size = DataView.get_icon_size_from_model_flags(@model_flags[n_panel])

        images = [ Wx::ArtProvider.get_bitmap_bundle(Wx::ART_WX_LOGO, Wx::ART_LIST, size) ]
        tc.set_images(images)

        root = tc.append_container(nil, "The Root", 0)
        tc.append_item( root, "Child 1", 0 )
        tc.append_item( root, "Child 2", 0 )
        tc.append_item( root, "Child 3, very long, long, long, long", 0 )

        @cont = tc.append_container( root, "Container child", 0 )
        tc.append_item( @cont, "Child 4", 0 )
        tc.append_item( @cont, "Child 5", 0 )

        tc.expand(@cont)

      when Page_VarHeight
        @ctrl[Page_VarHeight] =
            Wx::DVW::DataViewCtrl.new(parent, Wx::ID_ANY, style: style | Wx::DVW::DV_VARIABLE_LINE_HEIGHT )

        @long_music_model = MyLongMusicTreeModel.new
        @ctrl[Page_VarHeight].associate_model(@long_music_model)

        # column 0 of the view control:
        tr = MultiLineCustomRenderer.new
        column0 = Wx::DVW::DataViewColumn.new("title", tr, 0, from_dip(200), Wx::ALIGN_LEFT,
                                              Wx::DVW::DATAVIEW_COL_SORTABLE | Wx::DVW::DATAVIEW_COL_RESIZABLE)
        @ctrl[Page_VarHeight].append_column(column0)

        # column 1 of the view control:
        tr = MultiLineCustomRenderer.new
        column1 = Wx::DVW::DataViewColumn.new("artist", tr, 1, from_dip(150), Wx::ALIGN_LEFT,
                                              Wx::DVW::DATAVIEW_COL_SORTABLE | Wx::DVW::DATAVIEW_COL_REORDERABLE |
                                              Wx::DVW::DATAVIEW_COL_RESIZABLE)
        column1.set_min_width(from_dip(150)) # this column can't be resized to be smaller
        @ctrl[Page_VarHeight].append_column(column1)

      when Page_IndexList
        @ctrl[Page_IndexList] = Wx::DVW::DataViewCtrl.new(parent, Wx::ID_ANY, style: style)

        @index_list_model = MyIndexListModel.new
        @ctrl[Page_IndexList].associate_model(@index_list_model)
        @ctrl[Page_IndexList].append_text_column("String", 0)

        fill_index_list(Lang_English)

        @ctrl[Page_IndexList].evt_dataview_selection_changed(Wx::ID_ANY, self.method(:on_index_list_selection_changed))

      when Page_HasValue
        lc = Wx::DVW::DataViewListCtrl.new(parent, Wx::ID_ANY, style: style)
        @ctrl[Page_HasValue] = lc

        page7_model = MyListStoreHasValueModel.new
        lc.associate_model(page7_model)

        lc.append_toggle_column("Toggle")

        # We're not limited to convenience column-appending functions, it
        # can also be done fully manually, which allows us to customize
        # the renderer being used.
        renderer_radio = Wx::DVW::DataViewToggleRenderer.new("bool", Wx::DVW::DATAVIEW_CELL_ACTIVATABLE)
        renderer_radio.show_as_radio
        col_radio = Wx::DVW::DataViewColumn.new("Radio", renderer_radio, 1)
        lc.append_column(col_radio, "bool")

        lc.append_text_column( "Text" )
        lc.append_progress_column( "Progress" ).set_min_width(from_dip(100))

        10.times do |i|
          data = [ ( (i%3) == 0 ),
                   ( i == 7 ),  # select a single (random) radio item
                   "row #{i}",
                   (5*i) ]
          lc.append_item( data )
        end

        lc.evt_dataview_item_value_changed(Wx::ID_ANY, self.method(:on_has_value_value_changed))
      end

      @ctrl[n_panel].set_row_height(from_dip(32)) if has_model_flag(MODEL_USE_TALL_ROWS)
    end

    private

    # the controls stored in the various tabs of the main notebook:
    Page_Music = 0
    Page_List = 1
    Page_ListStore = 2
    Page_TreeStore = 3
    Page_VarHeight = 4
    Page_IndexList = 5
    Page_HasValue = 6
    Page_Max = 7

    Lang_English = 0
    Lang_French = 1

    # event handlers
    def on_style_change(event)

    end

    def on_set_background_colour(event)

    end

    def on_custom_header_attr(event)

    end
    if Wx::DVW::HAS_GENERIC_DATAVIEWCTRL

      def on_custom_header_height(event)

      end

    end # HAS_GENERIC_DATAVIEWCTRL

    def on_get_page_info(event)

    end

    def on_hit_test(event)

    end

    def on_disable(event)

    end

    def on_clear_my_music_tree_model(event)

    end

    def on_set_foreground_colour(event)

    end

    def on_inc_indent(event)

    end

    def on_dec_indent(event)

    end

    def on_toggle_layout_direction(evt)

    end

    def on_close(_)
      Wx::Log::active_target = @old_log_tgt
      destroy
    end

    def on_quit(event)

    end

    def on_about(event)

    end

    def on_clear_log(event)

    end

    def on_page_changed(event)

    end

    def on_add_mozart(event)

    end

    def on_delete_selected(event)

    end

    def on_delete_year(event)

    end

    def on_select_ninth(event)

    end

    def on_collapse(event)

    end

    def on_expand(event)

    end

    def on_show_current(event)

    end

    def on_set_ninth_current(event)

    end

    def on_change_ninth_title(event)

    end

    def on_ensure_ninth_and_second_column(event)

    end

    def on_prepend_list(event)

    end

    def on_delete_list(event)

    end

    # Third (DataViewListCtrl) page.
    def on_list_value_changed(event)

    end

    # Fourth page.
    def on_delete_tree_item(event)

    end

    def on_delete_all_tree_items(event)

    end

    def on_add_tree_item(event)

    end

    def on_add_tree_container_item(event)

    end

    def on_tree_item_expand(event)

    end

    def on_tree_item_collapse(event)

    end

    def on_tree_item_is_expanded(event)

    end

    def on_index_list_use_english(_)
      fill_index_list(Lang_English)
    end
    def on_index_list_use_french(_)
      fill_index_list(Lang_French)
    end
    def on_index_list_reset_model(event)

    end
    def on_index_list_selection_changed(event)

    end

    def on_value_changed(event)

    end

    def on_activated(event)

    end
    def on_expanding(event)

    end
    def on_expanded(event)

    end
    def on_collapsing(event)

    end
    def on_collapsed(event)

    end
    def on_selection_changed(event)

    end

    def on_start_editing(event)

    end
    def on_editing_started(event)

    end
    def on_editing_done(event)

    end

    def on_header_click(event)

    end
    def on_attr_header_click(event)

    end
    def on_header_right_click(event)

    end
    def on_header_click_list(event)

    end
    def on_sorted(event)

    end
    def on_sorted_list(event)

    end
    def on_column_reordered(event)

    end

    def on_context_menu(event)

    end

    def on_goto(event)

    end
    def on_add_many(event)

    end
    def on_hide_attributes(event)

    end
    def on_show_attributes(event)

    end

    def on_multiple_sort(event)

    end
    def on_sort_by_first_column(event)

    end

    if Wx.has_feature?(:USE_DRAG_AND_DROP)

    def on_begin_drag(event)

    end
    def on_drop_possible(event)

    end
    def on_drop(event)

    end

    end # USE_DRAG_AND_DROP

    def on_data_view_char(event)

    end

    # helper used by both OnDeleteSelected() and OnDataViewChar()
    def delete_selected_items

    end

    # helper for the index list model fills the model with the weekday names
    # in the specified language
    def fill_index_list(lang)

    end

    # Helper for checking ModelFlags of current panel (either currently
    # building or selected one).
    def has_model_flag(flag)
      (@model_flags[@current_panel] & flag) != 0
    end

    # HasValue page.
    def on_has_value_value_changed(event)

    end

  end

  class DVApp < Wx::App
    def on_init
      frame = DVFrame.new
      frame.show

      true
    end
  end

end

module DataViewSample

  include WxRuby::Sample if defined? WxRuby::Sample

  def self.describe
    { file: __FILE__,
      summary: 'wxRuby DataViewCtrl example.',
      description: 'wxRuby example displaying a frame window showcasing a DataViewCtrl.' }
  end

  def self.run
    execute(__FILE__)
  end

  if $0 == __FILE__
    DataView::DVApp.run
  end

end
