# :stopdoc:
# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# :startdoc:

module Wx

  module DVW

    class DataViewIconText < Object

      # Store given object's value in a new Wx::Variant.
      # @param icon_text [Wx::DVW::DataViewIconText]
      # @return [Wx::Variant]
      def self.to_variant(icon_text) end

      # Store this object's value in a new Wx::Variant.
      # @return [Wx::Variant]
      def to_variant; end

      # Extract value from the given variant and store in given icon text object.
      # @param variant [Wx::Variant]
      # @param icon_text [Wx::DVW::DataViewIconText]
      # @return [void]
      def self.from_variant(variant, icon_text) end

      # Extract value from the given variant.
      # @param variant [Wx::Variant]
      # @return [Wx::DVW::DataViewIconText] self
      def from_variant(variant) end

    end

    class DataViewCheckIconText < DataViewIconText

      # Store given object's value in a new Wx::Variant.
      # @param icon_text [Wx::DVW::DataViewCheckIconText]
      # @return [Wx::Variant]
      def self.to_variant(icon_text) end

      # Store this object's value in a new Wx::Variant.
      # @return [Wx::Variant]
      def to_variant; end

      # Extract value from the given variant and store in given icon text object.
      # @param variant [Wx::Variant]
      # @param icon_text [Wx::DVW::DataViewCheckIconText]
      # @return [void]
      def self.from_variant(variant, icon_text) end

      # Extract value from the given variant.
      # @param variant [Wx::Variant]
      # @return [Wx::DVW::DataViewCheckIconText] self
      def from_variant(variant) end

    end

  end

  class Variant < Object

    # Extract Wx::DVW::DataViewIconText from this variant.
    # @return [Wx::DVW::DataViewIconText]
    def get_data_view_icon_text; end
    alias :data_view_icon_text :get_data_view_icon_text

    # Checks if Variant contains a Wx::DVW::DataViewIconText value (not null).
    # @return [true,false]
    def data_view_icon_text?; end

    # Extract Wx::DVW::DataViewCheckIconText from this variant.
    # @return [Wx::DVW::DataViewCheckIconText]
    def get_data_view_check_icon_text; end
    alias :data_view_check_icon_text :get_data_view_check_icon_text

    # Checks if Variant contains a Wx::DVW::DataViewCheckIconText value (not null).
    # @return [true,false]
    def data_view_check_icon_text?; end

  end

end
