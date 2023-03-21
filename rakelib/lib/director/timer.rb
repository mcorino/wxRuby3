###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative './event_handler'

module WXRuby3

  class Director

    class Timer < EvtHandler

      def setup
        super
        spec.require_app 'wxTimer'
        # need a custom implementation to handle event handler proc cleanup
        spec.add_header_code <<~__HEREDOC
          class WXRubyTimer : public wxTimer
          {
          public:
            WXRubyTimer() : wxTimer() {}
            WXRubyTimer(wxEvtHandler *owner, int id=-1) : wxTimer(owner, id) {}
            virtual ~WXRubyTimer() 
            {
              wxRuby_ReleaseEvtHandlerProcs(this);
            }               
          };
        __HEREDOC
        spec.use_class_implementation 'wxTimer', 'WXRubyTimer'
        spec.do_not_generate(:variables, :enums, :defines, :functions)
      end
    end # class Timer

  end # class Director

end # module WXRuby3
