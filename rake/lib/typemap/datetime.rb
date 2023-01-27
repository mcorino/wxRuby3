###
# wxRuby3 Common typemap definitions
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # Typemaps for converting between wxDateTime and Ruby's Date and Time
    # classes. These are used in CalendarCtrl etc
    module DateTime

      include Typemap::Module

      define do

        map 'wxDateTime&' => 'Time' do

          add_header_code <<~__CODE
            #ifndef __WXRB_DATETIME_HELPERS__
            #include <wx/datetime.h>
            
            WXRB_EXPORT_FLAG VALUE wxRuby_wxDateTimeToRuby(const wxDateTime& dt);
            
            WXRB_EXPORT_FLAG wxDateTime* wxRuby_wxDateTimeFromRuby(VALUE ruby_value);
            #endif
            __CODE

          # Accepts any Time-like object from Ruby and creates a wxDateTime
          map_in temp: 'wxrb_flag dtalloc',
                 code: '$1 = wxRuby_wxDateTimeFromRuby($input); dtalloc = true;'

          # Converts a return value of wxDateTime& to a Ruby Time object
          map_out code: '$result = wxRuby_wxDateTimeToRuby(*$1);'

          map_directorin code: '$input = wxRuby_wxDateTimeToRuby($1);'

          map_freearg code: 'if (dtalloc$argnum) delete $1;'

          map_typecheck precedence: 'SWIGOBJECT', code: '$1 = rb_obj_is_kind_of($input, rb_cTime);'
        end

        map 'wxDateTime' => 'Time' do

          # Converts a return value of wxDateTime to a Ruby Time object
          map_out code: '$result = wxRuby_wxDateTimeToRuby($1);'

          map_directorout temp: 'wxrb_flag dtalloc', code: <<~__CODE
            wxDateTime* tmp = wxRuby_wxDateTimeFromRuby($input);
            $result = *tmp;
            delete tmp;
            __CODE

        end

      end # define

    end # DateTime

  end # Typemap

end # WXRuby3
