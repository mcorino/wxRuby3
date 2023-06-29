###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class RichTextBufferDataObject < Director

      include Typemap::DataFormat
      include Typemap::DataObjectData

      def setup
        super
        spec.gc_as_object
        # make sure the build scripts know that DataObjectSimple is part of the DataObject module
        spec.override_inheritance_chain('wxRichTextBufferDataObject', {'wxDataObjectSimple' => 'wxDataObject'}, 'wxDataObject')
        # we only allow Ruby derivatives from wxDataObject but not of any of the C++ implemented
        # specializations
        spec.no_proxy 'wxRichTextBufferDataObject'
        # SWIG gets confused and doesn't realise that various virtual methods
        # from wxDataObject are implemented fully in this subclass, and so,
        # believing it to be abstract doesn't provide an allocator for this
        # class. This overrides this.
        spec.make_concrete 'wxRichTextBufferDataObject'

        # ignore overrrides (will be available through base class)
        spec.ignore 'wxRichTextBufferDataObject::GetPreferredFormat'
        spec.ignore 'wxRichTextBufferDataObject::GetDataSize'
        spec.ignore 'wxRichTextBufferDataObject::GetDataHere'
        spec.ignore 'wxRichTextBufferDataObject::SetData'

        spec.new_object 'wxRichTextBufferDataObject::GetRichTextBuffer'
        spec.do_not_generate :variables, :defines, :functions, :enums
      end

    end

  end

end
