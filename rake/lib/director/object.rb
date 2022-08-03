#--------------------------------------------------------------------
# @file    object.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class Object < Director

      def initialize
        super
      end

      def setup(spec)
        spec.abstract(true)
        spec.ignore %w[wxObject::Ref wxObject::UnRef wxObject::GetRefData wxObject::IsKindOf wxObject::GetClassInfo]
        spec.add_extend_code 'wxObject', <<~__HEREDOC
          // Returns the string name of the C++ wx class which this object is wrapping.
          // The doubled wx name is to fool renamer.rb, which strips the wx prefix.
          // The actual final method is called wx_class
          VALUE wxwx_class() {
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
