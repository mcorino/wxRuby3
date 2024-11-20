# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::PG::PropertyGrid

module Wx::PG

  # since wxWidgets 3.3.0
  unless const_defined?(:PG_VALIDATION_FAILURE_BEHAVIOR_FLAGS)
    module PG_VALIDATION_FAILURE_BEHAVIOR_FLAGS
      PG_VFB_NULL = PGVFBFlags::Null
      PG_VFB_STAY_IN_PROPERTY = PGVFBFlags::StayInProperty
      PG_VFB_BEEP = PGVFBFlags::Beep
      PG_VFB_MARK_CELL = PGVFBFlags::MarkCell
      PG_VFB_SHOW_MESSAGE = PGVFBFlags::ShowMessage
      PG_VFB_SHOW_MESSAGEBOX = PGVFBFlags::ShowMessageBox
      PG_VFB_SHOW_MESSAGE_ON_STATUSBAR = PGVFBFlags::ShowMessageOnStatusBar
      PG_VFB_DEFAULT = PGVFBFlags::Default
      PG_VFB_UNDEFINED = PGVFBFlags::Undefined
    end
  end

  class PropertyGrid
    class << self
      def property_editors
        @prop_editors ||= {}
      end
      private :property_editors

      wx_do_register_editor_class = self.instance_method(:do_register_editor_class)
      wx_redefine_method(:do_register_editor_class) do |editor_class, name|
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
    wx_redefine_method :set_sorter do |meth, &block|
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
