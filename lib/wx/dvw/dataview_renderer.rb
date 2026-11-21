# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

module Wx

  module DVW

    class DataViewIconText < Wx::Object

      def to_variant
        DataViewIconText::to_variant(self)
      end

      def from_variant(variant)
        DataViewIconText::from_variant(variant, self)
        self
      end

    end

    class DataViewCheckIconText < DataViewIconText

      def to_variant
        DataViewCheckIconText::to_variant(self)
      end

      def from_variant(variant)
        DataViewCheckIconText::from_variant(variant, self)
        self
      end

    end

  end

  # update Variant class
  class Variant < Wx::Object

    def get_data_view_icon_text
      Wx::DVW::DataViewIconText.new.from_variant(self)
    end
    alias :data_view_icon_text :get_data_view_icon_text

    def data_view_icon_text?
      !null? && is_type('wxDataViewIconText')
    end

    def get_data_view_check_icon_text
      Wx::DVW::DataViewCheckIconText.new.from_variant(self)
    end
    alias :data_view_check_icon_text :get_data_view_check_icon_text

    def data_view_check_icon_text?
      !null? && is_type('wxDataViewCheckIconText')
    end

  end

end
