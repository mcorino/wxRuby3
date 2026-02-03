# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

# Wx::PG::PGProperty

module Wx
  module PG

    NullProperty = nil
    PGChoicesEmptyData = nil

    PG_LABEL_STRING = '@!' unless self.const_defined?(:PG_LABEL_STRING) # disappeared >= wxWidgets 3.3.0
    PG_LABEL = Wx::PG::PG_LABEL_STRING

    PG_DEFAULT_IMAGE_SIZE = Wx::DEFAULT_SIZE

    if Wx.at_least_wxwidgets?('3.3.0')
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

    # since wxWidgets 3.3.0
    unless const_defined?(:PGPropertyFlags)
      module PGPropertyFlags
        PG_PROP_MODIFIED = PGFlags::Modified
        PG_PROP_DISABLED = PGFlags::Disabled
        PG_PROP_HIDDEN = PGFlags::Hidden
        PG_PROP_CUSTOMIMAGE = PGFlags::CustomImage
        PG_PROP_NOEDITOR = PGFlags::NoEditor
        PG_PROP_COLLAPSED = PGFlags::Collapsed
        PG_PROP_INVALID_VALUE = PGFlags::InvalidValue
        PG_PROP_WAS_MODIFIED = PGFlags::WasModified
        PG_PROP_AGGREGATE = PGFlags::Aggregate
        PG_PROP_CHILDREN_ARE_COPIES = PGFlags::ChildrenAreCopies
        PG_PROP_PROPERTY = PGFlags::Property
        PG_PROP_CATEGORY = PGFlags::Category
        PG_PROP_MISC_PARENT = PGFlags::MiscParent
        PG_PROP_READONLY = PGFlags::ReadOnly
        PG_PROP_COMPOSED_VALUE = PGFlags::ComposedValue
        PG_PROP_USES_COMMON_VALUE = PGFlags::UsesCommonValue
        PG_PROP_BEING_DELETED = PGFlags::BeingDeleted

        PG_PROP_PARENTAL_FLAGS = PGFlags::ParentalFlags
        PG_STRING_STORED_FLAGS = PGFlags::StringStoredFlags
      end
    end

    def self.PG_IT_CHILDREN(mask)
      mask << 16
    end

    class PGProperty

      wx_each_attribute = instance_method :each_attribute
      wx_redefine_method :each_attribute do
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
      wx_redefine_method :each_label do
        if block_given?
          wx_each_label.bind(self).call
        else
          ::Enumerator.new { |y| wx_each_label.bind(self).call { |lbl| y << lbl } }
        end
      end

      wx_each_entry = instance_method :each_entry
      wx_redefine_method :each_entry do
        if block_given?
          wx_each_entry.bind(self).call
        else
          ::Enumerator.new { |y| wx_each_entry.bind(self).call { |entry| y << entry } }
        end
      end

    end

  end

end
