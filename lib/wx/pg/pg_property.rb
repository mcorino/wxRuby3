# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::PG::PGProperty

module Wx::PG

  NullProperty = nil
  PGChoicesEmptyData = nil

  PG_LABEL_STRING = '@!' unless self.const_defined?(:PG_LABEL_STRING) # disappeared >= wxWidgets 3.3.0
  PG_LABEL = Wx::PG::PG_LABEL_STRING

  PG_DEFAULT_IMAGE_SIZE = Wx::DEFAULT_SIZE

  if Wx::WXWIDGETS_VERSION >= '3.3.0'
    # backward compatibility constants
    PG_FULL_VALUE                     = PGPropValFormatFlags::FullValue
    PG_REPORT_ERROR                   = PGPropValFormatFlags::ReportError
    PG_PROPERTY_SPECIFIC              = PGPropValFormatFlags::PropertySpecific
    PG_EDITABLE_VALUE                 = PGPropValFormatFlags::EditableValue
    PG_COMPOSITE_FRAGMENT             = PGPropValFormatFlags::CompositeFragment
    PG_UNEDITABLE_COMPOSITE_FRAGMENT  = PGPropValFormatFlags::UneditableCompositeFragment
    PG_VALUE_IS_CURRENT               = PGPropValFormatFlags::ValueIsCurrent
    PG_PROGRAMMATIC_VALUE             = PGPropValFormatFlags::ProgrammaticValue
  end

  class PGProperty

    wx_each_attribute = instance_method :each_attribute
    define_method :each_attribute do
      if block_given?
        wx_each_attribute.bind(self).call
      else
        ::Enumerator.new { |y| wx_each_attribute.bind(self).call { |variant| y << variant } }
      end
    end

    def get_attributes
      each_attribute.inject({}) { |map, v| map[v.name] = v; map }
    end
    alias :attributes :get_attributes

    def set_attributes(map)
      raise ArgumentError, 'Expected Hash' unless map.is_a?(::Hash)
      map.each_pair { |nm, v| set_attribute(nm, v) }
    end
    alias :attributes= :set_attributes
  end

  class PGChoices

    wx_each_label = instance_method :each_label
    define_method :each_label do
      if block_given?
        wx_each_label.bind(self).call
      else
        ::Enumerator.new { |y| wx_each_label.bind(self).call { |lbl| y << lbl } }
      end
    end

    wx_each_entry = instance_method :each_entry
    define_method :each_entry do
      if block_given?
        wx_each_entry.bind(self).call
      else
        ::Enumerator.new { |y| wx_each_entry.bind(self).call { |entry| y << entry } }
      end
    end
    
  end
  
end
