###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class PGProperty < Director

      def setup
        super
        if spec.module_name == 'wxPGProperty'
          spec.items << 'wxPGChoices' << 'wxPGPaintData' << 'wxPGCellRenderer' << 'wxPGDefaultRenderer'
          spec.gc_as_refcounted 'wxPGCellRenderer', 'wxPGDefaultRenderer'
          spec.override_inheritance_chain('wxPGCellRenderer')
          spec.override_inheritance_chain('wxPGDefaultRenderer', 'wxPGCellRenderer')
          spec.rename_for_ruby 'parent' => 'wxPGPaintData::m_parent',
                               'choice_item' => 'wxPGPaintData::m_choiceItem',
                               'drawn_width' => 'wxPGPaintData::m_drawnWidth',
                               'drawn_height' => 'wxPGPaintData::m_drawnHeight'
          # wxPGChoices are always returned by value and never transfer ownership
          # so we do not need tracking or special free function
          spec.gc_as_temporary 'wxPGChoices'
          # prevent exposure of wxPGChoicesData; not of any real use in wxRuby
          spec.ignore 'wxPGChoices::wxPGChoices(wxPGChoicesData*)',
                      'wxPGChoices::AssignData',
                      'wxPGChoices::GetData',
                      'wxPGChoices::GetDataPtr',
                      'wxPGChoices::ExtractData'
          # replace by extension
          spec.ignore 'wxPGChoices::operator[]', ignore_doc: false
          spec.add_extend_code 'wxPGChoices', <<~__HEREDOC
            wxPGChoiceEntry __get__(unsigned int idx)
            {
              return (*self)[idx];
            }
          __HEREDOC
          spec.disown 'wxPGProperty *prop', 'wxPGProperty *childProperty'
          # obsolete
          spec.ignore %w[wxPGProperty::AddChild wxPGProperty::GetValueString]
          # not of use in Ruby
          spec.ignore(%w[wxPGProperty::GetClientObject wxPGProperty::SetClientObject])
          # provide customized implementation
          spec.ignore(%w[wxPGProperty::GetClientData wxPGProperty::SetClientData], ignore_doc: false) # keep docs
          # Replace the old Wx definitions of these methods (which would segfault)
          spec.add_extend_code 'wxPGProperty', <<~__HEREDOC
              VALUE get_client_data() 
              {
                VALUE returnVal = (VALUE)self->GetClientData();
                if (!returnVal)
                  return Qnil;
                return returnVal;
              }
            
              void set_client_data(VALUE item_data) 
              {
                self->SetClientData((void *)item_data);
              }
            __HEREDOC
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
          # any overrrides
          spec.suppress_warning(473,
                                'wxPGProperty::DoGetEditorClass',
                                'wxPGProperty::DoGetValidator',
                                'wxPGProperty::GetCellRenderer')
          spec.add_header_code <<~__HEREDOC
            extern void GC_mark_wxPGProperty(void* ptr)
            {
              if (ptr)
                rb_gc_mark((VALUE)((wxPGProperty*)ptr)->GetClientData());
            }
            __HEREDOC
          spec.add_swig_code '%markfunc wxPGProperty "GC_mark_wxPGProperty";'
          spec.make_enum_untyped 'wxPGPropertyFlags'
          # define in Ruby
          spec.ignore %w[wxNullProperty wxPGChoicesEmptyData], ignore_doc: false
        else
          spec.add_header_code 'extern void GC_mark_wxPGProperty(void* ptr);'
          spec.items.each do |itm|
            spec.add_swig_code %Q{%markfunc #{itm} "GC_mark_wxPGProperty";}
          end
        end
        spec.add_header_code 'typedef wxPGProperty::FlagType FlagType;'
      end
    end # class PGProperty

  end # class Director

end # module WXRuby3
