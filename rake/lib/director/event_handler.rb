#--------------------------------------------------------------------
# @file    event_handler.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class EvtHandler < Director

      def setup
        # fully ignore
        spec.ignore(
            'wxEvtHandler::Connect(int,wxEventType,wxObjectEventFunction,wxObject *,wxEvtHandler *)',
            'wxEvtHandler::Connect(wxEventType,wxObjectEventFunction,wxObject *,wxEvtHandler *)',
            'wxEvtHandler::Disconnect(wxEventType,wxObjectEventFunction,wxObject *,wxEvtHandler *)',
            'wxEvtHandler::Disconnect(int,wxEventType,wxObjectEventFunction,wxObject *,wxEvtHandler *)')
        spec.ignore([
            'wxEvtHandler::Connect(int,int,wxEventType,wxObjectEventFunction,wxObject *,wxEvtHandler *)',
            'wxEvtHandler::Disconnect(int,int,wxEventType,wxObjectEventFunction,wxObject *,wxEvtHandler *)'],
            ignore_doc: false) # keep docs
        spec.ignore(%w[wxEVT_HOTKEY])
        spec.ignore(%w[wxEvtHandler::SetClientData wxEvtHandler::GetClientData
                       wxEvtHandler::SetClientObject wxEvtHandler::GetClientObject])
        # special type mapping for wxEvtHander::QueueEvent
        # we do not need any 'disown' actions as the Ruby object should be tracked and will remain
        # alive as long as the C++ object is alive (which will be cleaned up in time by wxWidgets)
        spec.map 'wxEvent *event' => 'Wx::Event' do
          map_in code: '$1 = (wxEvent*)DATA_PTR($input);'
        end
        spec.add_runtime_code <<~__HEREDOC
          static swig_class wxRuby_GetSwigClassWxEvtHandler();
          WXRUBY_EXPORT VALUE wxRuby_GetEventTypeClassMap();

          // Internally, all event handlers are anonymous ruby Proc objects,
          // created by EvtHandler#connect. These need to be preserved from Ruby's
          // GC until the EvtHandler object itself is destroyed. So we keep a hash
          // which maps C++ pointer addresses of EvtHandlers to Ruby arrays of
          // the Proc objects which handle their events.
          WX_DECLARE_VOIDPTR_HASH_MAP(VALUE, PtrToEvtHandlerProcs);
          PtrToEvtHandlerProcs Evt_Handler_Handlers;
          
          // Add a proc to the list of protected handler for an EvtHandler object
          void wxRuby_ProtectEvtHandlerProc(void* evt_handler, VALUE proc) {
            if ( Evt_Handler_Handlers.count(evt_handler) == 0 )
              Evt_Handler_Handlers[evt_handler] = rb_ary_new();
            VALUE protected_procs = Evt_Handler_Handlers[evt_handler];
            rb_ary_push(protected_procs, proc);
          }
          
          // Called by App's mark function; protect all currently needed procs
          void wxRuby_MarkProtectedEvtHandlerProcs() {
            PtrToEvtHandlerProcs::iterator it;
            for( it = Evt_Handler_Handlers.begin(); 
                 it != Evt_Handler_Handlers.end(); 
                 ++it )
              rb_gc_mark( it->second );
          }
          
          // Called when a Window is destroyed; allows handler procs associated
          // with this object to be garbage collected at next run. See
          // swig/mark_free_impl.i
          void wxRuby_ReleaseEvtHandlerProcs(void* evt_handler) {
            Evt_Handler_Handlers.erase(evt_handler);
          }
          
          // Class which stores the ruby proc associated with an event handler. We
          // also cache the "call" symbol as this improves speed for event
          // handlers which are called many times (eg evt_motion)
          class wxRbCallback : public wxObject 
          {
          private:
              static ID c_call_id;
              static bool c_init_done;
            
          public:
              static ID call_id ()
              {
                if (!c_init_done)
                {
                  c_init_done = true;
                  c_call_id = rb_intern("call");
                }
                return c_call_id;
              }

              wxRbCallback(VALUE func) 
                : m_func(func) {}
              wxRbCallback(const wxRbCallback &other) 
                : wxObject(), m_func(other.m_func) {}
          
              // This method handles all events on the WxWidgets/C++ side. It link
              // inspects the event and based on the event's type wraps it in the
              // appropriate class (the mapping can be found in
              // lib/wx/classes/evthandler.rb). This wrapped event is then passed
              // into the ruby proc for handling on the ruby side
              void EventThunker(wxEvent &event)
              {
          #ifdef __WXRB_TRACE__                
                VALUE rb_event = wxRuby_WrapWxEventInRuby(0, &event);
          #else
                VALUE rb_event = wxRuby_WrapWxEventInRuby(&event);
          #endif
                wxRbCallback *cb = (wxRbCallback *)event.m_callbackUserData;
                rb_funcall(cb->m_func, call_id (), 1, rb_event);
              }
          
              VALUE m_func;
          };

          ID wxRbCallback::c_call_id = 0;
          bool wxRbCallback::c_init_done = false;

          __HEREDOC
        spec.add_extend_code 'wxEvtHandler', <<~__HEREDOC
          // This provides the public Ruby 'connect' method
          VALUE connect(int firstId, int lastId, wxEventType eventType, VALUE proc)
          {
            wxRuby_ProtectEvtHandlerProc((void *)$self, proc);
        
            wxObject* userData = new wxRbCallback(proc);
            wxObjectEventFunction function = 
                (wxObjectEventFunction )&wxRbCallback::EventThunker;
            self->Connect(firstId, lastId, eventType, function, userData);
          return Qtrue;
          }
        
          // Implementation of disconnect, accepting either an EVT_XXX constant
          // or a symbol name of an event handler method
          VALUE disconnect(int firstId, 
                   int lastId = wxID_ANY, 
                   VALUE evtSpecifier = Qnil)
          {
            wxEventType event_type;
          
            if ( TYPE(evtSpecifier) == T_FIXNUM ) // simply an Integer id
              event_type = NUM2INT(evtSpecifier);
            else if ( TYPE(evtSpecifier) == T_NIL ) // Not defined = any type
              event_type = wxEVT_NULL;
            else if ( TYPE(evtSpecifier) == T_SYMBOL ) // Symbol handler method
            {
              VALUE rb_evt_type = rb_funcall(wxRuby_GetSwigClassWxEvtHandler().klass, 
                               rb_intern("event_type_for_name"),
                               1, evtSpecifier);
              if ( rb_evt_type != Qnil )
                event_type = NUM2INT( rb_evt_type );
              else
              {
                VALUE msg = rb_inspect(evtSpecifier);
                rb_raise(rb_eTypeError, "Unknown event handler %s", 
                              StringValuePtr(msg));
              }
            }
            else 
              rb_raise(rb_eTypeError, "Invalid specifier for event type");
        
            // TODO - enable switching off all handlers by type only - this
            // version doesn't work if the first arg is wxID_ANY
            if ( self->Disconnect(firstId, lastId, event_type))
              return Qtrue;
            else
              return Qfalse;
          }
          __HEREDOC
        spec.add_wrapper_code <<~__HEREDOC
          static swig_class wxRuby_GetSwigClassWxEvtHandler() {
            return SwigClassWxEvtHandler;
          }     

          WXRUBY_EXPORT VALUE wxRuby_GetEventTypeClassMap() {
            VALUE map_name = rb_str_new2("EVENT_TYPE_CLASS_MAP");
            return rb_const_get(wxRuby_GetSwigClassWxEvtHandler().klass, rb_to_id(map_name)); 
          }
          __HEREDOC
        spec.add_swig_code <<~__HEREDOC
          // make sure wxEventType is known as 'int'
          typedef int wxEventType;
          __HEREDOC
        spec.do_not_generate :typedefs, :variables, :enums, :defines, :functions
        super
      end
    end # class EvtHandler

  end # class Director

end # module WXRuby3
