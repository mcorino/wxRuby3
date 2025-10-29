# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Display < Director

      def setup
        super
        spec.items << 'wxVideoMode'
        # type mapping for 'wxArrayVideoModes'
        spec.map 'wxArrayVideoModes' => 'Array<Wx::VideoMode>' do
          map_out code: <<~__CODE
            $result = rb_ary_new();
            std::vector<wxVideoMode>* vmarr = &$1;
            for (const wxVideoMode& vm : *vmarr)
            {
              wxVideoMode* pvm = new wxVideoMode(vm);
              VALUE rb_vm = SWIG_NewPointerObj(SWIG_as_voidptr(pvm), SWIGTYPE_p_wxVideoMode, 1);
              rb_ary_push($result, rb_vm);
            }
            __CODE
        end
        # add Ruby-style accessors for public attr
        spec.add_extend_code 'wxVideoMode', <<~__HEREDOC
          VALUE get_w()
          {
            return INT2NUM($self->w);
          }
          VALUE get_h()
          {
            return INT2NUM($self->h);
          }
          VALUE get_bpp()
          {
            return INT2NUM($self->bpp);
          }
          VALUE get_refresh()
          {
            return INT2NUM($self->refresh);
          }
          __HEREDOC
        spec.make_readonly 'wxVideoMode::w',
                           'wxVideoMode::h',
                           'wxVideoMode::bpp',
                           'wxVideoMode::refresh'
        # make sure to get docs for public attr
        spec.ignore 'wxVideoMode::w',
                    'wxVideoMode::h',
                    'wxVideoMode::bpp',
                    'wxVideoMode::refresh',
                    ignore_doc: false
      end

    end

  end

end
