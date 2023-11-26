# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

class Wx::HTML::SimpleHtmlListBox

  alias :get_client_data :get_client_object
  alias :set_client_data :set_client_object

  # Overload to provide Enumerator without block
  wx_each_string = instance_method :each_string
  define_method :each_string do |&block|
    if block
      wx_each_string.bind(self).call(&block)
    else
      ::Enumerator.new { |y| wx_each_string.bind(self).call { |ln| y << ln } }
    end
  end

end
