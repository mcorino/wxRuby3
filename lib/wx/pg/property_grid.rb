# Wx::PG::PropertyGrid
# Copyright (c) M.J.N. Corino, The Netherlands

module Wx::PG

  class PropertyGrid
    class << self
      def property_editors
        @prop_editors ||= {}
      end
      private :property_editors

      wx_register_editor_class = self.instance_method(:register_editor_class)
      define_method(:register_editor_class) do |editor_class, name|
        editor = wx_register_editor_class.bind(self).call(editor_class, name)
        property_editors[name] = editor # keep safe from GC and for lookup
      end

      def get_editor_class(name)
        property_editors[name]
      end
    end

    wx_set_sorter = instance_method :set_sorter
    define_method :set_sorter do |meth, &block|
      if block and not meth
        return block
      elsif meth and not block
        h_meth = case meth
                 when Symbol, String then self.method(meth)
                 when Proc then meth
                 when Method then meth
                 end
        # check arity == 3
        if h_meth.arity == 3
          Kernel.raise ArgumentError,
                       "PropertyGrid sorter is required to accept 3 arguments"
          caller
        end
        h_meth
      else
        Kernel.raise ArgumentError,
                     "Specify PropertyGrid sorter with a method, name, proc OR block"
        caller
      end
    end
    alias :sorter= :set_sorter

    alias :sorter :get_sorter
  end

end
