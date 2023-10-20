# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event'

module WXRuby3

  class Director

    class SashEvent < Event

      def setup
        super
        spec.disable_proxies
        # missing from interface docs
        spec.add_swig_code '%constant int EVT_SASH_DRAGGED_RANGE = wxEVT_SASH_DRAGGED;'
      end

      def doc_generator
        SashEventDocGenerator.new(self)
      end

    end # class SashEvent

  end # class Director

  class SashEventDocGenerator < DocGenerator

    protected def gen_constants_doc(fdoc)
      super
      xref_table = package.all_modules.reduce(DocGenerator.constants_db) { |db, mod| db[mod] }
      gen_constant_doc(fdoc, 'EVT_SASH_DRAGGED_RANGE', xref_table['EVT_SASH_DRAGGED'], '')
    end

  end

end # module WXRuby3
