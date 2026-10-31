# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
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
        # unwanted in Ruby
        spec.ignore 'wxXmlResource::LoadObject',
                    'wxXmlResource::LoadObjectRecursively'
        # unattached loaders return owned objects
        spec.new_object 'wxXmlResource::LoadMenu(const wxString &)',
                        'wxXmlResource::LoadMenuBar(const wxString &)'
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
            if ( !wxRuby_IsAppRunning() )
            { 
              rb_raise(rb_eRuntimeError,
                       "Cannot create a Window before App.main_loop has been called");
            }
          __CODE
        end
        # ignore this but not it's docs; will add special wrapper implementation (see below)
        spec.ignore 'wxXmlResource::AddSubclassFactory', ignore_doc: false
        spec.add_header_code 'static VALUE WxRuby_XmlSubclassFactory_klass;'
        spec.add_extend_code 'wxXmlResource', <<~__HEREDOC
          static void AddSubclassFactory(VALUE factory)
          {
            void *pfactory = 0;
            if (!WXRUBY_HAS_WRAPPED_DATA(factory) || !rb_obj_is_kind_of(factory, WxRuby_XmlSubclassFactory_klass))
            {
              rb_raise(rb_eArgError, "expected Wx::XmlSubclassFactory for argument 1"); return;
            }
            WXRUBY_WRAPPER_DATA_DFREE_RESET(factory); // wxWidgets will take over management 
            pfactory = WXRUBY_WRAPPER_DATA_PTR(factory);
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
            static WxRuby_ID create_id("create");

            wxObject *c_result ;
            VALUE rb_classname = Qnil ;
            VALUE SWIGUNUSED result;
            void *result_ptr;
            
            if (rb_respond_to(this->self_, create_id()))
            {
              rb_classname = WXSTR_TO_RSTR(className);
              result = rb_funcall(this->self_, create_id(), 1, rb_classname);
              if (result != Qnil)
              {
                if (!WXRUBY_HAS_WRAPPED_DATA(result) || !rb_obj_is_kind_of(result, ((swig_class *) (SWIGTYPE_p_wxObject->clientdata))->klass))
                {
                  Swig::DirectorTypeMismatchException::raise(rb_eTypeError, "in output value of type '""wxObject *""'");
                }
                result_ptr = WXRUBY_WRAPPER_DATA_PTR(result);
                WXRUBY_WRAPPER_DATA_DFREE_RESET(result); // disown
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
            WXRUBY_WRAPPER_DATA_PTR_RESET(this->self_); // unlink
          }

          SWIGINTERN void
          WxRuby_XmlSubclassFactory_free(void *self) 
          {
            wxXmlSubclassFactory *arg1 = (wxXmlSubclassFactory *)self;
            delete arg1;
          }

          #ifdef WXRUBY_SWIG_TYPED_DATA
 
          static const rb_data_type_t wxruby_subclass_factory_data_type = {
            "C++ WxRuby_XmlSubclassFactory",
          #if RUBY_API_VERSION_MAJOR >= 3
            { SWIG_Ruby_mark_swig_type, SWIG_Ruby_free_swig_type, 0, 0, {}},
          #else
            { SWIG_Ruby_mark_swig_type, SWIG_Ruby_free_swig_type, 0, {}},
          #endif
            0, 0
          #ifdef RUBY_TYPED_FREE_IMMEDIATELY
            , SWIG_RUBY_TYPED_DATA_FLAGS
          #endif
          };

          #endif

          SWIGINTERN VALUE
          #ifdef HAVE_RB_DEFINE_ALLOC_FUNC
          WxRuby_XmlSubclassFactory_allocate(VALUE self)
          #else
          WxRuby_XmlSubclassFactory_allocate(int argc, VALUE *argv, VALUE self)
          #endif
          {
            VALUE obj;
          #ifdef WXRUBY_SWIG_UNTYPED_DATA
            obj = Data_Wrap_Struct(self, 0, WxRuby_XmlSubclassFactory_free, 0);
          #else
            struct swig_ruby_wrapped_object *wrobj;
            obj = TypedData_Make_Struct(self, struct swig_ruby_wrapped_object, &wxruby_subclass_factory_data_type, wrobj);
            wrobj->data = 0;
            wrobj->dfree = WxRuby_XmlSubclassFactory_free;
          #endif
            rb_iv_set(obj, "@__swigtype__", rb_str_new2("XmlSubclassFactory"));
            WxRuby_XmlSubclassFactory *pfactory = new WxRuby_XmlSubclassFactory(obj); 
            WXRUBY_WRAPPER_DATA_PTR_SET(obj, pfactory);
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
