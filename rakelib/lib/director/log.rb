# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Log < Director

      def setup
        spec.gc_as_object %w[wxLog wxLogChain wxLogInterposer wxLogWindow]
        spec.items.concat(%w[wxLogBuffer wxLogChain wxLogGui wxLogStderr wxLogStream wxLogTextCtrl wxLogInterposer wxLogWindow wxLogNull wxLogRecordInfo])
        spec.no_proxy(%w[wxLogBuffer wxLogGui wxLogStderr wxLogTextCtrl wxLogWindow])
        spec.force_proxy(%w[wxLogInterposer])
        spec.ignore 'wxLog::SetFormatter'
        spec.regard %w[wxLog::DoLogRecord wxLog::DoLogTextAtLevel wxLog::DoLogText]
        spec.ignore 'wxLogBuffer::Flush'
        spec.ignore 'wxLogGui::Flush'
        if Config.instance.features_set?('wxUSE_STD_IOSTREAM')
          spec.ignore 'wxLogStream'
        end
        # wxLogStderr
        spec.ignore 'wxLogStderr::wxLogStderr'
        spec.add_extend_code 'wxLogStderr', <<~__HEREDOC
          wxLogStderr(int fh=2)
          {
            if (fh == 2)
            { return new wxLogStderr(); }
            else if (fh == 1)
            { return new wxLogStderr(stdout); }
            rb_raise(rb_eArgError, "Expected 1 (for stdout) or 2 (for stderr).");
          }
          __HEREDOC

        # for wxLogChain

        # In C++ wxLogChain releases it's redirection chain when destructed.
        # In wxRuby this does not work as expected as GC collection cannot be exactly predicted.
        # Therefor extend the class here with an explicit 'release' method.
        spec.add_extend_code 'wxLogChain', <<~__CODE
          void release()
          {
            wxLog::SetActiveTarget($self->GetOldLog());
            $self->DetachOldLog();
            // Make Ruby own the object again so it will be deleted when GC collected 
            VALUE rb_self = SWIG_RubyInstanceFor($self);
            if (!NIL_P(rb_self))
            {
              swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(CLASS_OF(rb_self));
              RDATA(rb_self)->dfree = ((swig_class *)swig_type->clientdata)->destroy;
            }
          }
          __CODE
        # In this case we have a mix of C++ marking and Ruby caching to manage GC collection.
        # The 'Old Log' reference is managed from C++ as it is captured and accessible there.
        # The 'New Log' reference is cached in Ruby as the LogChain class does not provide
        # access to this after setting (private member).
        spec.add_header_code <<~__HEREDOC
          static void GC_mark_wxLogChain(void* ptr)
          {
            if (ptr )
            {
              wxLogChain* logChain = reinterpret_cast<wxLogChain*> (ptr);
              wxLog* oldLog = logChain->GetOldLog();
              VALUE rb_old_log = SWIG_RubyInstanceFor(oldLog);
              if (!NIL_P(rb_old_log))
              {
                rb_gc_mark(rb_old_log);
              } 
            } 
          }
          __HEREDOC
        spec.add_swig_code '%markfunc wxLogChain "GC_mark_wxLogChain";',
                           '%markfunc wxLogInterposer "GC_mark_wxLogChain";',
                           '%markfunc wxLogWindow "GC_mark_wxLogChain";'
        spec.disown 'wxLog *logger'
        spec.ignore 'wxLogChain::DetachOldLog' # too much potential trouble
        # add override decl missing from xml specs
        spec.extend_interface 'wxLogChain',
                              'virtual void DoLogRecord(wxLogLevel level, const wxString& msg, const wxLogRecordInfo& info) override',
                              visibility: 'protected'
        # wxLogChain and derivatives need to be allocated disowned because new instances of these classes
        # are installed as ActiveTarget on construction and so wxWidgets has ownership
        spec.allocate_disowned 'wxLogChain'
        spec.allocate_disowned 'wxLogInterposer'
        spec.allocate_disowned 'wxLogWindow'

        # for ActiveTarget methods
        spec.ignore 'wxLog::SetThreadActiveTarget'
        spec.disown 'wxLog *logtarget'
        spec.new_object 'wxLog::SetActiveTarget'
        spec.do_not_generate(:functions)
        spec.make_concrete('wxLog')
        spec.extend_interface('wxLog', 'virtual ~wxLog ()')
        spec.gc_as_untracked 'wxLogRecordInfo'
        spec.add_extend_code 'wxLogRecordInfo', <<~__HEREDOC
          VALUE filename()
          {
            return $self->filename ? WXSTR_TO_RSTR(wxString($self->filename)) : Qnil;
          }
          VALUE line()
          {
            return INT2NUM($self->line);
          }
          VALUE func()
          {
            return $self->func ? WXSTR_TO_RSTR(wxString($self->func)) : Qnil;
          }
          VALUE component()
          {
            return $self->component ? WXSTR_TO_RSTR(wxString($self->component)) : Qnil;
          }
          __HEREDOC
        spec.make_abstract 'wxLogNull'
        spec.ignore 'wxLogNull::wxLogNull'
        spec.add_extend_code 'wxLogNull', <<~__HEREDOC__
          static void no_log()
          {
            if (rb_block_given_p ())
            {
              wxLogNull noLog;
              rb_yield(Qnil);
            }
          }
          __HEREDOC__
        super
      end
    end # class Log

  end # class Director

end # module WXRuby3
