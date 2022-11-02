#--------------------------------------------------------------------
# @file    log.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class Log < Director

      def setup
        spec.gc_as_object
        spec.items.concat(%w[wxLogBuffer wxLogChain wxLogGui wxLogStderr wxLogStream wxLogTextCtrl wxLogInterposer wxLogInterposerTemp wxLogWindow])
        spec.no_proxy(%w[wxLogBuffer wxLogGui wxLogWindow])
        spec.ignore 'wxLog::SetThreadActiveTarget'
        spec.disown 'wxLog *logtarget'
        spec.do_not_generate(:functions)
        spec.make_concrete('wxLog')
        spec.extend_interface('wxLog', '  virtual ~wxLog ();')
        super
      end
    end # class Log

  end # class Director

end # module WXRuby3
