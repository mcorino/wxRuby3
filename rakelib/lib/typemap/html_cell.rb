# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 HtmlCell typemap definition
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # Typemaps for converting returned HtmlCell references to
    # either the base Wx::HTML::HtmlCell or Wx::HTML::HtmlContainerCell
    module HtmlCell

      include Typemap::Module

      define do

        map 'wxHtmlCell*' => 'Wx::HTML::HtmlCell,Wx::HTML::HtmlContainerCell' do
          map_out code: <<~__CODE
            // attempt a dynamic cast to wxHtmlContainerCell 
            wxHtmlContainerCell* con_cell = dynamic_cast<wxHtmlContainerCell*> ($1);
            if (con_cell)
            {
              swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(rb_eval_string("Wx::HTML::HtmlContainerCell"));
              $result = SWIG_NewPointerObj(con_cell, swig_type, 0);
            }
            else
            {
              swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(rb_eval_string("Wx::HTML::HtmlCell"));
              $result = SWIG_NewPointerObj($1, swig_type, 0);
            }
            __CODE
          map_directorin code: <<~__CODE
            // attempt a dynamic cast to wxHtmlContainerCell 
            wxHtmlContainerCell* con_cell = dynamic_cast<wxHtmlContainerCell*> ($1);
            if (con_cell)
            {
              swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(rb_eval_string("Wx::HTML::HtmlContainerCell"));
              $input = SWIG_NewPointerObj(con_cell, swig_type, 0);
            }
            else
            {
              swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(rb_eval_string("Wx::HTML::HtmlCell"));
              $input = SWIG_NewPointerObj($1, swig_type, 0);
            }
            __CODE
        end

      end

    end

  end

end
