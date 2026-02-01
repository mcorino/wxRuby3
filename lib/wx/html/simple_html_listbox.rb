# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.


module Wx

  module HTML

    class SimpleHtmlListBox < Wx::HTML::HtmlListBox

      # force these (inherited) methods to be protected
      protected :set_item_count, :item_count=
      protected :get_item_count, :item_count

      # make sure to honor the inherited common overloads
      wx_get_client_object = instance_method :get_client_object
      wx_redefine_method :get_client_object do |*args|
        if args.empty?
          super()
        else
          wx_get_client_object.bind(self).call(*args)
        end
      end
      wx_set_client_object = instance_method :set_client_object
      wx_redefine_method :set_client_object do |*args|
        if args.size < 2
          super(*args)
        else
          wx_set_client_object.bind(self).call(*args)
        end
      end
      # redefine aliases
      alias :client_object :get_client_object
      alias :client_object= :set_client_object

      alias :get_client_data :get_client_object
      alias :set_client_data :set_client_object

      # Overload to provide Enumerator without block
      wx_each_string = instance_method :each_string
      wx_redefine_method :each_string do |&block|
        if block
          wx_each_string.bind(self).call(&block)
        else
          ::Enumerator.new { |y| wx_each_string.bind(self).call { |ln| y << ln } }
        end
      end

    end

  end

end
