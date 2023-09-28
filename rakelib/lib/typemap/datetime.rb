# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 Common typemap definitions
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # Typemaps for converting between wxDateTime and Ruby's Date and Time
    # classes. These are used in CalendarCtrl etc
    module DateTime

      include Typemap::Module

      define do

        map 'wxDateTime&' => 'Time,Date,DateTime' do

          add_header_code <<~__CODE
            #ifndef __WXRB_DATETIME_HELPERS__
            #include <wx/datetime.h>
            
            WXRB_EXPORT_FLAG VALUE wxRuby_wxDateTimeToRuby(const wxDateTime& dt);
            
            WXRB_EXPORT_FLAG wxDateTime* wxRuby_wxDateTimeFromRuby(VALUE ruby_value);
            #endif
            __CODE

          # Accepts any Time-like object from Ruby and creates a wxDateTime
          map_in temp: 'std::unique_ptr<wxDateTime> tmp_dt',
                 code: 'tmp_dt.reset(wxRuby_wxDateTimeFromRuby($input)); $1 = tmp_dt.get();'

          # Converts a return value of wxDateTime& to a Ruby Time object
          map_out code: '$result = wxRuby_wxDateTimeToRuby(*$1);'

          map_directorin code: '$input = wxRuby_wxDateTimeToRuby($1);'

          map_typecheck precedence: 'SWIGOBJECT', code: <<~__CODE
            $1 = rb_obj_is_kind_of($input, rb_cTime) || rb_respond_to($input, rb_intern ("to_time"));
            __CODE
        end

        map 'wxDateTime' => 'Time,Date,DateTime' do

          # Converts a return value of wxDateTime to a Ruby Time object
          map_out code: '$result = wxRuby_wxDateTimeToRuby($1);'

          map_directorout temp: 'std::unique_ptr<wxDateTime> tmp_dt', code: <<~__CODE
            tmp_dt.reset(wxRuby_wxDateTimeFromRuby($input));
            $result = *tmp_dt.get();
            __CODE

        end

      end # define

    end # DateTime

  end # Typemap

end # WXRuby3
