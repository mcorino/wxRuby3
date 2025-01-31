# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class PGCell < Director

      def setup
        super
        spec.items << 'wxPGCellData' << 'wxPGChoiceEntry'
        spec.override_inheritance_chain('wxPGCellData', [])
        spec.make_abstract 'wxPGCellData' # there is never any need to create an instance in Ruby
        spec.no_proxy 'wxPGCellData'
        spec.gc_never 'wxPGCellData'
        # wxPGChoiceEntry are always passed by value and never transfer ownership
        # so we do not need tracking or special free function
        spec.gc_as_untracked 'wxPGChoiceEntry'
        spec.do_not_generate :variables, :enums, :defines, :functions # with PGProperty
        # add method for correctly wrapping PGCell output references
        spec.add_header_code <<~__CODE
            extern VALUE mWxPG; // declare external module reference
            extern VALUE wxRuby_WrapWxPGCellInRuby(const wxPGCell *wx_pc)
            {
              // If no object was passed to be wrapped.
              if ( ! wx_pc )
                return Qnil;

              // check if this instance is already tracked; return tracked value if so 
              VALUE r_pc = SWIG_RubyInstanceFor(const_cast<wxPGCell*> (wx_pc));
              if (r_pc && !NIL_P(r_pc)) return r_pc;              

              // Get the wx class and the ruby class we are converting into
              wxString class_name = wxS("wxPGCell");
              if (dynamic_cast<const wxPGChoiceEntry*> (wx_pc))
              {
                class_name = wxS("wxPGChoiceEntry");
              }
              VALUE r_class = Qnil;
              if ( class_name.Len() > 2 )
              {
                wxCharBuffer wx_classname = class_name.mb_str();
                VALUE r_class_name = rb_intern(wx_classname.data () + 2); // wxRuby class name (minus 'wx')
                if (rb_const_defined(mWxPG, r_class_name))
                  r_class = rb_const_get(mWxPG, r_class_name);
              }

              // If we cannot find the class output a warning and return nil
              if ( r_class == Qnil )
              {
                rb_warn("Error wrapping object; class `%s' is not (yet) supported in wxRuby",
                        (const char *)class_name.mb_str() );
                return Qnil;
              }


              // Otherwise, retrieve the swig type info for this class and wrap it
              // in Ruby. wxRuby_GetSwigTypeForClass is defined in wx.i
              swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(r_class);
              return SWIG_NewPointerObj(const_cast<wxPGCell*> (wx_pc), swig_type, 0);
            }
        __CODE
      end
    end # class PGCell

  end # class Director

end # module WXRuby3
