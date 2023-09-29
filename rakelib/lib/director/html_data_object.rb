# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
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
        # SWIG gets confused and doesn't realise that various virtual methods
        # from wxDataObject are implemented fully in this subclass, and so,
        # believing it to be abstract doesn't provide an allocator for this
        # class. This overrides this.
        spec.make_concrete 'wxHTMLDataObject'

      end

    end

  end

end
