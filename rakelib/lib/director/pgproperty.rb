###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class PGProperty < Director

      include Typemap::PGEditor

      include Typemap::PGProperty

      include Typemap::PGCell

      def setup
        super
        if spec.module_name == 'wxPGProperty'
          spec.items << 'wxPGChoices' << 'wxPGPaintData' << 'propgriddefs.h'
          spec.regard 'wxPGPaintData::m_parent',
                      'wxPGPaintData::m_choiceItem',
                      'wxPGPaintData::m_drawnWidth',
                      'wxPGPaintData::m_drawnHeight'
          spec.rename_for_ruby 'parent' => 'wxPGPaintData::m_parent',
                               'choice_item' => 'wxPGPaintData::m_choiceItem',
                               'drawn_width' => 'wxPGPaintData::m_drawnWidth',
                               'drawn_height' => 'wxPGPaintData::m_drawnHeight'
          # wxPGChoices are always returned by value and never transfer ownership
          # so we do not need tracking or special free function
          spec.gc_as_untracked 'wxPGChoices'
          # prevent exposure of wxPGChoicesData; not of any real use in wxRuby
          spec.ignore 'wxPGChoices::wxPGChoices(wxPGChoicesData*)',
                      'wxPGChoices::AssignData',
                      'wxPGChoices::GetData',
                      'wxPGChoices::GetDataPtr',
                      'wxPGChoices::ExtractData',
                      # no use in wxRuby
                      'wxPGChoices::Add(size_t, const wxString *, const long *)',
                      'wxPGChoices::Add(const wxChar **, const long *)',
                      'wxPGChoices::Set(size_t, const wxString *, const long *)',
                      'wxPGChoices::Set(const wxChar **, const long *)',
                      'wxPGChoices::wxPGChoices(size_t, const wxString *, const long *)',
                      'wxPGChoices::wxPGChoices(const wxChar **, const long *)'
          # replace by extension
          spec.ignore 'wxPGChoices::operator[]', ignore_doc: false
          spec.add_extend_code 'wxPGChoices', <<~__HEREDOC
            wxPGChoiceEntry& __getitem__(unsigned int idx)
            {
              return (*self)[idx];
            }
          __HEREDOC
          spec.disown 'wxPGProperty *prop', 'wxPGProperty *childProperty'
          # do not think this useful for wxRuby (Also; caused GC problems)
          spec.ignore 'wxPGProperty::GetCellRenderer'
          # obsolete
          spec.ignore %w[wxPGProperty::AddChild wxPGProperty::GetValueString]
          # not of use in Ruby
          spec.ignore(%w[wxPGProperty::GetClientObject wxPGProperty::SetClientObject])
          # only keep the const version
          spec.ignore 'wxPGProperty::GetCell'
          spec.regard 'wxPGProperty::GetCell(unsigned int) const'
          spec.rename_for_ruby 'GetCellOrDefault' => 'wxPGProperty::GetCell(unsigned int) const'
          spec.rename_for_ruby 'get_cell' => 'wxPGProperty::GetOrCreateCell'
          # don't expose wxPGAttributeStorage; add a more Ruby-like extension
          spec.ignore 'wxPGProperty::GetAttributes'
          spec.add_extend_code 'wxPGProperty', <<~__HEREDOC
            VALUE each_attribute()
            {
              const wxPGAttributeStorage& att_store = self->GetAttributes();
              wxPGAttributeStorage::const_iterator it = att_store.StartIteration();
              wxVariant att_var;
              VALUE rc = Qnil;
              while (att_store.GetNext(it, att_var))
              {
                VALUE rb_att_var = SWIG_NewPointerObj(new wxVariant(att_var), SWIGTYPE_p_wxVariant, SWIG_POINTER_OWN);
                rc = rb_yield(rb_att_var);
              }
              return rc;
            }
            __HEREDOC
          # this creates an object that needs to be managed by the receiver
          spec.new_object 'wxPGProperty::GetEditorDialog'
          spec.suppress_warning(473, 'wxPGProperty::GetEditorDialog')
          # these return objects that will be owned (and need to be lifecycle managed) by any
          # overrrides
          spec.suppress_warning(473,
                                'wxPGProperty::DoGetEditorClass',
                                'wxPGProperty::DoGetValidator')
          spec.add_header_code <<~__HEREDOC
            extern void GC_mark_wxPGProperty(void* ptr)
            {
            #ifdef __WXRB_DEBUG__
              if (wxRuby_TraceLevel()>1)
              {
                std::wcout << "> GC_mark_wxPGProperty : " << ptr;
                if (ptr) std::wcout << " (" << ((wxPGProperty*)ptr)->GetName() << ')';
                std::wcout << std::endl;
              }
            #endif
              if (ptr)
              {
                VALUE object = (VALUE)((wxPGProperty*)ptr)->GetClientData();
                if (object && !NIL_P(object))
                {
            #ifdef __WXRB_DEBUG__
                  if (wxRuby_TraceLevel()>2)
                    std::wcout << "*** marking property data " << ptr << std::endl;
            #endif
                  rb_gc_mark(object);
                }
              }
            }
            __HEREDOC
          spec.add_swig_code '%markfunc wxPGProperty "GC_mark_wxPGProperty";'
          spec.ignore 'wxPGProperty::m_clientData' # not wanted for wxRuby
          # take protected members into account
          spec.regard 'wxPGProperty::wxPGProperty',
                      'wxPGProperty::ClearCells',
                      'wxPGProperty::EnsureCells',
                      'wxPGProperty::GetPropertyByNameWH',
                      'wxPGProperty::Empty',
                      'wxPGProperty::IsChildSelected'
          # add protected member var missing from XML docs
          # needed to have any use of overriding methods like #on_set_value
          spec.extend_interface 'wxPGProperty',
                                'wxVariant m_value',
                                visibility: 'protected'
          spec.rename_for_ruby 'value_' => 'wxPGProperty::m_value'
          spec.ignore %w[wxPG_LABEL wxPG_DEFAULT_IMAGE_SIZE]
          spec.ignore %w[wxPG_NULL_BITMAP wxPG_COLOUR_BLACK] unless Config.instance.wx_version >= '3.3.0'
          # define in Ruby
          spec.ignore %w[wxNullProperty wxPGChoicesEmptyData], ignore_doc: false
          # add method for correctly wrapping PGProperty output references
          spec.add_header_code <<~__CODE
            extern VALUE mWxPG; // declare external module reference
            extern VALUE wxRuby_WrapWxPGPropertyInRuby(const wxPGProperty *wx_pp)
            {
              // If no object was passed to be wrapped.
              if ( ! wx_pp )
                return Qnil;

              // check if this instance is already tracked; return tracked value if so 
              VALUE r_pp = SWIG_RubyInstanceFor(const_cast<wxPGProperty*> (wx_pp));
              if (r_pp && !NIL_P(r_pp)) return r_pp;              

              // Get the wx class and the ruby class we are converting into
              wxString class_name( wx_pp->GetClassInfo()->GetClassName() ); 
              VALUE r_class = Qnil;
              if ( class_name.Len() > 2 )
              {
                if (class_name == wxS("wxPGRootProperty"))
                {
                  r_class = ((swig_class*)SWIGTYPE_p_wxPGProperty->clientdata)->klass;
                }
                else
                {
                  wxCharBuffer wx_classname = class_name.mb_str();
                  VALUE r_class_name = rb_intern(wx_classname.data () + 2); // wxRuby class name (minus 'wx')
                  if (rb_const_defined(mWxPG, r_class_name))
                    r_class = rb_const_get(mWxPG, r_class_name);
                }
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
              return SWIG_NewPointerObj(const_cast<wxPGProperty*> (wx_pp), swig_type, 0);
            }
            __CODE
        else
          spec.add_header_code 'extern void GC_mark_wxPGProperty(void* ptr);'
          spec.items.each do |itm|
            unless itm == 'wxColourPropertyValue'
              # add protected member methods and var to complement base class
              spec.extend_interface itm,
                                    'void ClearCells(FlagType ignoreWithFlags, bool recursively)',
                                    'void EnsureCells(unsigned int column)',
                                    'wxPGProperty * GetPropertyByNameWH(const wxString &name, unsigned int hintIndex) const',
                                    'void Empty()',
                                    'bool IsChildSelected(bool recursive=false) const',
                                    'wxVariant m_value',
                                    visibility: 'protected'
              spec.rename_for_ruby 'value_' => "#{itm}::m_value"
              spec.add_swig_code %Q{%markfunc #{itm} "GC_mark_wxPGProperty";}
              spec.new_object %Q{#{itm}::GetEditorDialog}
              spec.suppress_warning(473, "#{itm}::GetEditorDialog")
            end
          end
        end
        spec.add_header_code 'typedef wxPGProperty::FlagType FlagType;'
      end
    end # class PGProperty

  end # class Director

end # module WXRuby3
