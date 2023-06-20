###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class HTMLDataObject < Director

      include Typemap::DataFormat
      include Typemap::DataObjectData

      def setup
        super
        spec.gc_as_object
        # make sure the build scripts know that DataObjectSimple is part of the DataObject module
        spec.override_inheritance_chain('wxHTMLDataObject', {'wxDataObjectSimple' => 'wxDataObject'}, 'wxDataObject')
        # we only allow Ruby derivatives from wxDataObject but not of any of the C++ implemented
        # specializations
        spec.no_proxy 'wxHTMLDataObject'
        spec.add_swig_code <<~__HEREDOC
            // SWIG gets confused and doesn't realise that various virtual methods
            // from wxDataObject are implemented fully in this subclass, and so,
            // believing it to be abstract doesn't provide an allocator for this
            // class. This undocumented feature overrides this.
            %feature("notabstract") wxHTMLDataObject;
        __HEREDOC

      end

    end

  end

end
