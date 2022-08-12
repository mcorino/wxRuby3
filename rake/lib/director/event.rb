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
        spec.ignore_bases('wxMouseEvent' => 'wxMouseState', 'wxKeyEvent' => 'wxKeyboardState')
        spec.make_abstract('wxPaintEvent')
        spec.set_only_for 'wxUSE_HOTKEY', 'wxEVT_HOTKEY'
        spec.set_only_for 'WXWIN_COMPATIBILITY_2_8', 'wxShowEvent::GetShow', 'wxIconizeEvent::Iconized'
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
        spec.extend_class('wxEvent', 'virtual wxEvent* Clone() const')
        spec.no_proxy 'wxRubyEvent::Clone'
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
        spec.add_swig_runtime_code <<~__HEREDOC
          %rename(wxCommandEvent) wxRubyCommandEvent;
          __HEREDOC
        spec.include 'wx/event.h'
        spec.ignore %w{
          wxCommandEvent::Checked
          wxCommandEvent::GetClientObject
          wxCommandEvent::SetClientObject
          wxCommandEvent::GetExtraLong
        }
        spec.rename_class('wxCommandEvent', 'wxRubyCommandEvent')
        # spec.override_base('wxCommandEvent', 'wxRubyEvent')
        spec.extend_class('wxCommandEvent', 'virtual wxCommandEvent* Clone() const')
        spec.no_proxy 'wxRubyCommandEvent::Clone'
        spec.add_header_code <<~__HEREDOC
          // Cf wxEvent - has to be written as a C+++ subclass to ensure correct
          // GC/thread protection of Ruby instance variables when user-written
          // event classes are queued.
          //
          //
          // FIXME : intermittent errors with CommandEvent losing the tracked
          // object before handling - though the same code works fine with Wx::Event
          class wxRubyCommandEvent : public wxCommandEvent
          {
          public:
            wxRubyCommandEvent(wxEventType commandType = wxEVT_NULL, 
                               int id = 0) : 
              wxCommandEvent(commandType, id) { }
          
            // When the C++ side event is destroyed, unlink from the Ruby object
            // and remove that object from the tracking hash so it can be
            // collected by GC.
            virtual ~wxRubyCommandEvent() {
              wxRuby_RemoveTracking( (void*)this );
            }
          
            // Will be called when add_pending_event is used to queue an event
            // (often when using Threads), because a clone is queued. So copy the
            // Wx C++ event, create a shallow (dup) of the Ruby event object, and
            // add to the tracking hash so that it is GC-protected
            virtual wxCommandEvent* Clone() const {
              wxRubyCommandEvent* wx_ev = new wxRubyCommandEvent(GetEventType(), 
                                                                 GetId());
          
              VALUE r_obj = SWIG_RubyInstanceFor((void *)this);
              VALUE r_obj_dup = rb_obj_clone(r_obj);
          
              DATA_PTR(r_obj_dup) = wx_ev;
              wxRuby_AddTracking( (void*)wx_ev, r_obj_dup );
              return wx_ev;
            }
          };
          __HEREDOC
        spec.ignore 'wxKeyEvent::GetPosition(wxCoord *,wxCoord *) const'
        if spec.module_name == 'wxEvent'
          spec.ignore 'wxQueueEvent'
          spec.add_wrapper_code <<~__HEREDOC
            extern VALUE wxRuby_GetDefaultEventClass () {
              return SwigClassWxEvent.klass;
            }
            __HEREDOC
        end
        super
      end

      def process
        defmod = super
        spec.items.each do |citem|
          unless citem == 'wxEvent'
            def_item = defmod.find_item(citem)
            if Extractor::ClassDef === def_item
              if def_item.hierarchy.has_key?('wxEvent')
                spec.override_base(citem, 'wxRubyEvent')
              elsif def_item.hierarchy.has_key?('wxCommandEvent')
                spec.override_base(citem, 'wxRubyCommandEvent')
              end
            end
          end
        end
        defmod
      end
    end # class Event

  end # class Director

end # module WXRuby3
