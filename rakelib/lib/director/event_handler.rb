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
              'wxEvtHandler::Connect',
              'wxEvtHandler::Disconnect')
          spec.ignore(%w[wxEVT_HOTKEY])
          spec.ignore(%w[wxEvtHandler::SetClientData wxEvtHandler::GetClientData
                         wxEvtHandler::SetClientObject wxEvtHandler::GetClientObject])
          # Do not see much point in allowing/supporting this to be overridden when we
          # have TryBefore and TryAfter to handle this much cleaner
          spec.no_proxy 'wxEvtHandler::ProcessEvent'
          spec.regard('wxEvtHandler::ProcessEvent', regard_doc: false) # we provide customized docs
          # make SWIG aware of these
          spec.regard 'wxEvtHandler::TryBefore', 'wxEvtHandler::TryAfter'
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
            
            // Class which stores the ruby proc associated with an event handler. We
            // also cache the "call" symbol as this improves speed for event
            // handlers which are called many times (eg evt_motion)
            class wxRbCallback : public wxObject 
            {
            private:
                static ID c_call_id;
                static bool c_init_done;
              
                static ID call_id ()
                {
                  if (!c_init_done)
                  {
                    c_init_done = true;
                    c_call_id = rb_intern("call");
                  }
                  return c_call_id;
                }

                static VALUE rescue(VALUE, VALUE error)
                { 
                  return error;
                }
  
                static VALUE do_call_back(VALUE rb_cb_data)
                {
                  rb_funcall(rb_ary_entry(rb_cb_data, 0), call_id (), 1, rb_ary_entry(rb_cb_data, 1));
                  return Qnil;
                }

            public:
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
            #ifdef __WXRB_DEBUG__                
                  VALUE rb_event = wxRuby_WrapWxEventInRuby(0, &event);
            #else
                  VALUE rb_event = wxRuby_WrapWxEventInRuby(&event);
            #endif
                  wxRbCallback *cb = (wxRbCallback *)event.m_callbackUserData;
                  VALUE rb_cb_args = rb_ary_new();
                  rb_ary_push(rb_cb_args, cb->m_func);
                  rb_ary_push(rb_cb_args, rb_event);
                  VALUE err = rb_rescue2(VALUEFUNC(do_call_back), rb_cb_args, VALUEFUNC(rescue), Qnil, rb_eException, 0);
                  if (!NIL_P(err))
                  {
                    VALUE rb_app = rb_const_get(wxRuby_Core(), rb_intern("THE_APP"));
                    rb_iv_set(rb_app, "@exception", err);
            #ifdef __WXRB_DEBUG__                
                    if (!rb_obj_is_kind_of(err, rb_eSystemExit) && wxRuby_TraceLevel()>0)
                    {
                      VALUE msg = rb_funcall(err, rb_intern("message"), 0);
                      VALUE err_name = rb_funcall(rb_funcall(err, rb_intern("class"), 0), rb_intern("name"), 0);
                      VALUE bt = rb_funcall(err, rb_intern("backtrace"), 0);
                      bt = rb_funcall(bt, rb_intern("join"), 1, rb_str_new2("\\n"));
                      std::cerr << std::endl
                                << ' ' << StringValuePtr(err_name) << ": " << StringValuePtr(msg) << std::endl
                                << StringValuePtr(bt) << std::endl;
                    }
            #endif
                    rb_funcall(rb_app, rb_intern("exit_main_loop"), 0);
                  }
                }
            
                VALUE m_func;
            };
  
            ID wxRbCallback::c_call_id = 0;
            bool wxRbCallback::c_init_done = false;
  
            // Internally, all event handlers are anonymous ruby Proc objects,
            // created by EvtHandler#connect. These need to be preserved from Ruby's
            // GC until the EvtHandler object itself is destroyed. So we keep a hash
            // which maps C++ pointer addresses of EvtHandlers to lists of
            // the callback objects created to handle their events.
            typedef wxVector<wxRbCallback*> EvtHandlerProcList;
            typedef EvtHandlerProcList* EvtHandlerProcListPtr;
            WX_DECLARE_VOIDPTR_HASH_MAP(EvtHandlerProcListPtr, PtrToEvtHandlerProcs);
            PtrToEvtHandlerProcs Evt_Handler_Handlers;
            
            // Add a proc to the list of protected handler for an EvtHandler object
            void wxRuby_ProtectEvtHandlerProc(void* evt_handler, wxRbCallback* proc_cb) 
            {
              if (Evt_Handler_Handlers.count(evt_handler) == 0)
                Evt_Handler_Handlers[evt_handler] = new EvtHandlerProcList();
              Evt_Handler_Handlers[evt_handler]->push_back(proc_cb);
            }
            
            // Called by App's mark function; protect all currently needed procs
            void wxRuby_MarkProtectedEvtHandlerProcs() 
            {
              PtrToEvtHandlerProcs::iterator it;
              for( it = Evt_Handler_Handlers.begin(); 
                   it != Evt_Handler_Handlers.end(); 
                   ++it )
              {
                for (EvtHandlerProcList::iterator itproc = it->second->begin();
                     itproc != it->second->end();
                     itproc++)
                {
                  rb_gc_mark((*itproc)->m_func);
                }
              }
            }
            
            // Called when a Window (or other event handler) is destroyed; allows handler procs associated
            // with this object to be garbage collected at next run. See
            // swig/mark_free_impl.i
            WXRUBY_EXPORT void wxRuby_ReleaseEvtHandlerProcs(void* evt_handler) 
            {
              if (Evt_Handler_Handlers.count(evt_handler) != 0)
              {
                delete Evt_Handler_Handlers[evt_handler];
                Evt_Handler_Handlers.erase(evt_handler);
              }
            }

            static ID __wxrb_method_id()
            {
              static ID __id = 0;
              if (__id == 0) __id = rb_intern("method");
              return __id;
            }

            static ID __wxrb_try_before_id()
            {
              static ID __id = 0;
              if (__id == 0) __id = rb_intern("try_before");
              return __id;
            }

            static ID __wxrb_try_after_id()
            {
              static ID __id = 0;
              if (__id == 0) __id = rb_intern("try_after");
              return __id;
            }

            static ID __wxrb_source_location_id()
            {
              static ID __id = 0;
              if (__id == 0) __id = rb_intern("source_location");
              return __id;
            }

            WXRUBY_EXPORT bool wxRuby_IsNativeMethod(VALUE object, ID method_id)
            {
              return Qnil == rb_funcall(rb_funcall(object, __wxrb_method_id(), 1, ID2SYM(method_id)), 
                                        __wxrb_source_location_id(), 
                                        0);
            }
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
              wxRbCallback* userData = new wxRbCallback(proc);
              wxRuby_ProtectEvtHandlerProc((void *)$self, userData);
          
              wxObjectEventFunction function = 
                  (wxObjectEventFunction )&wxRbCallback::EventThunker;
              $self->Connect(firstId, lastId, eventType, function, userData);
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
          
              if ( $self->Disconnect(firstId, lastId, event_type))
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
          end
          spec.add_header_code <<~__HEREDOC
              static ID __wxrb_try_before_id()
              {
                static ID __id = 0;
                if (__id == 0) __id = rb_intern("try_before");
                return __id;
              }
  
              static ID __wxrb_try_after_id()
              {
                static ID __id = 0;
                if (__id == 0) __id = rb_intern("try_after");
                return __id;
              }
          __HEREDOC
        end
      end
    end # class EvtHandler

  end # class Director

  module SwigRunner
    class Processor

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
      class UpdateEvthandler < Processor

        def run
          at_director_method = false
          director_method_id = nil
          director_wx_class = nil
          director_method_line = 0

          prev_line = nil

          update_source(at_end: ->(){ prev_line }) do |line|
            if at_director_method
              director_method_line += 1   # update line counter
              if director_method_line == 4 && line.strip.empty?   # are we at the right spot?
                code = <<~__CODE     # insert the code update
                // added by wxRuby3 Processor.update_evthandler
                // if Ruby object not registered anymore or no Ruby defined method override
                // reroute directly to C++ method
                if (Qnil == wxRuby_FindTracking(this) || wxRuby_IsNativeMethod(swig_get_self(), __wxrb_try_#{director_method_id.downcase}_id()))
                {
                  return this->#{director_wx_class}::Try#{director_method_id}(event);
                }
                __CODE
                line << "\n  " << code.split("\n").join("\n  ")
                at_director_method = false  # end of update
              end
            elsif /bool\s+SwigDirector_(\w+)::Try(Before|After)\(.*\)\s+{/ =~ line
              director_wx_class = $1 == 'App' ? 'wxApp' : $1
              director_method_id = $2     # After or Before method?
              at_director_method = true   # we're at a director method to be updated
              director_method_line = 0    # keep track of the method lines
            end

            result = prev_line
            prev_line = line
            result
          end
        end

      end # class UpdateEvthandler

    end
  end

end # module WXRuby3
