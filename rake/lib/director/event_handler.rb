###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class EvtHandler < Director

      def setup
        super
        # update generated code for all event handlers
        spec.post_processors << :update_evthandler
        if spec.module_name == 'wxEvtHandler'
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
          # Do not see much point in allowing/supporting this to be overridden when we
          # have TryBefore and TryAfter to handle this much cleaner
          spec.no_proxy 'wxEvtHandler::ProcessEvent'
          spec.regard('wxEvtHandler::ProcessEvent', regard_doc: false) # we provide customized docs
          # make SWIG aware of these
          spec.regard 'wxEvtHandler::TryBefore', 'wxEvtHandler::TryAfter', regard_doc: false
          # to optimize we need these to change name in Ruby
          spec.rename_for_ruby '_wx_try_before' => 'wxEvtHandler::TryBefore',
                               '_wx_try_after' => 'wxEvtHandler::TryAfter'
          # Special type mapping for wxEvtHandler::QueueEvent which assumes ownership of the C++ event.
          # We need to create a shallow copy of the Ruby event instance (copying it's Ruby members if any),
          # pass linkage of the C++ event to the copy and remove it from the original (input) Ruby
          # instance (so it can not delete/or reference it anymore); also start tracking the copy
          # (which effectively removes the tracking for the original).
          # Queued (pending) events are cleaned up (deleted) by wxWidgets after (failing) handling
          # which will automatically unlink and un-track them releasing the Ruby instance to be GC-ed.
          spec.map 'wxEvent *event' => 'Wx::Event' do
            map_in code: <<~__CODE
              // get the wrapped wxEvent*
              wxEvent *wx_ev = (wxEvent*)DATA_PTR($input);
              // check if this a user defined event
              if ( wx_ev->GetEventType() > wxEVT_USER_FIRST )
              {
                // we need to preserve the Ruby state
                // create a shallow copy of the Ruby object
                VALUE r_evt_copy = rb_obj_clone($input);
                // pass the wxEvent* over to the copy
                DATA_PTR(r_evt_copy) = wx_ev;
                // unlink the input
                DATA_PTR($input) = 0;
                // track the copy (this overwrites the record for the 
                // original, effectively untracking it)
                wxRuby_AddTracking( (void*)wx_ev, r_evt_copy);
              }
              else
              {
                // std wx event; no need to preserve the Ruby state
                // simply untrack and unlink the input
                wxRuby_RemoveTracking( (void*)wx_ev);
                DATA_PTR($input) = 0;
                // and just pass on the C++ event                
              }
              // Queue the C++ event
              $1 = wx_ev;
              __CODE
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
          spec.add_header_code <<~__HEREDOC
            #include <memory> // for std::unique_ptr<>
  
            class RbAsyncProcCallEvent : public wxAsyncMethodCallEvent
            {
            public:
              RbAsyncProcCallEvent(wxObject* evtObj, VALUE call) 
                : wxAsyncMethodCallEvent(evtObj)
                , m_rb_call(call)
              {}
  
              RbAsyncProcCallEvent(const RbAsyncProcCallEvent& other)
                : wxAsyncMethodCallEvent(other)
                , m_rb_call(other.m_rb_call)
              {}
  
              virtual ~RbAsyncProcCallEvent()
              {
                wxRuby_RemoveTracking((void*)this);
              }
  
              virtual wxEvent *Clone() const wxOVERRIDE
              {
                  return new RbAsyncProcCallEvent(*this);
              }
          
              virtual void Execute() wxOVERRIDE
              {
                  if (TYPE(m_rb_call) == T_ARRAY)
                  {
                    VALUE proc = rb_ary_entry(m_rb_call, 0);
                    int argc = RARRAY_LEN(m_rb_call)-1;
                    std::unique_ptr<VALUE> safe_args (new VALUE[argc]);
                    for (int i=0; i<argc ;i++)
                    {
                      safe_args.get()[i] = rb_ary_entry(m_rb_call, i+1);
                    }
                    rb_funcall2(proc, rb_intern("call"), argc, safe_args.get());
                  }
                  else
                  {
                    rb_funcall(m_rb_call, rb_intern("call"), 0, 0);
                  }
              }
          
            private:
              VALUE m_rb_call;
            };
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
  
            void call_after(VALUE call)
            {
              // valid call object?
              VALUE proc;
              if (TYPE(call) == T_ARRAY && 
                    (rb_obj_is_kind_of(proc = rb_ary_entry(call, 0), rb_cProc)
                     ||
                     rb_obj_is_kind_of(proc, rb_cMethod)))
              {
                // create C++ event
                RbAsyncProcCallEvent * evt = new RbAsyncProcCallEvent(self, call);
                // track it and the call object
                wxRuby_AddTracking( (void*)evt, call);
                // queue it
                self->QueueEvent(evt);
              }
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
          spec.do_not_generate :typedefs, :variables, :enums, :defines, :functions
        else
          spec.items.each do |itm|
            # Avoid adding unneeded directors
            spec.no_proxy("#{spec.class_name(itm)}::ProcessEvent") unless /\.h\Z/ =~ itm
            # to optimize we need these to change name in Ruby
            spec.rename_for_ruby '_wx_try_before' => 'wxEvtHandler::TryBefore',
                                 '_wx_try_after' => 'wxEvtHandler::TryAfter'
          end
        end
      end
    end # class EvtHandler

  end # class Director

  module SwigRunner::Processor

    # Special post-processor for EvtHandler and derivatives.
    # This provides both an optimization and extra safe guarding for the
    # event processing path in wxRuby.
    # The processor inserts code in the 'TryXXX' methods of the director class which check
    # for existence of any Ruby implementation of these methods ('try_before' or 'try_after')
    # in the absence of which a direct call to the wxWidget implementation is made. If there
    # does exist a Ruby ('override') implementation the method continues and calls the Ruby
    # method implementation.
    # The original wxWidget implementations are available in Ruby as 'wx_try_before' and
    # 'wx_try_after' and can be called from the 'overrides'.
    # Additionally the inserted code first off checks if the event handler is actually (still)
    # able to handle events by calling wxRuby_FindTracking() since in wxRuby it is in rare occasions
    # possible the event handler instance gets garbage collected AFTER the event processing
    # path has started in which case the C++ and Ruby object are unlinked and any attempts to
    # access the (originally) associated Ruby object will have bad results (this is especially
    # true for dialogs which are not cleaned up by wxWidgets but rather garbage collected by Ruby).
    def self.update_evthandler(target, spec)
      puts "Processor.update_evthandler: #{target}"

      at_director_method = false
      director_method_id = nil
      director_wx_class = nil
      director_method_line = 0

      prev_line = nil

      Stream.transaction do
        out = CodeStream.new(target)
        File.foreach(target, chomp: true) do |line|

          if at_director_method
            director_method_line += 1   # update line counter
            if director_method_line == 4 && line.strip.empty?   # are we at the right spot?
              code = <<~__CODE     # insert the code update
                // added by wxRuby3 Processor.update_evthandler
                if (wxRuby_FindTracking(this) == Qnil)
                  return false;
                if (!rb_respond_to(swig_get_self(), rb_intern("try_#{director_method_id.downcase}")))
                  return this->#{director_wx_class}::Try#{director_method_id}(event);
                __CODE
              line << "\n  " << code.split("\n").join("\n  ")
            elsif /rb_funcall\(.*\"(wx_try_(before|after))\".*\)/ =~ line
              curname = $1
              newname = "try_#{$2}"
              line[%Q{"#{curname}"}] = %Q{"#{newname}"}
              at_director_method = false  # end of update
            end
          elsif /bool\s+SwigDirector_(\w+)::Try(Before|After)\(.*\)\s+{/ =~ line
            director_wx_class = $1 == 'App' ? 'wxRubyApp' : $1
            director_method_id = $2     # After or Before method?
            at_director_method = true   # we're at a director method to be updated
            director_method_line = 0    # keep track of the method lines
          end

          out.puts(prev_line) if prev_line
          prev_line = line
        end
        out.puts prev_line if prev_line
      end
    end

  end

end # module WXRuby3
