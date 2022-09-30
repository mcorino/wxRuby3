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
        spec.do_not_generate(:functions)
        spec.make_concrete('wxLog')
        spec.extend_class('wxLog', '  virtual ~wxLog ();')
        super
      end
    end # class Log

  end # class Director

end # module WXRuby3
