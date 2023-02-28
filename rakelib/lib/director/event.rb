###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
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
          spec.extend_interface('wxEvent', 'virtual wxEvent* Clone() const')
          spec.ignore %w[wxEvent::Clone wxEvent::GetEventUserData]
          spec.ignore 'wxEvent::wxEvent(int,wxEventType)'
          spec.no_proxy 'wxEvent::Clone'
          spec.add_header_code <<~__HEREDOC
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
          # make Ruby director and wrappers use custom implementation
          spec.use_class_implementation('wxCommandEvent', 'wxRubyCommandEvent')
          spec.ignore %w{
            wxCommandEvent::GetClientObject
            wxCommandEvent::SetClientObject
            wxCommandEvent::GetExtraLong
          }
          spec.extend_interface('wxCommandEvent', 'virtual wxCommandEvent* Clone() const')
          spec.no_proxy 'wxCommandEvent::Clone'
          spec.add_header_code <<~__HEREDOC
            // Cf wxEvent - has to be written as a C+++ subclass to ensure correct
            // GC/thread protection of Ruby instance variables when user-written
            // event classes are queued.
            //
            //
            // FIXME : intermittent errors with CommandEvent losing the tracked
            // object before handling - though the same code works fine with Wx::Event
            class WXRUBY_EXPORT wxRubyCommandEvent : public wxCommandEvent
            {
            public:
              wxRubyCommandEvent(wxEventType commandType = wxEVT_NULL, 
                                 int id = 0) : 
                wxCommandEvent(commandType, id) { }
              wxRubyCommandEvent(const wxRubyCommandEvent& cev) :
                wxCommandEvent(cev) { }
            
              // When the C++ side event is destroyed, unlink from the Ruby object
              // and remove that object from the tracking hash so it can be
              // collected by GC.
              virtual ~wxRubyCommandEvent() {
                SWIG_RubyUnlinkObjects((void*)this);
                wxRuby_RemoveTracking((void*)this);
              }
            
              // Will be called when add_pending_event is used to queue an event
              // (often when using Threads), because a clone is queued. So copy the
              // Wx C++ event, create a shallow (dup) of the Ruby event object, and
              // add to the tracking hash so that it is GC-protected
              virtual wxCommandEvent* Clone() const {
                wxRubyCommandEvent* wx_ev = new wxRubyCommandEvent(*this);
            
                VALUE r_obj = SWIG_RubyInstanceFor((void *)this);
                VALUE r_obj_dup = rb_obj_clone(r_obj);
            
                DATA_PTR(r_obj_dup) = wx_ev;
                wxRuby_AddTracking( (void*)wx_ev, r_obj_dup );
                return wx_ev;
              }
            };
            __HEREDOC
          spec.add_wrapper_code <<~__HEREDOC
            extern VALUE wxRuby_GetDefaultEventClass () {
              return SwigClassWxEvent.klass;
            }
            __HEREDOC
          spec.ignore 'wxQueueEvent'
          spec.set_only_for 'wxUSE_HOTKEY', 'wxEVT_HOTKEY'
          # make sure this event constant definition exists
          spec.add_swig_code %Q{%constant wxEventType wxEVT_MENU_HIGHLIGHT_ALL = wxEVT_MENU_HIGHLIGHT;}
        end
        super
      end

      def process(gendoc: false)
        defmod = super
        spec.items.each do |citem|
          unless citem == 'wxEvent'
            def_item = defmod.find_item(citem)
            if Extractor::ClassDef === def_item
              if def_item.hierarchy.has_key?('wxEvent')
                spec.override_inheritance_chain(citem, {'wxEvent' => 'wxEvent'}, 'wxObject')
              elsif def_item.hierarchy.has_key?('wxCommandEvent')
                spec.override_inheritance_chain(citem, {'wxCommandEvent' => 'wxEvent'}, 'wxEvent', 'wxObject')
              elsif def_item.hierarchy.has_key?('wxGestureEvent')
                spec.override_inheritance_chain(citem, {'wxGestureEvent' => 'wxEvents'}, 'wxEvent', 'wxObject')
              elsif def_item.hierarchy.has_key?('wxNotifyEvent')
                spec.override_inheritance_chain(citem, {'wxNotifyEvent' => 'wxEvents'}, {'wxCommandEvent' => 'wxEvent'}, 'wxEvent', 'wxObject')
              end
              spec.make_abstract(citem) if citem == 'wxPaintEvent' # doc flaw
            end
          end
        end
        defmod
      end
    end # class Event

  end # class Director

end # module WXRuby3
