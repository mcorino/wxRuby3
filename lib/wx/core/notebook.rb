# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.
# 
# Some parts are
# Copyright 2004-2007, wxRuby development team
# released under the MIT-like wxRuby2 license

# Displays a set of pages in parallel using tabs

class Wx::Notebook
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
