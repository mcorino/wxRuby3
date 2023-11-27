# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
#
# Adapted for wxRuby from wxWidgets richtext sample
# Copyright (c) 2001 Vadim Zeitlin

module Widgets

  module ItemContainer

    class Page < Widgets::Page

      # Help track client data objects in wxItemContainer instances.
      class TrackedClientData
        def initialize(tracker, value)
          @tracker = tracker
          @value = value
          @tracker.__send__(:start_tracking_data)
        end

        def get_value
          @value
        end
      end

      def initialize(book, images, icon)
        super(book, images, icon)
        @trackedDataObjects = 0
        @items = %w[This is a List of strings]
        @container = nil
      end

      def on_button_test_item_container(event)
        @container = get_container
        ::Kernel.raise RuntimeError, 'Widget must have a test widget' unless @container

        @container.on_unlink_client_data { stop_tracking_data }

        Wx.log_message('wxItemContainer test for %s, %s:',
                       get_widget.class.name,
                       @container.is_sorted ? 'Sorted' : 'Unsorted')
    
        expected_result = @container.sorted? ? self.sorted_items : @items
    
        start_test('Append one item')
        item = @items.first
        @container.append(item)
        end_test([item])
    
        start_test("Append some items")
        @container.append(@items)
        end_test(expected_result)
    
        start_test('Append some items with data')
        objects = []
        @items.size.times { |i| objects << create_client_data(i) }
        @container.append(@items, objects)
        end_test(expected_result)
        objects = nil
    
        start_test('Append some items with data, one by one')
        @items.each_with_index { |item, i| @container.append(item, create_client_data(i)) }
        end_test(expected_result)
    
        unless @container.sorted?
          start_test('Insert in reverse order with data, one by one')
          @items.reverse.each_with_index do |item, i|
            @container.insert(item, 0, create_client_data(@items.size-(i+1)))
          end
          end_test(expected_result)
        end

        @container.on_unlink_client_data(nil)
      end

      def get_container
        ::Kernel.raise NotImplementedError
      end

      private

      def start_test(label)
        @container.clear
        Wx.log_message("Test - #{label}:")
      end

      def end_test(items)
        count = @container.count
    
        ok = (count == items.size)
        ::Kernel.raise RuntimeError, 'Item count does not match.' unless ok

        count.times do |i|
          str = @container.get_string(i)
          if str != items[i]
            Wx.log_error("Wrong string \"#{str}\" at position #{i} (expected \"#{items[i]}\")")
            ok = false
            break
          end

          if @container.has_client_untyped_data
            data = @container.get_client_data(i)
            if data && !verify_client_data(data.get_value, str)
              ok = false
              break
            end
          # elsif @container.has_client_object_data  # NOT supported by wxRuby
          end
        end

        Wx.log_message(dump_container_data(items)) unless ok

        @container.clear
        ok &= verify_all_client_data_destroyed
    
        Wx.log_message("...%s", ok ? "passed" : "failed")
      end

      # Track client data in wxItemContainer instances
      def create_client_data(value)
        TrackedClientData.new(self, value)
      end

      def  start_tracking_data
        @trackedDataObjects += 1
      end

      def stop_tracking_data
        @trackedDataObjects -= 1
      end

      def verify_all_client_data_destroyed
        if @trackedDataObjects > 0
          message = 'Bug in managing wxClientData: '
          if @trackedDataObjects > 0
            message << @trackedDataObjects.to_s << ' lost objects'
          else
            message << (-@trackedDataObjects).to_s << ' extra deletes'
          end
          ::Kernel.raise RuntimeError, message
        else
          true
        end
      end

      def verify_client_data(i, str)
        if i > @items.size || @items[i] != str
          Wx.log_error("Client data for '%s' does not match.", str)
          false
        else
          true
        end
      end

      def dump_container_data(expected)
        str = "Current content:\n"

        @container.each_string.each_with_index do |s, i|
          str << " - " << s << " ["
          if @container.has_client_untyped_data
              data = @container.get_client_data(i)
              str << data.get_value.to_s if data
          end
          str << "]\n"
        end

        str << "Expected content:\n"
        expected.each do |item|
          str << " - " << item << "["
          str << @items.find_index(item).to_s
          str << "]\n"
        end

        return str
      end

      def sorted_items
        @items.sort { |a,b| a.casecmp(b) }
      end

    end

  end

end
