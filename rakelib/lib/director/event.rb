# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Event < Director

      def setup
        if spec.module_name == 'wxEvent'
          spec.items << 'wxCommandEvent'
          # To allow instance variables to be attached to custom subclasses of
          # Wx::Event written in Ruby in a GC-safe, thread-safe way, wrap a
          # custom C++ subclass of wxEvent as Ruby's Wx::Event.
          #
          # Note that this subclass only applies to Event objects created on the
          # Ruby side - for the large majority of normal event handling, objects
          # are created C++ side then given a shallow, transient wrapper for
          # their use in Ruby - see wxRuby_WrapWxEventInRuby in swig/wx.i.
          #
          # make Ruby director and wrappers use custom implementation
          spec.use_class_implementation('wxEvent', 'wxRubyEvent')
          spec.extend_interface('wxEvent', 'wxEvent(wxEventType commandType = wxEVT_NULL, int id = 0, int prop_level = wxEVENT_PROPAGATE_NONE)')
          spec.ignore %w[wxEvent::GetEventUserData]
          spec.ignore 'wxEvent::wxEvent(int,wxEventType)'
          spec.no_proxy 'wxEvent::Clone', 'wxCommandEvent::Clone'
          spec.regard 'wxEvent::Clone', regard_doc: false # need updated doc
          # need this to force alloc func
          spec.make_concrete 'wxEvent'
          # type mapping for result #clone
          spec.map 'wxEvent*' => 'Wx::Event' do
            map_out code: <<~__CODE
              $result = wxRuby_WrapClonedWxEvent($1);
              __CODE
          end
          spec.add_header_code <<~__HEREDOC
            static VALUE Evt_Type_Map = NULL;
            static VALUE wxRuby_WrapClonedWxEvent(wxEvent* wx_evt)
            {
              wxString class_name( wx_evt->GetClassInfo()->GetClassName() );
              if (class_name == "wxEvent" || class_name == "wxCommandEvent")
              {
                // special clones for Ruby derived events are already managed and tracked
                return SWIG_RubyInstanceFor((void *)wx_evt);
              }

              // otherwise

              // Get the mapping of event types to classes
              if ( ! Evt_Type_Map )
              {
                Evt_Type_Map = wxRuby_GetEventTypeClassMap ();
              }
            
              // Then, look up the event type in this hash (MUCH faster than calling
              // EvtHandler.evt_class_for_type method)
              VALUE rb_event_type_id =  INT2NUM( wx_evt->GetEventType() );
              VALUE rb_event_class = rb_hash_aref(Evt_Type_Map, rb_event_type_id);

              if ( NIL_P(rb_event_class) )
              {
                rb_event_class = wxRuby_GetDefaultEventClass();
                rb_warning("Unmapped event type %i (%s)", wx_evt->GetEventType(), (const char *)class_name.mb_str());
              }

              // Wrap as owned object as this is a user code factory function.
              swig_type_info*  type = wxRuby_GetSwigTypeForClass(rb_event_class);
              swig_class* class_info = (swig_class*)type->clientdata;
              // Create a new (owned) Ruby event object 
              VALUE rb_evt = Data_Wrap_Struct(class_info->klass, VOIDFUNC(class_info->mark), 
                                                                 VOIDFUNC(class_info->destroy), 
                                                                 wx_evt);
              // track new event object
              SWIG_RubyAddTracking(wx_evt, rb_evt);
              // do not forget to mark the instance with the mangled swig type name
              rb_iv_set(rb_evt, "@__swigtype__", rb_str_new2(type->name));
            
            #if __WXRB_DEBUG__
              if (wxRuby_TraceLevel()>1)
                std::wcout << "* wxRuby_WrapClonedWxEvent - wrapped cloned event " << wx_evt << "{" << type->name << "}" << std::endl;
            #endif
            
              return rb_evt;
            }

            // Custom subclass implementation. Provide a constructor, destructor and
            // clone functions to allow proper linking to a Ruby object.
            class WXRUBY_EXPORT wxRubyEvent : public wxEvent
            {
              public:
              wxRubyEvent(wxEventType commandType = wxEVT_NULL, 
                          int id = 0,
                          int prop_level = wxEVENT_PROPAGATE_NONE) : 
                wxEvent(id, commandType) {  m_propagationLevel = prop_level; }
              wxRubyEvent(const wxRubyEvent& ev) :
                wxEvent(ev) { }
            
              // When the C++ side event is destroyed, unlink from the Ruby object
              // and remove that object from the tracking hash so it can be
              // collected by GC.
              virtual ~wxRubyEvent() {
                SWIG_RubyUnlinkObjects((void*)this);
                wxRuby_RemoveTracking((void*)this);
              }
            
              // Will be called when add_pending_event is used to queue an event
              // (often when using Threads), because a clone is queued. So copy the
              // Wx C++ event, create a shallow (dup) of the Ruby event object, and
              // add to the tracking hash so that it is GC-protected
              virtual wxEvent* Clone() const {
                wxRubyEvent* wx_ev = new wxRubyEvent( *this );
            
                VALUE r_obj = SWIG_RubyInstanceFor((void *)this);
                VALUE r_obj_dup = rb_obj_clone(r_obj);
            
                DATA_PTR(r_obj_dup) = wx_ev;
                wxRuby_AddTracking( (void*)wx_ev, r_obj_dup );
                return wx_ev;
              }
            };
            __HEREDOC
          spec.add_extend_code 'wxEvent', <<~__HEREDOC
            // This class method provides a guaranteed-unique event id that can be
            // used for custom event types.
            static VALUE new_user_event_type()
            {
              // make sure to get an id offset from the user events base so we can use that to
              // to check for user defined events  
              static int s_lastUsedUserEventType = wxEVT_USER_FIRST;

              int event_type_id = ++s_lastUsedUserEventType;
              return INT2NUM(event_type_id);
            }
            __HEREDOC
          spec.map 'wxObject*' => 'Wx::Object' do
            map_out code: '$result = wxRuby_WrapWxObjectInRuby($1);'
          end
          # make Ruby director and wrappers use custom implementation
          spec.use_class_implementation('wxCommandEvent', 'wxRubyCommandEvent')
          spec.ignore %w{
            wxCommandEvent::GetClientData
            wxCommandEvent::SetClientData
            wxCommandEvent::GetExtraLong
          }
          # ignore but keep doc; will replace with custom versions
          spec.ignore %w[wxCommandEvent::GetClientObject wxCommandEvent::SetClientObject], ignore_doc: false
          # for doc gen only
          spec.map 'wxClientData*' => 'Object', swig: false do
            map_in code: ''
            map_out code: ''
          end
          # need this to force alloc func
          spec.make_concrete 'wxCommandEvent'
          spec.add_header_code <<~__HEREDOC
            // Cf wxEvent - has to be written as a C+++ subclass to ensure correct
            // GC/thread protection of Ruby instance variables when user-written
            // event classes are queued.
            class WXRUBY_EXPORT wxRubyCommandEvent : public wxCommandEvent
            {
            public:
              wxRubyCommandEvent(wxEventType commandType = wxEVT_NULL, 
                                 int id = 0) 
                : wxCommandEvent(commandType, id) 
              { }
              wxRubyCommandEvent(const wxRubyCommandEvent& cev) 
                : wxCommandEvent(cev) 
                , has_ruby_data_(cev.has_ruby_data_) 
              { }
            
              // When the C++ side event is destroyed, unlink from the Ruby object
              // and remove that object from the tracking hash so it can be
              // collected by GC.
              virtual ~wxRubyCommandEvent() 
              {
                SWIG_RubyUnlinkObjects((void*)this);
                wxRuby_RemoveTracking((void*)this);
              }
            
              // Will be called when add_pending_event is used to queue an event
              // (often when using Threads), because a clone is queued. So copy the
              // Wx C++ event, create a shallow (dup) of the Ruby event object, and
              // add to the tracking hash so that it is GC-protected
              virtual wxCommandEvent* Clone() const 
              {
                wxRubyCommandEvent* wx_ev = new wxRubyCommandEvent(*this);
            
                VALUE r_obj = SWIG_RubyInstanceFor((void *)this);
                VALUE r_obj_dup = rb_obj_clone(r_obj);
            
                DATA_PTR(r_obj_dup) = wx_ev;
                wxRuby_AddTracking( (void*)wx_ev, r_obj_dup );
                return wx_ev;
              }

              bool has_ruby_data_ {};
            };


            // wxRuby must preserve ruby objects attached as the ClientData of
            // command events that have been user-defined in ruby. Some of the
            // standard wxWidgets CommandEvent classes also use ClientData
            // for their own purposes, and this must not be marked as the data is
            // not a ruby object, and will thus crash.
            WXRUBY_EXPORT void GC_mark_wxEvent(void *ptr)
            {
            #ifdef __WXRB_DEBUG__
              if (wxRuby_TraceLevel()>1)
                std::wcout << "> GC_mark_wxEvent : " << ptr << std::endl;
            #endif
            
              if ( ! ptr ) return;
              wxEvent* wx_event = (wxEvent*)ptr;
            #ifdef __WXRB_DEBUG__
              if (wxRuby_TraceLevel()>2)
                std::wcout << "* GC_mark_wxEvent(" << ptr << ":{" << wx_event->GetEventType() << "})" << std::endl;
            #endif
              if (wx_event->IsCommandEvent())
              {
                wxCommandEvent* wx_cm_event = (wxCommandEvent*)ptr;
                if (wx_cm_event->GetClientObject() == nullptr && wx_cm_event->GetClientData() != nullptr)
                {
                  wxRubyCommandEvent* rbcev = dynamic_cast<wxRubyCommandEvent*> (wx_cm_event);
                  if (rbcev && rbcev->has_ruby_data_)
                  {
                    VALUE rb_client_data = (VALUE)wx_cm_event->GetClientData();
                    rb_gc_mark(rb_client_data);
                  }
                }
              }
            
            #ifdef __WXRB_DEBUG__
              if (wxRuby_TraceLevel()>1)
                std::wcout << "< GC_mark_wxEvent : " <<  ptr << std::endl;
            #endif
            }
            __HEREDOC
          # CommandEvent requires custom handling of client data.
          # As command events do not 'own' their wxClientData objects we cannot use the regular support
          # for setting client data from Ruby as that would cause memory leaks by creating wxRubyClientData
          # instances that would never get deleted.
          # On the other hand wxWidgets library code might still set wxClientData instances propagated from
          # control or item client data which needs to be used for returning client data with GetClientObject.
          # As wxRuby client data always is any arbitrary Ruby Object anyway we simply combine the two approaches wxWidgets
          # offers here under 1 set of methods.
          spec.include 'wxruby-ClientData.h'
          spec.add_extend_code 'wxCommandEvent', <<~__HEREDOC
            VALUE GetClientObject()
            {
              VALUE rc = Qnil;
              // return Ruby client data depending on what's available
              if ($self->GetClientObject())
              {
                wxRubyClientData* rbcd = dynamic_cast<wxRubyClientData*> ($self->GetClientObject());
                if (rbcd) rc = rbcd->GetData();
              }
              else if ($self->GetClientData() != nullptr)
              {
                wxRubyCommandEvent* rbcev = dynamic_cast<wxRubyCommandEvent*> ($self);
                if (rbcev && rbcev->has_ruby_data_) rc = (VALUE)$self->GetClientData();
              }
              return rc;
            }

            void SetClientObject(VALUE cd)
            {
              wxRubyCommandEvent* rbcev = dynamic_cast<wxRubyCommandEvent*> ($self);
              if (rbcev)
              {
                // use SetClientData as not to create memory leaks; GC marker for events will keep it alive
                $self->SetClientData(NIL_P(cd) ? nullptr : (void*)cd);
                rbcev->has_ruby_data_ = !NIL_P(cd);
              }
            }
            __HEREDOC
          spec.add_wrapper_code <<~__HEREDOC
            extern VALUE wxRuby_GetDefaultEventClass() 
            {
              return SwigClassWxEvent.klass;
            }
            __HEREDOC
          spec.ignore 'wxQueueEvent'
          spec.ignore_unless('USE_HOTKEY', 'wxEVT_HOTKEY')
          spec.ignore_unless('WXMSW', 'wxEVT_MOUSE_CAPTURE_CHANGED', 'wxEVT_MOUSE_CAPTURE_LOST', 'wxEVT_DISPLAY_CHANGED')
          # make sure this event constant definition exists
          spec.add_swig_code %Q{%constant wxEventType wxEVT_MENU_HIGHLIGHT_ALL = wxEVT_MENU_HIGHLIGHT;}
          # add event type constant missing from interface defs
          spec.add_swig_code %Q{%constant wxEventType wxEVT_NC_PAINT = wxEVT_NC_PAINT;}
        end
        super
      end

      def process(gendoc: false)
        defmod = super
        unless spec.module_name == 'wxEvent'
          spec.items.each do |citem|
            def_item = defmod.find_item(citem)
            if Extractor::ClassDef === def_item
              spec.no_proxy "#{citem}::Clone"
              if def_item.hierarchy.has_key?('wxEvent')
                spec.override_inheritance_chain(citem, {'wxEvent' => 'wxEvent'}, 'wxObject')
              elsif def_item.hierarchy.has_key?('wxCommandEvent')
                spec.override_inheritance_chain(citem, {'wxCommandEvent' => 'wxEvent'}, 'wxEvent', 'wxObject')
              elsif def_item.hierarchy.has_key?('wxGestureEvent')
                spec.override_inheritance_chain(citem, {'wxGestureEvent' => 'wxEvents'}, 'wxEvent', 'wxObject')
              elsif def_item.hierarchy.has_key?('wxNotifyEvent')
                spec.override_inheritance_chain(citem, {'wxNotifyEvent' => 'wxEvents'}, {'wxCommandEvent' => 'wxEvent'}, 'wxEvent', 'wxObject')
              end
              case citem
              when 'wxNotifyEvent', 'wxPaintEvent'
                # keep these abstract in wxRuby
                spec.make_abstract(citem)
              else
                # need this to force alloc func
                spec.make_concrete(citem)
                spec.no_proxy(citem)
              end
            end
          end
        end
        defmod
      end

      def doc_generator
        if spec.module_name == 'wxEvent'
          EventDocGenerator.new(self)
        else
          super
        end
      end

    end # class Event

  end # class Director

  class EventDocGenerator < DocGenerator

    protected def gen_constants_doc(fdoc)
      super
      xref_table = package.all_modules.reduce(DocGenerator.constants_db) { |db, mod| db[mod] }
      gen_constant_doc(fdoc, 'EVT_MENU_HIGHLIGHT_ALL', xref_table['EVT_MENU_HIGHLIGHT'], '')
      gen_constant_doc(fdoc, 'EVT_NC_PAINT', xref_table['EVT_NC_PAINT'], '')
    end

  end

end # module WXRuby3
