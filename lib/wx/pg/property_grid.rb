# Wx::PG::PropertyGrid
# Copyright (c) M.J.N. Corino, The Netherlands

module Wx::PG

  # since wxWidgets 3.3.0
  PG_VFB_NULL = PGVFBFlags::Null unless const_defined?(:PG_VFB_NULL)
  PG_VFB_STAY_IN_PROPERTY = PGVFBFlags::StayInProperty unless const_defined?(:PG_VFB_STAY_IN_PROPERTY)
  PG_VFB_BEEP = PGVFBFlags::Beep unless const_defined?(:PG_VFB_BEEP)
  PG_VFB_MARK_CELL = PGVFBFlags::MarkCell unless const_defined?(:PG_VFB_MARK_CELL)
  PG_VFB_SHOW_MESSAGE = PGVFBFlags::ShowMessage unless const_defined?(:PG_VFB_SHOW_MESSAGE)
  PG_VFB_SHOW_MESSAGEBOX = PGVFBFlags::ShowMessageBox unless const_defined?(:PG_VFB_SHOW_MESSAGEBOX)
  PG_VFB_SHOW_MESSAGE_ON_STATUSBAR = PGVFBFlags::ShowMessageOnStatusBar unless const_defined?(:PG_VFB_SHOW_MESSAGE_ON_STATUSBAR)
  PG_VFB_DEFAULT = PGVFBFlags::Default unless const_defined?(:PG_VFB_DEFAULT)
  PG_VFB_UNDEFINED = PGVFBFlags::Undefined unless const_defined?(:PG_VFB_UNDEFINED)

  class PropertyGrid
    class << self
      def property_editors
        @prop_editors ||= {}
      end
      private :property_editors

      wx_do_register_editor_class = self.instance_method(:do_register_editor_class)
      define_method(:do_register_editor_class) do |editor_class, name|
        editor = wx_do_register_editor_class.bind(self).call(editor_class, name)
        property_editors[name] = editor # keep safe from GC and for lookup
      end

      def register_editor_class(editor)
        do_register_editor_class(editor, editor.class.name)
      end

      def get_editor_class(name)
        property_editors[name] || get_standard_editor_class(name)
      end
    end

    wx_set_sorter = instance_method :set_sorter
    define_method :set_sorter do |meth, &block|
      h_sorter = if block and not meth
                   block
                 elsif meth and not block
                   case meth
                   when Symbol, String then self.method(meth)
                   when Proc then meth
                   when Method then meth
                   end
                 else
                   Kernel.raise ArgumentError,
                                "Specify PropertyGrid sorter with a method, name, proc OR block"
                   caller
                 end
      # check arity == 3
      if h_sorter.arity == 3
        Kernel.raise ArgumentError,
                     "PropertyGrid sorter is required to accept 3 arguments"
        caller
      end
      wx_set_sorter.bind(self).call(h_sorter)
    end
    alias :sorter= :set_sorter

    alias :sorter :get_sorter
  end

end
