# Wx::PG::PropertyGrid
# Copyright (c) M.J.N. Corino, The Netherlands

module Wx::PG

  if self.const_defined?(:PropertyGrid)
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
    end
  end

end
