###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class DataObject < Director

      include Typemap::DataFormat
      include Typemap::DataObjectData

      def setup
        super
        spec.items.concat %w[wxDataObjectSimple wxDataObjectComposite wxBitmapDataObject wxFileDataObject wxTextDataObject wxCustomDataObject wxImageDataObject wxURLDataObject]
        spec.gc_as_object

        # we only allow Ruby derivatives from wxDataObject but not of any of the C++ implemented
        # specializations
        %w[wxDataObjectSimple wxDataObjectComposite wxBitmapDataObject wxFileDataObject wxTextDataObject wxCustomDataObject wxImageDataObject wxURLDataObject].each do |kls|
          spec.no_proxy kls
        end

        # ignore the shortened 'convenience' forms
        spec.ignore 'wxDataObjectSimple::GetDataHere(void *) const'
        spec.ignore 'wxDataObjectSimple::SetData(size_t, const void *)'
        spec.ignore 'wxDataObjectSimple::GetDataSize() const'
        # ignore this as all derivatives have a fixed format
        spec.ignore 'wxDataObjectSimple::SetFormat'

        # ignore these as all fully implemented in derived and not useful in Ruby
        spec.ignore 'wxCustomDataObject::Alloc'
        spec.ignore 'wxCustomDataObject::Free'
        spec.ignore 'wxCustomDataObject::GetData'
        spec.ignore 'wxCustomDataObject::SetData'
        spec.ignore 'wxCustomDataObject::GetSize'
        spec.ignore 'wxCustomDataObject::TakeData'

        # all available in bases
        spec.ignore 'wxTextDataObject::GetFormatCount'
        spec.ignore 'wxTextDataObject::GetFormat'
        spec.ignore 'wxTextDataObject::GetAllFormats'

        %w[wxDataObjectComposite wxBitmapDataObject wxFileDataObject wxTextDataObject wxImageDataObject wxURLDataObject].each do |kls|
          spec.add_swig_code <<~__HEREDOC
            // SWIG gets confused and doesn't realise that various virtual methods
            // from wxDataObject are implemented fully in this subclass, and so,
            // believing it to be abstract doesn't provide an allocator for this
            // class. This undocumented feature overrides this.
            %feature("notabstract") #{kls};
            __HEREDOC
        end

        # Once a DataObject has been added, it belongs to the wxDataObjectComposite object,
        # and will be freed by it on destruction.
        spec.disown 'wxDataObjectSimple* dataObject'

        # Add GC management for the DataObjectSimple instances added to a DataObjectComposite instance.
        spec.add_header_code <<~__HEREDOC
          #include <vector>
          #include <map>

          typedef std::vector<VALUE> data_object_list_t;
          typedef std::map<wxDataObjectComposite*, data_object_list_t> composite_data_object_map_t;
          static composite_data_object_map_t CompositeDataObject_Map;

          static void wxRuby_markCompositeDataObjects()
          {
            composite_data_object_map_t::iterator it;
            for( it = CompositeDataObject_Map.begin(); it != CompositeDataObject_Map.end(); ++it )
            {
              data_object_list_t &do_list = it->second;
              for (VALUE data_obj : do_list)
              {
          #ifdef __WXRB_DEBUG__
                if (wxRuby_TraceLevel()>1)
                {
                  void *c_ptr = (TYPE(data_obj) == T_DATA ? DATA_PTR(data_obj) : 0);
                  std::wcout << "**** wxRuby_markCompositeDataObjects : " << it->first << "|" << (void*)c_ptr << std::endl;
                }
          #endif               
                rb_gc_mark(data_obj);
              }
            }
          }

          // custom implementation for wxRuby so we can handle de-registering composites
          class WxRuby_DataObjectComposite : public wxDataObjectComposite
          {
          public:
            WxRuby_DataObjectComposite() : wxDataObjectComposite() {}
            virtual ~WxRuby_DataObjectComposite()
            {
              CompositeDataObject_Map.erase(this);
            } 
          };

          #if wxUSE_RICHTEXT 
          #include <wx/richtext/richtextbuffer.h>
          #endif

          // Add custom object wrapper for DataObjectComposite#get_object result
          static VALUE wxRuby_WrapDataObjectSimple(wxDataObjectSimple* d_obj)
          {
            if (!d_obj)
              return Qnil;

            // check if we have this object tracked
            VALUE r_obj = SWIG_RubyInstanceFor(d_obj);
            if (r_obj != Qnil)
            {
              swig_class* sklass = (swig_class *) SWIGTYPE_p_wxDataObjectSimple->clientdata;
              if (rb_obj_is_kind_of(r_obj, sklass->klass))
                return r_obj; 
            }      
            
            // Otherwise check the returned type and create a new object wrapper
            void* do_ptr;
            if ((do_ptr = dynamic_cast<wxBitmapDataObject*> (d_obj)))
            {
              return SWIG_NewPointerObj(do_ptr, SWIGTYPE_p_wxBitmapDataObject, 0);
            }
            if ((do_ptr = dynamic_cast<wxImageDataObject*> (d_obj)))
            {
              return SWIG_NewPointerObj(do_ptr, SWIGTYPE_p_wxImageDataObject, 0);
            }
            if ((do_ptr = dynamic_cast<wxCustomDataObject*> (d_obj)))
            {
              return SWIG_NewPointerObj(do_ptr, SWIGTYPE_p_wxCustomDataObject, 0);
            }
            if ((do_ptr = dynamic_cast<wxFileDataObject*> (d_obj)))
            {
              return SWIG_NewPointerObj(do_ptr, SWIGTYPE_p_wxFileDataObject, 0);
            }
            if ((do_ptr = dynamic_cast<wxTextDataObject*> (d_obj)))
            {
              return SWIG_NewPointerObj(do_ptr, SWIGTYPE_p_wxTextDataObject, 0);
            }
          #if wxUSE_HTML
            if ((do_ptr = dynamic_cast<wxHTMLDataObject*> (d_obj)))
            {
              VALUE r_class = rb_eval_string("Wx::HTML::HTMLDataObject");
              swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(r_class);
              return SWIG_NewPointerObj(do_ptr, swig_type, 0);
            }
          #endif
          #if wxUSE_RICHTEXT 
            if ((do_ptr = dynamic_cast<wxRichTextBufferDataObject*> (d_obj)))
            {
              VALUE r_class = rb_eval_string("Wx::RTC::RichTextBufferDataObject");
              swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(r_class);
              return SWIG_NewPointerObj(do_ptr, swig_type, 0);
            }
          #endif
            return Qnil;
          }
          __HEREDOC
        # install GC marker
        spec.add_init_code 'wxRuby_AppendMarker(wxRuby_markCompositeDataObjects);'
        # use custom implementation class
        spec.use_class_implementation 'wxDataObjectComposite', 'WxRuby_DataObjectComposite'

        # make sure to return the right derived type
        spec.map 'wxDataObjectSimple*' => 'Wx::DataObjectSimple' do
          map_out code: '$result = wxRuby_WrapDataObjectSimple($1);'
        end

        # disable generating the default Add method (keep docs)
        spec.ignore 'wxDataObjectComposite::Add', ignore_doc: false
        # Add custom Add implementation
        spec.add_extend_code 'wxDataObjectComposite', <<~__HEREDOC
          void add(VALUE rb_dataObject, bool preferred=false)
          {
            // convert simple object
            wxDataObjectSimple *simple_do;
            int res = SWIG_ConvertPtr(rb_dataObject, SWIG_as_voidptrptr(&simple_do), SWIGTYPE_p_wxDataObjectSimple, SWIG_POINTER_DISOWN);
            if (!SWIG_IsOK(res)) 
            {
              rb_raise(rb_eArgError, "Expected Wx::DataObjectSimple for 1");
            }

            // add new simple instance to registration for this composite
            CompositeDataObject_Map[$self].push_back(rb_dataObject);

            // add to composite
            $self->Add(simple_do);
          }
          __HEREDOC

      end
    end # class DataObject

    def doc_generator
      DataObjectDocGenerator.new(self)
    end

  end # class Director

  class DataObjectDocGenerator < DocGenerator

    def get_class_doc(clsdef)
      if clsdef.name == 'wxDataObjectSimple'
        []
      else
        super
      end
    end
    protected :get_class_doc

    def get_method_doc(mtd)
      if Extractor::MethodDef === mtd && mtd.class_name == 'wxDataObject' && mtd.name == 'GetDataSize'
        {}
      else
        super
      end
    end
    protected :get_method_doc

  end

end # module WXRuby3
