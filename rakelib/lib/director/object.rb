# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Object < Director

      def setup
        spec.make_abstract('wxObject')
        spec.ignore %w[wxObject::Ref wxObject::UnRef wxObject::GetRefData wxObject::IsKindOf wxObject::GetClassInfo]
        spec.no_proxy 'wxObject'
        spec.add_extend_code 'wxObject', <<~__HEREDOC
          // Returns the string name of the C++ wx class which this object is wrapping.
          // The doubled wx_ name is to fool renamer.rb, which strips the wx_ prefix.
          // The actual final method is called wx_class
          VALUE wx_wx_class() {
          wxString class_name( self->GetClassInfo()->GetClassName() );
          VALUE rb_class_name = WXSTR_TO_RSTR(class_name);
          return rb_class_name;
          }
          __HEREDOC
        super
      end
    end # class Object

  end # class Director

end # module WXRuby3
