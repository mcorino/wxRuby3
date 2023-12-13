# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 Common typemap definitions
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # These typemaps are used by TreeCtrl and TreeEvent to convert wx tree
    # item ids into lightweight wrapper objects
    module TreeItemId

      include Typemap::Module

      define do

        map 'wxTreeItemId&' => 'Wx::TreeItemId' do

          add_header_code <<~__CODE
            // implemented in TreeEvent.cpp
            extern VALUE _wxRuby_Wrap_wxTreeItemId(const wxTreeItemId& id);
            extern wxTreeItemId _wxRuby_Unwrap_wxTreeItemId(VALUE id);
            extern bool _wxRuby_Is_wxTreeItemId(VALUE id);
            __CODE

          map_in temp: 'wxTreeItemId tmpId', code: <<~__CODE
            if ($input != Qnil) tmpId = _wxRuby_Unwrap_wxTreeItemId($input);
            $1 = &tmpId;
            __CODE

          map_directorin code: '$input = _wxRuby_Wrap_wxTreeItemId($1);'

          map_typecheck precedence: 'POINTER', code: '$1 = _wxRuby_Is_wxTreeItemId($input);'
        end

        map 'wxTreeItemId' => 'Wx::TreeItemId' do

          add_header_code <<~__CODE
            // implemented in TreeEvent.cpp
            extern VALUE _wxRuby_Wrap_wxTreeItemId(const wxTreeItemId& id);
            extern wxTreeItemId _wxRuby_Unwrap_wxTreeItemId(VALUE id);
            extern bool _wxRuby_Is_wxTreeItemId(VALUE id);
            __CODE

          map_in temp: 'wxTreeItemId tmpId', code: <<~__CODE
            if ($input != Qnil) tmpId = _wxRuby_Unwrap_wxTreeItemId($input);
            $1 = tmpId;
            __CODE

          map_directorin code: '$input = _wxRuby_Wrap_wxTreeItemId($1);'

          map_out code: '$result = _wxRuby_Wrap_wxTreeItemId($1);'

          map_directorout temp: 'wxTreeItemId tmpId', code: <<~__CODE
            if ($input != Qnil) tmpId = _wxRuby_Unwrap_wxTreeItemId($input);
            $result = tmpId;
          __CODE

          map_typecheck precedence: 'POINTER', code: '$1 = _wxRuby_Is_wxTreeItemId($input);'
        end

      end # define

    end # TreeItemId

  end # Typemap

end # WXRuby3
