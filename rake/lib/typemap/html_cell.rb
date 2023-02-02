###
# wxRuby3 HtmlCell typemap definition
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # Typemaps for converting returned HtmlCell references to
    # either the base Wx::Html::HtmlCell or Wx::Html::HtmlContainerCell
    module HtmlCell

      include Typemap::Module

      define do

        map 'wxHtmlCell*' => 'Wx::Html::HtmlCell,Wx::Html::HtmlContainerCell' do
          map_out code: <<~__CODE
            // attempt a dynamic cast to wxHtmlContainerCell 
            wxHtmlContainerCell* con_cell = dynamic_cast<wxHtmlContainerCell*> ($1);
            if (con_cell)
            {
              swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(rb_eval_string("Wx::Html::HtmlContainerCell"));
              $result = SWIG_NewPointerObj(con_cell, swig_type, 0);
            }
            else
            {
              swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(rb_eval_string("Wx::Html::HtmlCell"));
              $result = SWIG_NewPointerObj($1, swig_type, 0);
            }
            __CODE
          map_directorin code: <<~__CODE
            // attempt a dynamic cast to wxHtmlContainerCell 
            wxHtmlContainerCell* con_cell = dynamic_cast<wxHtmlContainerCell*> ($1);
            if (con_cell)
            {
              swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(rb_eval_string("Wx::Html::HtmlContainerCell"));
              $input = SWIG_NewPointerObj(con_cell, swig_type, 0);
            }
            else
            {
              swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(rb_eval_string("Wx::Html::HtmlCell"));
              $input = SWIG_NewPointerObj($1, swig_type, 0);
            }
            __CODE
        end

      end

    end

  end

end
