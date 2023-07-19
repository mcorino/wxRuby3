###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class Log < Director

      def setup
        spec.gc_as_object
        spec.items.concat(%w[wxLogBuffer wxLogChain wxLogGui wxLogStderr wxLogStream wxLogTextCtrl wxLogInterposer wxLogInterposerTemp wxLogWindow wxLogNull wxLogRecordInfo])
        spec.no_proxy(%w[wxLogBuffer wxLogChain wxLogGui wxLogStderr wxLogTextCtrl wxLogInterposer wxLogInterposerTemp wxLogWindow])
        spec.regard %w[wxLog::DoLogRecord wxLog::DoLogTextAtLevel wxLog::DoLogText]
        spec.ignore 'wxLogBuffer::Flush'
        spec.ignore 'wxLogGui::Flush'
        if Config.instance.features_set?(%w[wxUSE_STD_IOSTREAM])
          spec.ignore 'wxLogStream'
        end
        spec.ignore 'wxLog::SetThreadActiveTarget'
        spec.disown 'wxLog *logtarget'
        spec.new_object 'wxLog::SetActiveTarget'
        spec.do_not_generate(:functions)
        spec.make_concrete('wxLog')
        spec.extend_interface('wxLog', 'virtual ~wxLog ();')
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
