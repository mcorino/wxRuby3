# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

class Wx::AUI::AuiTabCtrl

  # Convenience method for iterating pages
  def each_page
    if block_given?
      0.upto(get_page_count - 1) do | i |
        yield get_page(i)
      end
    else
      ::Enumerator.new { |y| each_page { |pg| y << pg } }
    end
  end

end
