# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class PersistentObject < Director

      def setup
        super
        spec.gc_as_marked
        spec.add_header_code <<~__HEREDOC
          #include "wxruby-Persistence.h"

          WxRubyPersistentObject::WxRubyPersistentObject(VALUE rb_obj)
            : wxPersistentObject((void*)rb_obj)
          {}

          WxRubyPersistentObject::~WxRubyPersistentObject()
          {
            if (this->GetObject())
              WxRubyPersistenceManager::UnregisterPersistentObject(
                reinterpret_cast<VALUE> (this->GetObject()));
          } 

          bool WxRubyPersistentObject::SaveValue(const wxString& name, VALUE value)
          {
            WxRubyPersistenceManager* wxrb_pm = dynamic_cast<WxRubyPersistenceManager*> (&wxPersistenceManager::Get());
            return wxrb_pm ? wxrb_pm->SaveRubyValue(*this, name, value) : false;
          }

          VALUE WxRubyPersistentObject::RestoreValue(const wxString& name)
          {
            WxRubyPersistenceManager* wxrb_pm = dynamic_cast<WxRubyPersistenceManager*> (&wxPersistenceManager::Get());
            return wxrb_pm ? wxrb_pm->RestoreRubyValue(*this, name) : Qnil;
          } 
          __HEREDOC
        spec.use_class_implementation 'wxPersistentObject', 'WxRubyPersistentObject'
        spec.ignore %w[wxPersistentObject::GetObject wxPersistentObject::wxPersistentObject]
        spec.ignore %w[wxCreatePersistentObject wxPersistentRegisterAndRestore]
        spec.extend_interface 'wxPersistentObject',
                              'wxPersistentObject(VALUE rb_obj)',
                              'bool SaveValue(const wxString& name, VALUE value)',
                              'VALUE RestoreValue(const wxString& name)',
                              visibility: 'protected'
        spec.add_extend_code 'wxPersistentObject', <<~__HEREDOC
          VALUE GetObject()
          {
            WxRubyPersistentObject* rpo = dynamic_cast<WxRubyPersistentObject*> ($self);
            if (rpo)
            {
              return reinterpret_cast<VALUE> (rpo->GetObject());
            } 
            else
            {
              return Qnil;
            }
          }
          __HEREDOC
        super
      end
    end # class PersistentObject

  end # class Director

end # module WXRuby3
