# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class SplitterWindow < Window

      def setup
        spec.rename_for_ruby('Init' => 'wxSplitterWindow::Initialize')
        # this reimplemented window base method need to be properly wrapped but
        # is missing from the XML docs
        spec.extend_interface('wxSplitterWindow', 'virtual void OnInternalIdle()')
        super
        # fix naming mismatch with #evt_splitter_dclick
        spec.add_swig_code '%constant int EVT_SPLITTER_DCLICK = wxEVT_SPLITTER_DOUBLECLICKED;'
      end

      def doc_generator
        SplitterWindowDocGenerator.new(self)
      end

    end # class SplitterWindow

  end # class Director

  class SplitterWindowDocGenerator < DocGenerator

    protected def gen_constants_doc(fdoc)
      super
      xref_table = package.all_modules.reduce(DocGenerator.constants_db) { |db, mod| db[mod] }
      gen_constant_doc(fdoc, 'EVT_SPLITTER_DCLICK', xref_table['EVT_SPLITTER_DOUBLECLICKED'], 'wxRuby specific alias for Wx::EVT_SPLITTER_DOUBLECLICKED')
    end

  end

end # module WXRuby3
