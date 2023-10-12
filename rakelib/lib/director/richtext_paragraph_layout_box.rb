# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './richtext_composite_object'

module WXRuby3

  class Director

    class RichTextParagraphLayoutBox < RichTextCompositeObject

      include Typemap::RichText

      def setup
        super
        if spec.module_name == 'wxRichTextParagraphLayoutBox'
          spec.items << 'wxRichTextField' <<
                        'wxRichTextStyleSheet' <<
                        'wxRichTextStyleDefinition' <<
                        'wxRichTextCharacterStyleDefinition' <<
                        'wxRichTextParagraphStyleDefinition' <<
                        'wxRichTextListStyleDefinition'
          spec.no_proxy 'wxRichTextStyleSheet',
                        'wxRichTextStyleDefinition',
                        'wxRichTextCharacterStyleDefinition',
                        'wxRichTextParagraphStyleDefinition',
                        'wxRichTextListStyleDefinition'
          spec.make_abstract 'wxRichTextStyleDefinition'
          spec.make_concrete 'wxRichTextCharacterStyleDefinition'
          spec.make_concrete 'wxRichTextParagraphStyleDefinition'
          spec.make_concrete 'wxRichTextListStyleDefinition'
          # documented declarations are incorrect
          spec.ignore 'wxRichTextStyleDefinition::GetStyle'
          spec.extend_interface 'wxRichTextStyleDefinition',
                                'const wxRichTextAttr& GetStyle() const'
          # missing from docs
          spec.extend_interface 'wxRichTextStyleDefinition',
                                'virtual wxRichTextStyleDefinition* Clone() const = 0'
          spec.new_object 'wxRichTextStyleDefinition::Clone'
          spec.add_header_code <<~__HEREDOC
              static void wxRuby_MakeRichTextStyleDefinitionOwned(VALUE rb_rtsd)
              {
                swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(CLASS_OF(rb_rtsd));
                RDATA(rb_rtsd)->dfree = ((swig_class *) swig_type->clientdata)->destroy; // make sure Ruby owns
              }
  
              extern VALUE wxRuby_RichTextStyleDefinition2Ruby(const wxRichTextStyleDefinition *wx_rtsd, int own)
              {
                  // If no object was passed to be wrapped.
                  if ( ! wx_rtsd )
                    return Qnil;
    
                  // Get the wx class and the ruby class we are converting into
                  wxString class_name( wx_rtsd->GetClassInfo()->GetClassName() );
                  wxCharBuffer wx_classname = class_name.mb_str();
                  VALUE r_class_name = rb_intern(wx_classname.data () + 2);
                  VALUE r_class = Qnil;
                
                  if ( class_name.Len() > 2 )
                  {
                    // lookup the class in the RichText module
                    if (rb_const_defined(mWxRTC, r_class_name))
                      r_class = rb_const_get(mWxRTC, r_class_name);
                  }
    
                  // Handle classes (currently) unknown in wxRuby.
                  if ( NIL_P(r_class) )
                  {
                    rb_warn("Error wrapping object; class '%s' is not (yet) supported in wxRuby",
                            (const char *)class_name.mb_str());
                    return Qnil;
                  }
                
                  // Otherwise, retrieve the swig type info for this class and wrap it
                  // in Ruby. wxRuby_GetSwigTypeForClass is defined in wx.i
                  swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(r_class);
                  VALUE rb_rtsd = SWIG_NewPointerObj(const_cast<wxRichTextStyleDefinition*> (wx_rtsd), swig_type, own);
                  return rb_rtsd;
              }
              __HEREDOC
          # add undocumented convenience method
          spec.extend_interface 'wxRichTextListStyleDefinition',
                                'void SetAttributes(int i, int leftIndent, int leftSubIndent, int bulletStyle, const wxString& bulletSymbol = wxEmptyString)'
          # redefine these since we need to be able to selectively specify 'disown'
          spec.ignore 'wxRichTextStyleSheet::AddCharacterStyle',
                      'wxRichTextStyleSheet::AddListStyle',
                      'wxRichTextStyleSheet::AddParagraphStyle',
                      'wxRichTextStyleSheet::AddStyle', ignore_doc: false
          spec.extend_interface 'wxRichTextStyleSheet',
                                'bool AddCharacterStyle(wxRichTextCharacterStyleDefinition *def_disown)',
                                'bool AddListStyle(wxRichTextListStyleDefinition *def_disown)',
                                'bool AddParagraphStyle(wxRichTextParagraphStyleDefinition *def_disown)',
                                'bool AddStyle(wxRichTextStyleDefinition *def_disown)'
          spec.disown 'wxRichTextCharacterStyleDefinition *def_disown',
                      'wxRichTextListStyleDefinition *def_disown',
                      'wxRichTextParagraphStyleDefinition *def_disown',
                      'wxRichTextStyleDefinition *def_disown'
          # The RemoveXXX methods need custom wrapper as we need to re-own any style defs that
          # are removed but NOT deleted
          spec.ignore 'wxRichTextStyleSheet::RemoveCharacterStyle',
                      'wxRichTextStyleSheet::RemoveListStyle',
                      'wxRichTextStyleSheet::RemoveParagraphStyle',
                      'wxRichTextStyleSheet::RemoveStyle', ignore_doc: false
          spec.add_extend_code 'wxRichTextStyleSheet', <<~__HEREDOC
            bool remove_character_style(wxRichTextStyleDefinition *def, bool deleteStyle=false)
            {
              bool rc = $self->RemoveCharacterStyle(def, deleteStyle);
              if (rc && !deleteStyle)
              {
                VALUE rb_rtsd = SWIG_RubyInstanceFor(const_cast<wxRichTextStyleDefinition*> (def));
                if (rb_rtsd && !NIL_P(rb_rtsd)) // should always be true
                {
                  wxRuby_MakeRichTextStyleDefinitionOwned(rb_rtsd);
                }
              }
              return rc;
            }
  
            bool remove_list_style(wxRichTextStyleDefinition *def, bool deleteStyle=false)
            {
              bool rc = $self->RemoveListStyle(def, deleteStyle);
              if (rc && !deleteStyle)
              {
                VALUE rb_rtsd = SWIG_RubyInstanceFor(const_cast<wxRichTextStyleDefinition*> (def));
                if (rb_rtsd && !NIL_P(rb_rtsd)) // should always be true
                {
                  wxRuby_MakeRichTextStyleDefinitionOwned(rb_rtsd);
                }
              }
              return rc;
            }
  
            bool remove_paragraph_style(wxRichTextStyleDefinition *def, bool deleteStyle=false)
            {
              bool rc = $self->RemoveParagraphStyle(def, deleteStyle);
              if (rc && !deleteStyle)
              {
                VALUE rb_rtsd = SWIG_RubyInstanceFor(const_cast<wxRichTextStyleDefinition*> (def));
                if (rb_rtsd && !NIL_P(rb_rtsd)) // should always be true
                {
                  wxRuby_MakeRichTextStyleDefinitionOwned(rb_rtsd);
                }
              }
              return rc;
            }
  
            bool remove_style(wxRichTextStyleDefinition *def, bool deleteStyle=false)
            {
              bool rc = $self->RemoveStyle(def, deleteStyle);
              if (rc && !deleteStyle)
              {
                VALUE rb_rtsd = SWIG_RubyInstanceFor(const_cast<wxRichTextStyleDefinition*> (def));
                if (rb_rtsd && !NIL_P(rb_rtsd)) // should always be true
                {
                  wxRuby_MakeRichTextStyleDefinitionOwned(rb_rtsd);
                }
              }
              return rc;
            }
            __HEREDOC
          spec.do_not_generate(:typedefs, :variables, :enums, :defines, :functions)
        end
      end

    end

  end

end
