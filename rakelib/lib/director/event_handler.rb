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
          # add special mapping for event filters so we can accept the app instance as well
          # although Wx::App is not derived from Wx::EventFilter in wxRuby (no multiple inheritance)
          spec.map 'wxEventFilter*' => 'Wx::EventFilter,Wx::App' do
            map_in code: <<~__CODE
              int res = SWIG_ERROR; 
              void *argp = 0;
              if (rb_obj_is_kind_of($input, ((swig_class*)SWIGTYPE_p_wxEventFilter->clientdata)->klass))
              {
                res = SWIG_ConvertPtr($input, &argp, SWIGTYPE_p_wxEventFilter, 0);  
                if (SWIG_IsOK(res)) $1 = reinterpret_cast< wxEventFilter * >(argp);
              }
              else
              {
                VALUE app_klass = rb_eval_string("Wx::App");
                if (rb_obj_is_kind_of($input, app_klass))
                {
                  res = SWIG_ConvertPtr($input, &argp, wxRuby_GetSwigTypeForClass(app_klass), 0);
                  if (SWIG_IsOK(res)) $1 = reinterpret_cast< wxApp * >(argp);
                }
              }
              if (!SWIG_IsOK(res)) 
              {
                SWIG_exception_fail(SWIG_ArgError(res), Ruby_Format_TypeError( "", "wxEventFilter *","wxEvtHandler::$symname", 1, $input)); 
              }
              __CODE
          end
          spec.add_runtime_code <<~__HEREDOC
            static swig_class wxRuby_GetSwigClassWxEvtHandler();
            WXRUBY_EXPORT VALUE wxRuby_GetEventTypeClassMap();

            class wxRbCallback;
            static void wxRuby_ReleaseEvtHandlerProc(void* evt_handler, wxRbCallback* proc_cb);
            
            // Class which stores the ruby proc associated with an event handler. We
            // also cache the "call" symbol as this improves speed for event
            // handlers which are called many times (eg evt_motion)
            class wxRbCallback : public wxObject 
            {
            public:
                wxRbCallback(VALUE func, void* evh) 
                  : m_func(func), m_evh(evh) {}
                wxRbCallback(const wxRbCallback &other) 
                  : wxObject(), m_func(other.m_func), m_evh(other.m_evh) {}
                ~wxRbCallback()
                { wxRuby_ReleaseEvtHandlerProc(m_evh, this); }
            
                // This method handles all events on the WxWidgets/C++ side. It link
                // inspects the event and based on the event's type wraps it in the
                // appropriate class (the mapping can be found in
                // lib/wx/classes/evthandler.rb). This wrapped event is then passed
                // into the ruby proc for handling on the ruby side
                void EventThunker(wxEvent &event)
                {
                  static WxRuby_ID call_id("call");

            #ifdef __WXRB_DEBUG__                
                  VALUE rb_event = wxRuby_WrapWxEventInRuby(0, &event);
            #else
                  VALUE rb_event = wxRuby_WrapWxEventInRuby(&event);
            #endif
                  wxRbCallback *cb = (wxRbCallback *)event.m_callbackUserData;
                  bool ex_caught = false;
                  VALUE rc = wxRuby_Funcall(ex_caught, cb->m_func, call_id(), 1, rb_event);
                  if (ex_caught)
                  {
            #ifdef __WXRB_DEBUG__                
                    if (!rb_obj_is_kind_of(rc, rb_eSystemExit) && wxRuby_TraceLevel()>0)
                    {
                      wxRuby_PrintException(rc);
                    }
            #endif
                    wxRuby_ExitMainLoop(rc);
                  }
                }
            
                VALUE m_func;
                void* m_evh;
            };
  
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
            
            static void wxRuby_ReleaseEvtHandlerProc(void* evt_handler, wxRbCallback* proc_cb) 
            {        
              if (Evt_Handler_Handlers.count(evt_handler) != 0)
              {
                EvtHandlerProcList *ehpl = Evt_Handler_Handlers[evt_handler];
                for (EvtHandlerProcList::iterator itproc = ehpl->begin();
                     itproc != ehpl->end();
                     itproc++)
                {
                  if (proc_cb == (*itproc))
                  {
                    ehpl->erase(itproc);
                    return;
                  }
                }
              }
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

            static WxRuby_ID __wxrb_method_id("method");
            static WxRuby_ID __wxrb_try_before_id("try_before");
            static WxRuby_ID __wxrb_try_after_id("try_after");
            static WxRuby_ID __wxrb_source_location_id("source_location");

            WXRUBY_EXPORT bool wxRuby_IsNativeMethod(VALUE object, ID method_id)
            {
              return Qnil == rb_funcall(rb_funcall(object, __wxrb_method_id(), 1, ID2SYM(method_id)), 
                                        __wxrb_source_location_id(), 
                                        0);
            }
            __HEREDOC
          spec.add_header_code <<~__HEREDOC
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
                static WxRuby_ID call_id("call");
    
                bool ex_caught = false;
                VALUE rc;
                if (TYPE(m_rb_call) == T_ARRAY)
                {
                  VALUE proc = rb_ary_entry(m_rb_call, 0);
                  VALUE args = rb_ary_subseq(m_rb_call, 1, RARRAY_LEN(m_rb_call)-1);
                  rc = wxRuby_Funcall(ex_caught, proc, call_id(), args);
                }
                else
                {
                  rc = wxRuby_Funcall(ex_caught, m_rb_call, call_id(), (int)0);
                }
                if (ex_caught)
                {
            #ifdef __WXRB_DEBUG__                
                  if (!rb_obj_is_kind_of(rc, rb_eSystemExit) && wxRuby_TraceLevel()>0)
                  {
                    wxRuby_PrintException(rc);
                  }
            #endif
                  wxRuby_ExitMainLoop(rc);
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
              wxRbCallback* userData = new wxRbCallback(proc, (void *)$self);
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
              static WxRuby_ID event_type_for_name_id("event_type_for_name");

              wxEventType event_type;
            
              if ( TYPE(evtSpecifier) == T_FIXNUM ) // simply an Integer id
                event_type = NUM2INT(evtSpecifier);
              else if ( TYPE(evtSpecifier) == T_NIL ) // Not defined = any type
                event_type = wxEVT_NULL;
              else if ( TYPE(evtSpecifier) == T_SYMBOL ) // Symbol handler method
              {
                VALUE rb_evt_type = rb_funcall(wxRuby_GetSwigClassWxEvtHandler().klass, 
                                               event_type_for_name_id(),
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
              return rb_funcall(wxRuby_GetSwigClassWxEvtHandler().klass, 
                                rb_intern("send"), 
                                1, ID2SYM(rb_intern("get_event_type_class_map")), 0);
            }
            __HEREDOC
          spec.do_not_generate :typedefs, :variables, :enums, :defines, :functions
        end
      end

      def process(gendoc: false)
        defmod = super
        unless spec.module_name == 'wxEvtHandler'
          is_evt_handler = false
          spec.items.each do |citem|
            def_item = defmod.find_item(citem)
            if Extractor::ClassDef === def_item && spec.is_derived_from?(def_item, 'wxEvtHandler')
              spec.no_proxy "#{spec.class_name(citem)}::ProcessEvent"
              is_evt_handler = true
            end
          end
          # only once
          if is_evt_handler
            spec.add_header_code <<~__HEREDOC
              static WxRuby_ID __wxrb_try_before_id("try_before");
              static WxRuby_ID __wxrb_try_after_id("try_after");
              __HEREDOC
          end
        end
        defmod
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
