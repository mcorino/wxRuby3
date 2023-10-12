# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class RichTextObject < Director

      include Typemap::RichText

      def setup
        super
        spec.swig_import 'swig/classes/include/wxTextAttr.h'
        if spec.module_name == 'wxRichTextObject'
          spec.items.concat %w[
            wxRichTextPlainText
            wxRichTextDrawingContext
            wxRichTextAttr
            wxTextBoxAttr
            wxTextAttrDimension
            wxTextAttrDimensions
            wxTextAttrShadow
            wxTextAttrBorder
            wxTextAttrBorders
            wxTextAttrSize
            wxRichTextSelection
            wxRichTextProperties
          ]
          spec.disable_proxies
          spec.gc_as_untracked 'wxRichTextObject',
                               'wxRichTextPlainText'
          spec.add_swig_code '%feature("freefunc") wxRichTextObject "GC_RichTextObjectFreeFunc";'
          spec.gc_as_untracked 'wxRichTextDrawingContext',
                               'wxRichTextAttr',
                               'wxTextBoxAttr',
                               'wxTextAttrDimension',
                               'wxTextAttrDimensions',
                               'wxTextAttrShadow',
                               'wxTextAttrBorder',
                               'wxTextAttrBorders',
                               'wxTextAttrSize',
                               'wxRichTextSelection',
                               'wxRichTextProperties'
          spec.add_header_code <<~__HEREDOC
            extern void GC_RichTextObjectFreeFunc(void* ptr)
            {
              SWIG_RubyRemoveTracking(ptr);
              if (ptr)
              {
            #ifdef __WXRB_DEBUG__
                if (wxRuby_TraceLevel()>1)
                  std::wcout << "GC_RichTextObjectFreeFunc(" << ptr << ")" << std::endl;
            #endif
                ((wxRichTextObject*)ptr)->Dereference();            
              } 
            }
            __HEREDOC
          spec.make_abstract 'wxRichTextObject'
          spec.add_header_code <<~__HEREDOC
            extern VALUE wxRuby_RichTextObject2Ruby(const wxRichTextObject *wx_rto, int own)
            {
                // If no object was passed to be wrapped.
                if ( ! wx_rto )
                  return Qnil;
  
                // Get the wx class and the ruby class we are converting into
                wxString class_name( wx_rto->GetClassInfo()->GetClassName() );
                wxCharBuffer wx_classname = class_name.mb_str();
                VALUE r_class_name = rb_intern(wx_classname.data () + 2);
                VALUE r_class = Qnil;
              
                if ( class_name.Len() > 2 )
                {
                  // lookup the class in the RichText module
                  if (rb_const_defined(mWxRTC, r_class_name))
                    r_class = rb_const_get(mWxRTC, r_class_name);
                }
  
                // Handle classes (currently) unknown in wxRuby.
                if ( NIL_P(r_class) )
                {
                  rb_warn("Error wrapping object; class '%s' is not (yet) supported in wxRuby",
                          (const char *)class_name.mb_str());
                  return Qnil;
                }
              
                // Otherwise, retrieve the swig type info for this class and wrap it
                // in Ruby. wxRuby_GetSwigTypeForClass is defined in wx.i
                swig_type_info* swig_type = wxRuby_GetSwigTypeForClass(r_class);
                VALUE rb_rto = SWIG_NewPointerObj(const_cast<wxRichTextObject*> (wx_rto), swig_type, own);
                return rb_rto;
            }
            __HEREDOC
          spec.ignore(%w[wxRICHTEXT_ALL wxRICHTEXT_NONE wxRICHTEXT_NO_SELECTION])
          # special typemap for const wxChar wxRichTextLineBreakChar;
          spec.add_swig_code <<~__HEREDOC
            %typemap(constcode,noblock=1) const wxChar {
              %set_constant("$symname", rb_str_new2((const char *)wxString($value).utf8_str()));
            }
            __HEREDOC
          spec.new_object 'wxRichTextObject::DoSplit',
                          'wxRichTextObject::Clone'
          # for wxRichTextObject::GetRangeSize
          spec.map 'int & descent', as: 'Integer' do

            map_in temp: 'int tmp', code: 'tmp = NUM2INT($input); $1 = &tmp;'

            map_argout code: '$result = SWIG_Ruby_AppendOutput($result, INT2NUM(tmp$argnum));'

            map_directorin code: '$input = INT2NUM($1);'

            map_directorargout code: <<~__CODE
              if(output != Qnil)
              {
                $1 = NUM2INT(output);
              }
              else
              {
                $1 = 0;
              }
              __CODE

          end
          spec.map_apply 'int * OUTPUT' => ['int * height',
                                            'int &leftMargin', 'int &rightMargin', 'int &topMargin', 'int &bottomMargin']
          spec.map 'wxTextOutputStream &' => 'IO,Wx::OutputStream' do

            add_header_code <<~__CODE
              WXRUBY_EXPORT bool wxRuby_IsOutputStream(VALUE);
              WXRUBY_EXPORT bool wxRuby_IsCompatibleOutput(VALUE rbos);
              WXRUBY_EXPORT wxOutputStream* wxRuby_RubyToOutputStream(VALUE);
              WXRUBY_EXPORT VALUE wxRuby_RubyFromOutputStream(wxOutputStream&);
  
              // Allows a ruby IO-like object to be used as a wxOutputStream
              class WXRUBY_EXPORT wxRubyOutputStream : public wxOutputStream
              {
              public:
                // Initialize with the writeable ruby IO-like object
                wxRubyOutputStream(VALUE rb_io);
                virtual ~wxRubyOutputStream(); 
            
                wxFileOffset GetLength() const wxOVERRIDE;
              
                void Sync() wxOVERRIDE;
                bool Close() wxOVERRIDE; 
                bool Ok() const { return IsOk(); }
                bool IsOk() const wxOVERRIDE;
                bool IsSeekable() const wxOVERRIDE;
  
                VALUE GetRubyIO () { return m_rbio; }
              
              protected:
                size_t OnSysWrite(const void *buffer, size_t size) wxOVERRIDE; 
                wxFileOffset OnSysSeek(wxFileOffset seek, wxSeekMode mode) wxOVERRIDE;
                wxFileOffset OnSysTell() const wxOVERRIDE;
  
                VALUE m_rbio; // Wrapped ruby object
                bool m_isIO;
                bool m_isSeekable;
              };
              __CODE

            map_in temp: 'std::unique_ptr<wxRubyOutputStream> tmp_ros, std::unique_ptr<wxTextOutputStream> tmp_tos',
                   code: <<~__CODE
              if (wxRuby_IsCompatibleOutput($input))
              {
                tmp_ros = std::make_unique<wxRubyOutputStream>($input); 
                tmp_tos = std::make_unique<wxTextOutputStream>(*tmp_ros.get());
                $1 = tmp_tos.get();
              }
              else
              {
                wxOutputStream* wx_os = wxRuby_RubyToOutputStream($input);
                if (!wx_os)
                {
                  rb_raise(rb_eArgError, "Invalid value for %d expected IO(-like) or Wx::OutputStream", $argnum-1);
                }
                tmp_tos = std::make_unique<wxTextOutputStream>(*wx_os);
                $1 = tmp_tos.get();
              }
              __CODE
          end
          spec.map 'wxRichTextAttrArray & attributes' => 'Array' do

            map_in temp: 'wxRichTextAttrArray arr, VALUE rb_arr', code: <<~__CODE
            if (TYPE($input) == T_ARRAY)
            {
              $1 = &arr;
              rb_arr = $input;
            }
            else
            {
              rb_raise(rb_eArgError, "Expected an Array for %d", $argnum-1);
            }
            __CODE

            map_argout by_ref: true, code: <<~__CODE
            for (size_t i=0; i<arr$argnum.GetCount() ;++i)
            {
              wxRichTextAttr* wx_rta = new wxRichTextAttr(arr$argnum.Item(i));
              rb_ary_push(rb_arr$argnum, SWIG_NewPointerObj(SWIG_as_voidptr(wx_rta), SWIGTYPE_p_wxRichTextAttr, SWIG_POINTER_OWN));
            }
            __CODE

          end
          spec.ignore 'wxRichTextSelection::operator[]'
          spec.ignore 'wxRichTextProperties::SetProperty(const wxString &,const wxChar *)',
                      'wxRichTextProperties::operator[]'
          spec.map 'const wxRichTextVariantArray &' => 'Array<Wx::Variant>' do
            map_in temp: 'wxRichTextVariantArray tmp', code: <<~__CODE
              if (($input == Qnil) || (TYPE($input) != T_ARRAY))
              {
                rb_raise(rb_eArgError, "Expected an Array of Wx::Variant for %d", $argnum-1);
              }
              else
              {
                for (int i = 0; i < RARRAY_LEN($input); ++i)
                {
                  void *ptr;
                  VALUE var = rb_ary_entry($input, i);
                  int res = SWIG_ConvertPtr(var, &ptr, SWIGTYPE_p_wxVariant,  0 );
                  if (!SWIG_IsOK(res)) {
                    rb_raise(rb_eArgError, "Expected an Array of Wx::Variant for %d", $argnum-1);
                  }
                  tmp.Add(*static_cast<wxVariant*>(ptr));
                }
                $1 = &tmp;
              }
              __CODE
            map_out code: <<~__CODE
              $result = rb_ary_new();
              for (size_t i = 0; i < $1->Count(); ++i)
              {
                wxVariant *var = &(*$1)[i];
                rb_ary_push($result, SWIG_NewPointerObj(SWIG_as_voidptr(var), SWIGTYPE_p_wxVariant, 0));
              }
              __CODE
            map_typecheck precedence: 'OBJECT_ARRAY', code: '$1 = TYPE($input) == T_ARRAY;'
          end
          spec.do_not_generate(:functions)
        else
          spec.add_header_code 'extern VALUE wxRuby_RichTextObject2Ruby(const wxRichTextObject *wx_rto, int own);'
        end
      end

      def process(gendoc: false)
        defmod = super
        unless spec.module_name == 'wxRichTextObject'
          spec.add_header_code 'extern void GC_RichTextObjectFreeFunc(void* ptr);'
          spec.items.each do |citem|
            def_item = defmod.find_item(citem)
            if Extractor::ClassDef === def_item && def_item.is_derived_from?('wxRichTextObject')
              spec.no_proxy def_item.name
              spec.gc_as_untracked def_item.name
              spec.add_swig_code %Q{%feature("freefunc") #{def_item.name} "GC_RichTextObjectFreeFunc";}
            end
          end
        end
        defmod
      end

    end

  end

end
