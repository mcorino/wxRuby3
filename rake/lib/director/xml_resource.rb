###
# wxRuby3 wxWidgets interface director
# Copyright (c) M.J.N. Corino, The Netherlands
###

module WXRuby3

  class Director

    class XmlResource < Director

      def setup
        super
        # use XRC handlers as is in Ruby
        spec.ignore %w[wxXmlResource::AddHandler wxXmlResource::ClearHandlers wxXmlResource::InsertHandler]
        # not really added value; will add alternative allowing more flexibility (see below)
        spec.ignore 'wxXmlResource::LoadDocument(wxXmlDocument *, const wxString &)'
        # For these three methods, there are two variants in wxWidgets. One loads an
        # XRC from scratch and returns an instance of a core Wx class
        # (Wx::Dialog, Wx::Frame, or Wx::Panel). The other loads a layout into
        # an already existing instance of one of these classes, which may be a
        # custom ruby subclass containing extended methods etc. These two types
        # are disambiguated below.
        spec.rename_for_ruby 'LoadDialogSubclass' => 'wxXmlResource::LoadDialog(wxDialog *, wxWindow *, const wxString &)',
                             'LoadPanelSubclass' => 'wxXmlResource::LoadPanel(wxPanel *, wxWindow *, const wxString &)',
                             'LoadFrameSubclass'=> 'wxXmlResource::LoadFrame(wxFrame *, wxWindow *, const wxString &)'
        # XmlResource is an exception to the general rule in typemap.i - it has
        # methods which accept a 'wxWindow* parent' argument which may be
        # null. The common typemap checks if the parent is NULL, but Dialogs
        # and Frames may have NULL (Ruby:nil) parents as created by XmlResource
        # LoadDialog and LoadFrame methods. So we disable that part of the
        # checking for all methods (including those which would ideally retain
        # it - eg LoadPanel - b/c no way to apply a typemap based on method
        # name in SWIG, but we will fix that with some pure Ruby overrides)
        spec.map 'wxWindow* parent' => 'Wx::Window' do
          map_check code: <<~__CODE
            if ( ! rb_const_defined(wxRuby_Core(), rb_intern("THE_APP") ) )
            { 
              rb_raise(rb_eRuntimeError,
                       "Cannot create a Window before App.main_loop has been called");
            }
          __CODE
        end
        spec.make_enum_untyped 'wxXmlResourceFlags'
        # ignore this but not it's docs; will add special wrapper implementation (see below)
        spec.ignore 'wxXmlResource::AddSubclassFactory', ignore_doc: false
        spec.add_header_code 'static VALUE WxRuby_XmlSubclassFactory_klass;'
        spec.add_extend_code 'wxXmlResource', <<~__HEREDOC
          static void AddSubclassFactory(VALUE factory)
          {
            void *pfactory = 0;
            if (TYPE(factory) != T_DATA || !rb_obj_is_kind_of(factory, WxRuby_XmlSubclassFactory_klass))
            {
              rb_raise(rb_eArgError, "expected Wx::XmlSubclassFactory for argument 1"); return;
            }
            RDATA(factory)->dfree = 0; // wxWidgets will take over management 
            Data_Get_Struct(factory, void, pfactory);
            wxXmlResource::AddSubclassFactory(reinterpret_cast< wxXmlSubclassFactory * >(pfactory));
          }
          __HEREDOC
        spec.add_wrapper_code <<~__HEREDOC
          // Custom director-like class for XmlSubclassFactory
          class WxRuby_XmlSubclassFactory : public wxXmlSubclassFactory
          {
          public:
            WxRuby_XmlSubclassFactory(VALUE self) : wxXmlSubclassFactory(), self_(self) {}
            virtual wxObject *Create(wxString const &className);
            virtual ~WxRuby_XmlSubclassFactory();

          private:
            VALUE self_;
          };

          wxObject *WxRuby_XmlSubclassFactory::Create(wxString const &className)
          {
            wxObject *c_result ;
            VALUE rb_classname = Qnil ;
            VALUE SWIGUNUSED result;
            void *result_ptr;
            
            ID create_id = rb_intern("create");
            if (rb_respond_to(this->self_, create_id))
            {
              rb_classname = WXSTR_TO_RSTR(className);
              result = rb_funcall(this->self_, create_id, 1, rb_classname);
              if (result != Qnil)
              {
                if (TYPE(result) != T_DATA || !rb_obj_is_kind_of(result, ((swig_class *) (SWIGTYPE_p_wxObject->clientdata))->klass))
                {
                  Swig::DirectorTypeMismatchException::raise(rb_eTypeError, "in output value of type '""wxObject *""'");
                }
                Data_Get_Struct(result, void, result_ptr);
                RDATA(result)->dfree = 0; // disown
                // the returned wxObject's should be Window objects which are always managed by wxWidgets after creation
                // so no need to own anything anymore
                c_result = reinterpret_cast< wxObject * >(result_ptr);
                return c_result;
              }
            }
            return 0;
          }  

          WxRuby_XmlSubclassFactory::~WxRuby_XmlSubclassFactory()
          {
            DATA_PTR(this->self_) = 0; // unlink
          }

          SWIGINTERN void
          WxRuby_XmlSubclassFactory_free(void *self) 
          {
            wxXmlSubclassFactory *arg1 = (wxXmlSubclassFactory *)self;
            delete arg1;
          }

          SWIGINTERN VALUE
          #ifdef HAVE_RB_DEFINE_ALLOC_FUNC
          WxRuby_XmlSubclassFactory_allocate(VALUE self)
          #else
          WxRuby_XmlSubclassFactory_allocate(int argc, VALUE *argv, VALUE self)
          #endif
          {
            VALUE obj;
            obj = Data_Wrap_Struct(self, 0, WxRuby_XmlSubclassFactory_free, 0);
            WxRuby_XmlSubclassFactory *pfactory = new WxRuby_XmlSubclassFactory(obj); 
            DATA_PTR(obj) = pfactory;
          #ifndef HAVE_RB_DEFINE_ALLOC_FUNC
            rb_obj_call_init(obj, argc, argv);
          #endif
            return obj;
          }
          __HEREDOC
        spec.add_init_code <<~__HEREDOC
          WxRuby_XmlSubclassFactory_klass = rb_define_class_under(mWxXmlResource, "XmlSubclassFactory", rb_cObject);
          rb_define_alloc_func(WxRuby_XmlSubclassFactory_klass, WxRuby_XmlSubclassFactory_allocate);
          __HEREDOC
      end
    end # class XmlResource

  end # class Director

end # module WXRuby3
