###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class Clipboard < Director

      include Typemap::DataFormat

      def setup
        super
        spec.gc_as_untracked # don't even track Clipboard objects
        # there is no need or support for clipboard derivatives
        # not least because wxRuby only ever allows a single global clipboard
        spec.disable_proxies
        spec.make_abstract 'wxClipboard'
        # After a data object has been set to the clipboard using set_data, it
        # becomes owned by the clipboard and shouldn't be freed
        spec.disown 'wxDataObject* data'
        spec.add_extend_code 'wxClipboard', <<~__HEREDOC
          // Provide access to the global clipboard; same clipboard must be used
          // between calls to do data transfer properly.
          static VALUE get_global_clipboard() 
          {
            return SWIG_NewPointerObj(wxTheClipboard, SWIGTYPE_p_wxClipboard, 0);
          }
          __HEREDOC
      end
    end # class Clipboard

  end # class Director

end # module WXRuby3
