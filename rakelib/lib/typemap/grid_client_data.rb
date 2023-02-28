###
# wxRuby3 Grid client data typemap definition
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # Typemaps for converting returned PGCell references to
    # either the correct wxRuby class
    module GridClientData

      include Typemap::Module

      define do

        map 'wxClientData *' => 'Object' do
          add_header_code <<~__CODE
            #include <wx/clntdata.h>
            extern void wxRuby_RegisterGridClientData(wxClientData* pcd, VALUE rbval);
            extern void wxRuby_UnregisterGridClientData(wxClientData* pcd);

            class WXRBGridClientData : public wxClientData
            {
            public:
              WXRBGridClientData() : rb_data(Qnil) { }
              WXRBGridClientData (VALUE data) : rb_data(data) { wxRuby_RegisterGridClientData(this, data); }
              virtual ~WXRBGridClientData () { wxRuby_UnregisterGridClientData(this); }
              VALUE GetData() const { return rb_data; }
            private:
              VALUE rb_data;
            };

            __CODE
          map_in code: '$1 = new WXRBGridClientData($input);'
          map_out code: <<~__CODE
            $result = Qnil;
            if ($1)
            {
              WXRBGridClientData* pgcd = dynamic_cast<WXRBGridClientData*> ($1);
              if (pgcd) $result = pgcd->GetData();
            }
          __CODE
        end

      end

    end

  end

end
