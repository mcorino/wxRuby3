# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event'

module WXRuby3

  class Director

    class DialUpEvent < Event

      def setup
        super
        spec.disable_proxies
        # missing from interface docs
        spec.add_swig_code '%constant int EVT_DIALUP_CONNECTED = wxEVT_DIALUP_CONNECTED;'
        spec.add_swig_code '%constant int EVT_DIALUP_DISCONNECTED = wxEVT_DIALUP_DISCONNECTED;'
      end

      def doc_generator
        DialUpEventDocGenerator.new(self)
      end

    end # class DialupEvent

  end # class Director

  class DialUpEventDocGenerator < DocGenerator

    protected def gen_constants_doc(fdoc)
      super
      xref_table = package.all_modules.reduce(DocGenerator.constants_db) { |db, mod| db[mod] }
      gen_constant_doc(fdoc, 'EVT_DIALUP_CONNECTED', xref_table['EVT_DIALUP_CONNECTED'], 'connected event')
      gen_constant_doc(fdoc, 'EVT_DIALUP_DISCONNECTED', xref_table['EVT_DIALUP_DISCONNECTED'], 'disconnected event')
    end

  end

end # module WXRuby3
