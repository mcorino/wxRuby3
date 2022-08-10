#--------------------------------------------------------------------
# @file    event.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class Event < Director

      def setup
        # in case of wxEvent itself
        if spec.module_name == 'wxEvent'
          spec.set_only_for 'wxUSE_HOTKEY', 'wxEVT_HOTKEY'
          spec.add_swig_runtime_code <<~__HEREDOC
            // To allow instance variables to be attached to custom subclasses of
            // Wx::Event written in Ruby in a GC-safe, thread-safe way, wrap a
            // custom C++ subclass of wxEvent as Ruby's Wx::Event.
            // 
            // Note that this subclass only applies to Event objects created on the
            // Ruby side - for the large majority of normal event handling, objects
            // are created C++ side then given a shallow, transient wrapper for
            // their use in Ruby - see wxRuby_WrapWxEventInRuby in swig/wx.i.
            %rename(wxEvent) wxRubyEvent;
            __HEREDOC
          spec.include 'wx/event.h'
          spec.rename_class('wxEvent', 'wxRubyEvent')
          spec.extend_class('wxEvent', 'wxRubyEvent(wxEventType commandType = wxEVT_NULL, int id = 0, int prop_level = wxEVENT_PROPAGATE_NONE)')
          spec.add_header_code <<~__HEREDOC
            // Custom subclass implementation. Provide a constructor, destructor and
            // clone functions to allow proper linking to a Ruby object.
            class wxRubyEvent : public wxEvent
            {
              public:
              wxRubyEvent(wxEventType commandType = wxEVT_NULL, 
                          int id = 0,
                          int prop_level = wxEVENT_PROPAGATE_NONE) : 
                wxEvent(id, commandType) {  m_propagationLevel = prop_level; }
            
              // When the C++ side event is destroyed, unlink from the Ruby object
              // and remove that object from the tracking hash so it can be
              // collected by GC.
              virtual ~wxRubyEvent() {
                wxRuby_RemoveTracking( (void*)this );
              }
            
              // Will be called when add_pending_event is used to queue an event
              // (often when using Threads), because a clone is queued. So copy the
              // Wx C++ event, create a shallow (dup) of the Ruby event object, and
              // add to the tracking hash so that it is GC-protected
              virtual wxEvent* Clone() const {
                wxRubyEvent* wx_ev = new wxRubyEvent( GetEventType(),
                                                      GetId(),
                                                      m_propagationLevel );
            
                VALUE r_obj = SWIG_RubyInstanceFor((void *)this);
                VALUE r_obj_dup = rb_obj_clone(r_obj);
            
                DATA_PTR(r_obj_dup) = wx_ev;
                wxRuby_AddTracking( (void*)wx_ev, r_obj_dup );
                return wx_ev;
              }
            };
            __HEREDOC
          spec.add_extend_code 'wxRubyEvent', <<~__HEREDOC
            // This class method provides a guaranteed-unique event id that can be
            // used for custom event types.
            static VALUE new_event_type()
            {
            int event_type_id = (int)wxNewEventType();
            return INT2NUM(event_type_id );
            }
            __HEREDOC
        end
        super
      end
    end # class Event

  end # class Director

end # module WXRuby3
