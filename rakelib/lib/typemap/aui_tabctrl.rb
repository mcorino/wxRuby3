# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 Common typemap definitions
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # These typemaps are used by AUI classes to convert wxAuiTabCtrl pointers
    # into lightweight wrapper objects
    module AuiTabCtrl

      include Typemap::Module

      define do

        map 'wxAuiTabCtrl*' => 'Wx::AUI::AuiTabCtrl' do

          add_header_code <<~__CODE
            // implemented in TreeEvent.cpp
            extern VALUE _wxRuby_Wrap_wxAuiTabCtrl(wxAuiTabCtrl* wxATC);
            extern wxAuiTabCtrl* _wxRuby_Unwrap_wxAuiTabCtrl(VALUE rbATC);
            extern bool _wxRuby_Is_wxAuiTabCtrl(VALUE rbATC);
            __CODE

          map_in temp: 'wxAuiTabCtrl *tmpATC', code: <<~__CODE
            if ($input != Qnil) tmpATC = _wxRuby_Unwrap_wxAuiTabCtrl($input);
            $1 = tmpATC;
            __CODE

          map_out code: '$result = _wxRuby_Wrap_wxAuiTabCtrl($1);'
        end

      end # define

    end # AuiTabCtrl

  end # Typemap

end # WXRuby3
