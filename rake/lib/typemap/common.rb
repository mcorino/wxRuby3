###
# wxRuby3 Common typemap definitions
# Copyright (c) M.J.N. Corino, The Netherlands
###

require_relative '../core/mapping'

module WXRuby3

  module Typemap

    # initialize common basic mappings for std type typedefs
    register_std_typedef('wxLongLong_t', 'long long')
    register_std_typedef('wxULongLong_t', 'unsigned long long')
    register_std_typedef('wxInt8', 'signed char')
    register_std_typedef('wxUint8', 'unsigned char')
    register_std_typedef('wxByte', 'unsigned char')
    register_std_typedef('wxInt16', 'signed short')
    register_std_typedef('wxUint16', 'unsigned short')
    register_std_typedef('wxWord', 'unsigned short')
    register_std_typedef('wxChar16', 'unsigned short')
    register_std_typedef('wxInt32', 'int')
    register_std_typedef('wxUint32', 'unsigned int')
    register_std_typedef('wxDword', 'unsigned int')
    register_std_typedef('wxChar32', 'unsigned int')
    register_std_typedef('wxInt64', 'long long')
    register_std_typedef('wxUint64', 'unsigned long long')
    register_std_typedef('wxInt64', 'long long')
    register_std_typedef('wxIntPtr', 'ssize_t')
    register_std_typedef('wxUIntPtr', 'size_t')
    register_std_typedef('wxPrintQuality', 'int')
    register_std_typedef('wxCoord', 'int')
    register_std_typedef('wxFloat32', 'float')
    register_std_typedef('wxFloat64', 'double')
    register_std_typedef('wxDouble', 'double')
    register_std_typedef('wxWindowID', 'int')
    register_std_typedef('wxEventType', 'int')

    module Common

      include Typemap::Module

      define do

        map 'int * OUTPUT' => 'Integer' do
          map_directorargout code: <<~__CODE
            if(output != Qnil)
            {
              *$1 = (int)NUM2INT(output);
            }
            else
            {
              *$1 = 0;
            }
            __CODE
        end

        map 'long * OUTPUT' => 'Integer' do
          map_directorargout code: <<~__CODE
            if(output != Qnil)
            {
              *$1 = (int)NUM2INT(output);
            }
            else
            {
              *$1 = 0;
            }
          __CODE
        end

        # String <> wxString type mappings

        map 'wxString&' => 'String' do
          map_in temp: 'wxString tmp', code: 'tmp = RSTR_TO_WXSTR($input); $1 = &tmp;'
          map_out code: '$result = WXSTR_PTR_TO_RSTR($1);'
          map_directorout code: '$result = RSTR_TO_WXSTR($input);'
          map_directorin code: '$input = WXSTR_TO_RSTR($1);'
          map_typecheck precedence: 'STRING', code: '$1 = (TYPE($input) == T_STRING);'
        end

        map 'wxString*' => 'String' do
          map_in temp: 'wxString tmp', code: 'tmp = RSTR_TO_WXSTR($input); $1 = &tmp;'
          map_out code: '$result = WXSTR_PTR_TO_RSTR($1);'
          map_directorin code: '$input = WXSTR_PTR_TO_RSTR($1);'
          map_typecheck precedence: 'STRING', code: '$1 = (TYPE($input) == T_STRING);'
        end

        map 'wxString' => 'String' do
          map_in code: '$1 = RSTR_TO_WXSTR($input);'
          map_out code: '$result = WXSTR_TO_RSTR($1);'
          map_directorout code: '$result = RSTR_TO_WXSTR($input);'
          map_typecheck precedence: 'STRING', code: '$1 = (TYPE($input) == T_STRING);'
          map_varout code: '$result = WXSTR_TO_RSTR($1);'
        end

        # String <> wxChar* type mappings

        map 'wxUniChar' => 'String' do
          map_in temp: 'wxString temp', code: <<~__CODE
            temp = ($input == Qnil ? wxString() : wxString(StringValuePtr($input), wxConvUTF8));
            $1 = temp.Len() > 0 ? temp.GetChar(0) : wxUniChar();
          __CODE
          map_out code: '$result = rb_str_new2((const char *)wxString($1).utf8_str());'
          map_directorin code: "$input = rb_str_new2((const char *)wxString($1).utf8_str());"
          map_directorout temp: 'wxString temp', code: <<~__CODE
            temp = ($input == Qnil ? wxString() : wxString(StringValuePtr($input), wxConvUTF8));
            $result = temp.Len() > 0 ? temp.GetChar(0) : wxUniChar();
          __CODE
          map_typecheck precedence: 'string', code: '$1 = (TYPE($input) == T_STRING);'
          map_varout code: '$result = rb_str_new2((const char *)wxString($1).utf8_str());'
        end

        map 'const wxUniChar &', 'wxUniChar const &', as: 'String' do
          map_in temp: 'wxString tempS, wxUniChar temp', code: <<~__CODE
            tempS = ($input == Qnil ? wxString() : wxString(StringValuePtr($input), wxConvUTF8));
            temp = tempS.Len() > 0 ? tempS.GetChar(0) : wxUniChar();
            $1 = &temp;
          __CODE
          map_directorin code: "$input = rb_str_new2((const char *)wxString($1).utf8_str());"
          map_typecheck precedence: 'string', code: '$1 = (TYPE($input) == T_STRING);'
        end

        map 'const wxChar *' => 'String' do
          map_in temp: 'wxString temp', code: <<~__CODE
            temp = ($input == Qnil ? wxString() : wxString(StringValuePtr($input), wxConvUTF8));
            $1 = const_cast<wxChar*> (static_cast<wxChar const *> (temp.c_str()));
            __CODE
          map_out code: '$result = rb_str_new2((const char *)wxString($1).utf8_str());'
          map_directorin code: "$input = rb_str_new2((const char *)wxString($1).utf8_str());"
          map_typecheck precedence: 'string', code: '$1 = (TYPE($input) == T_STRING);'
          map_varout code: '$result = rb_str_new2((const char *)wxString($1).utf8_str());'
        end

        # String <> wxChar type mappings
        map 'wxChar' => 'String' do
          map_in temp: 'wxString temp', code: <<~__CODE
            if ($input == Qnil || TYPE($input) != T_STRING || RSTRING_LEN($input) < 1)
            {
              $1 = 0;
            }
            else
            {
              temp = wxString(StringValuePtr($input), wxConvUTF8);
              $1 = temp[0];
            }
            __CODE
          map_out code: <<~__CODE
            if ($1 == 0)
            {
              $result = Qnil;
            }
            else
            {
              $result = rb_str_new2((const char *)wxString($1).utf8_str());
            }
            __CODE
          map_directorin code: <<~__CODE
            if ($1 == 0)
            {
              $input = Qnil;
            }
            else
            {
              $input = rb_str_new2((const char *)wxString($1).utf8_str());
            }
          __CODE
          map_typecheck precedence: 'string', code: '$1 = (TYPE($input) == T_STRING);'
          map_varout code: <<~__CODE
            if ($1 == 0)
            {
              $result = Qnil;
            }
            else
            {
              $result = rb_str_new2((const char *)wxString($1).utf8_str());
            }
          __CODE
        end

        # Object <> void* type mappings

        map 'void*' => 'Object' do
          map_in code: '$1 = (void*)($input);'
          map_out code: <<~__CODE
            if ($1) $result = (VALUE)($1);
            else    $result = Qnil;
            __CODE
          # void* should only be considered after everything else does not match
          # since for Ruby the precedence for bool is set to 10000 make it 20000
          # (have to be careful when bool is matched alongside void* though since
          #  the check considers values the Ruby way for bool, i.e. anything matches a bool)
          map_typecheck precedence: 20000, code: '$1 = TRUE;'
        end

        # Typemaps for wxSize and wxPoint as input parameters; for brevity,
        # wxRuby permits these common input parameters to be represented as
        # two-element arrays [x, y] or [width, height].

        map 'wxSize&' => 'Array<Integer>, Wx::Size',
            'wxPoint&' => 'Array<Integer>, Wx::Point' do
          map_in code: <<~__CODE
            if ( TYPE($input) == T_DATA )
            {
              void* argp$argnum;
              SWIG_ConvertPtr($input, &argp$argnum, $1_descriptor, 1 );
              $1 = reinterpret_cast< $1_basetype * >(argp$argnum);
            }
            else if ( TYPE($input) == T_ARRAY )
            {
              $1 = new $1_basetype( NUM2INT( rb_ary_entry($input, 0) ),
                                   NUM2INT( rb_ary_entry($input, 1) ) );
              // Create a ruby object so the C++ obj is freed when GC runs
              SWIG_NewPointerObj($1, $1_descriptor, 1);
            }
            else
            {
              rb_raise(rb_eTypeError, "Wrong type for $1_basetype parameter");
            }
            __CODE
          map_typecheck precedence: 'POINTER', code: <<~__CODE
            void *vptr = 0;
            $1 = 0;
            if (TYPE($input) == T_ARRAY && RARRAY_LEN($input) == 2)
              $1 = 1;
            else if (TYPE($input) == T_DATA && SWIG_CheckState (SWIG_ConvertPtr ($input, &vptr, $1_descriptor, 0)))
              $1 = 1;
            __CODE
        end

        # Integer <> wxItemKind type mappings

        map 'wxItemKind' => 'Integer' do
          map_in code: '$1 = (wxItemKind)NUM2INT($input);'
          map_out code: '$result = INT2NUM((int)$1);'
          # fixes mixup between
          # wxMenuItem* wxMenu::Append(int itemid, const wxString& text, const wxString& help = wxEmptyString, wxItemKind kind = wxITEM_NORMAL)
          # and
          # void wxMenu::Append(int itemid, const wxString& text, const wxString& help, bool isCheckable);
          map_typecheck precedence: 'INTEGER',
                        code: '$1 = (TYPE($input) == T_FIXNUM && TYPE($input) != T_TRUE && TYPE($input) != T_FALSE);'
        end

        # Array<String> <> wxString[]/wxString* type mappings

        map 'int n, const wxString choices []',
            'int n, const wxString* choices',
            'int nItems, const wxString *items' do
          map_in from: { type: 'Array<String>', index: 1 }, temp: 'wxString *arr', code: <<~__CODE
            if (($input == Qnil) || (TYPE($input) != T_ARRAY))
            {
              $1 = 0;
              $2 = NULL;
            }
            else
            {
              arr = new wxString[ RARRAY_LEN($input) ];
              for (int i = 0; i < RARRAY_LEN($input); i++)
              {
                VALUE str = rb_ary_entry($input,i);
                arr[i] = wxString(StringValuePtr(str), wxConvUTF8);
              }
              $1 = RARRAY_LEN($input);
              $2 = arr;
            }
            __CODE
          map_default code: <<~__CODE
            {
              $1 = 0;
              $2 = NULL;
            }
            __CODE
          map_freearg code: 'if ($2 != NULL) delete [] $2;'
          map_typecheck precedence: 'STRING_ARRAY', code: '$1 = (TYPE($input) == T_ARRAY);'
        end

        # Array<String> <> wxArrayString type mappings

        map 'wxArrayString &' => 'Array<String>' do
          map_in temp: 'wxArrayString tmp', code: <<~__CODE
            if (($input == Qnil) || (TYPE($input) != T_ARRAY))
            {
              $1 = &tmp;
            }
            else
            {
              for (int i = 0; i < RARRAY_LEN($input); i++)
              {
                VALUE str = rb_ary_entry($input, i);
                wxString item(StringValuePtr(str), wxConvUTF8);
                tmp.Add(item);
              }
              $1 = &tmp;
            }
            __CODE
          map_out code: <<~__CODE
            $result = rb_ary_new();
            for (size_t i = 0; i < $1->GetCount(); i++)
            {
              rb_ary_push($result, WXSTR_TO_RSTR($1->Item(i)));
            }
            __CODE
          map_directorin code: <<~__CODE
            $input = rb_ary_new();
            for (size_t i = 0; i < $1.GetCount(); i++)
            {
              rb_ary_push($input, WXSTR_TO_RSTR($1.Item(i)));
            }
          __CODE
          map_typecheck precedence: 'STRING_ARRAY', code: '$1 = (TYPE($input) == T_ARRAY);'
        end

        # wxArrayString return by value
        map 'wxArrayString' => 'Array<String>' do
          map_out code: <<~__CODE
              $result = rb_ary_new();
              for (size_t i = 0; i < $1.GetCount(); i++)
              {
                rb_ary_push($result, WXSTR_TO_RSTR($1.Item(i)));
              }
          __CODE
          map_directorout code: <<~__CODE
            if (TYPE($input) != T_ARRAY)
            {
              for (int i = 0; i < RARRAY_LEN($input); i++)
              {
                VALUE str = rb_ary_entry($input, i);
                wxString item(StringValuePtr(str), wxConvUTF8);
                $result.Add(item);
              }
            }
          __CODE
        end

        # Array<Integer> <> wxArrayInt/wxArrayInt& type mappings

        # return by value
        map 'wxArrayInt' => 'Array<Integer>' do
          map_in code: <<~__CODE
            if (($input != Qnil) && (TYPE($input) == T_ARRAY))
            {
              for (int i = 0; i < RARRAY_LEN($input); i++)
              {
                int item = NUM2INT(rb_ary_entry($input,i));
                $1.Add(item);
              }
            }
          __CODE
          map_out code: <<~__CODE
            $result = rb_ary_new();
            for (size_t i = 0; i < $1.GetCount(); i++)
            {
              rb_ary_push($result,INT2NUM( $1.Item(i) ) );
            }
            __CODE
          map_directorout code: <<~__CODE
            if (TYPE($input) != T_ARRAY)
            {
              for (int i = 0; i < RARRAY_LEN($input); i++)
              {
                int item = NUM2INT(rb_ary_entry($input,i));
                $result.Add(item);
              }
            }
            __CODE
          map_typecheck precedence: 'INT32_ARRAY', code: '$1 = (TYPE($input) == T_ARRAY);'
        end

        # input reference
        map 'wxArrayInt&' => 'Array<Integer>' do
          map_in temp: 'wxArrayInt tmp', code: <<~__CODE
            if (($input == Qnil) || (TYPE($input) != T_ARRAY))
            {
              $1 = &tmp;
            }
            else
            {
              for (int i = 0; i < RARRAY_LEN($input); i++)
              {
                int item = NUM2INT(rb_ary_entry($input,i));
                tmp.Add(item);
              }
              $1 = &tmp;
            }
            __CODE
          map_directorin code: <<~__CODE
            $input = rb_ary_new();
            for (size_t i = 0; i < $1.GetCount(); i++)
            {
              rb_ary_push($input,INT2NUM( $1.Item(i) ) );
            }
          __CODE
          map_typecheck precedence: 'INT32_ARRAY', code: '$1 = (TYPE($input) == T_ARRAY);'
        end

        # various enumerator type mappings

        map *%w[wxEdge wxRelationship wxKeyCode], as: 'Integer' do
          map_in code: '$1 = ($1_type)NUM2INT($input);'
          map_out code: '$result = INT2NUM((int)$1);'
          map_typecheck precedence: 'INT32', code: '$1 = TYPE($input) == T_FIXNUM;'
        end

        # integer OUTPUT mappings

        map_apply 'int *OUTPUT' => ['int * x', 'int * y', 'int * w', 'int * h', 'int * descent', 'int * externalLeading']
        map_apply 'int *OUTPUT' => ['wxCoord * width', 'wxCoord * height', 'wxCoord * heightLine',
                                    'wxCoord * w', 'wxCoord * h', 'wxCoord * descent', 'wxCoord * externalLeading']

        # DEPRECATED
        # # special integer combination OUTPUT mappings
        #
        # map 'int * x , int * y , int * descent, int * externalLeading' do
        #   map_directorargout code: <<~__CODE
        #     if((TYPE(result) == T_ARRAY) && ( RARRAY_LEN(result) >= 2 ) )
        #     {
        #       *$1 = ($*1_ltype)NUM2INT(rb_ary_entry(result,0));
        #       *$2 = ($*2_ltype)NUM2INT(rb_ary_entry(result,1));
        #       if(($3 != NULL) && RARRAY_LEN(result) >= 3)
        #         *$3 = ($*3_ltype)NUM2INT(rb_ary_entry(result,2));
        #       if(($4 != NULL) && RARRAY_LEN(result) >= 4)
        #         *$4 = ($*4_ltype)NUM2INT(rb_ary_entry(result,3));
        #     }
        #     __CODE
        # end
        # map 'wxCoord * width , wxCoord * height , wxCoord * heightLine' do
        #   map_directorargout code: <<~__CODE
        #     if((TYPE(result) == T_ARRAY) && ( RARRAY_LEN(result) >= 2) )
        #     {
        #       *$1 = ($*1_ltype)NUM2INT(rb_ary_entry(result,0));
        #       *$2 = ($*2_ltype)NUM2INT(rb_ary_entry(result,1));
        #       if(($3 != NULL) && RARRAY_LEN(result) >= 3)
        #         *$3 = ($*3_ltype)NUM2INT(rb_ary_entry(result,2));
        #     }
        #     __CODE
        # end
        # map 'wxCoord * w , wxCoord * h , wxCoord * descent, wxCoord * externalLeading' do
        #   map_directorargout code: <<~__CODE
        #     if((TYPE(result) == T_ARRAY) && ( RARRAY_LEN(result) >= 2 ) )
        #     {
        #       *$1 = ($*1_ltype)NUM2INT(rb_ary_entry(result,0));
        #       *$2 = ($*2_ltype)NUM2INT(rb_ary_entry(result,1));
        #       if(($3 != NULL) && RARRAY_LEN(result) >= 3)
        #         *$3 = ($*3_ltype)NUM2INT(rb_ary_entry(result,2));
        #       if(($4 != NULL) && RARRAY_LEN(result) >= 4)
        #         *$4 = ($*4_ltype)NUM2INT(rb_ary_entry(result,3));
        #     }
        #     __CODE
        # end

        # Window check type mapping

        map 'wxWindow* parent' => 'Wx::Window' do
          # This typemap catches the first argument of all constructors and
          # Create() methods for Wx::Window classes. These should not be called
          # before App::main_loop is started, and, except for TopLevelWindows,
          # the parent argument must not be NULL.
          map_check code: <<~__CODE
            if ( ! rb_const_defined(wxRuby_Core(), rb_intern("THE_APP") ) )
            { 
              rb_raise(rb_eRuntimeError,
                       "Cannot create a Window before App.main_loop has been called");
            }
            if ( ! $1 && ! rb_obj_is_kind_of(self, wxRuby_GetTopLevelWindowClass()) )
            { 
              rb_raise(rb_eArgError,
                       "Window parent argument must not be nil");
            }
            __CODE
        end

        # window/sizer object wrapping

        map 'wxWindow*' => 'Wx::Window', 'wxSizer*' => 'Wx::Sizer' do
          map_out code: '$result = wxRuby_WrapWxObjectInRuby($1);'
        end


        # Validators must be cast to correct subclass, but internal validator
        # is a clone, and should not be freed, so disown after wrapping.
        map 'wxValidator*' => 'Wx::Validator' do
          map_out code: <<~__CODE
            $result = wxRuby_WrapWxObjectInRuby($1);
            if (!NIL_P($result)) RDATA($result)->dfree = SWIG_RubyRemoveTracking;
            __CODE
        end

        # For ProcessEvent and AddPendingEvent and wxApp::FilterEvent

        map 'wxEvent &event' => 'Wx::Event' do
          map_directorin code: <<~__CODE
            #ifdef __WXRB_TRACE__
            $input = wxRuby_WrapWxEventInRuby(this, const_cast<wxEvent*> (&$1));
            #else
            $input = wxRuby_WrapWxEventInRuby(const_cast<wxEvent*> (&$1));
            #endif
            __CODE

          # Thin and trusting wrapping to bypass SWIG's normal mechanisms; we
          # don't want SWIG changing ownership or typechecking these.
          map_in code: '$1 = (wxEvent*)DATA_PTR($input);'
        end

        # For wxWindow::DoUpdateUIEvent

        map 'wxUpdateUIEvent &' => 'Wx::UpdateUIEvent' do
          map_directorin code: <<~__CODE
            #ifdef __WXRB_TRACE__
            $input = wxRuby_WrapWxEventInRuby(this, static_cast<wxEvent*> (&$1));
            #else
            $input = wxRuby_WrapWxEventInRuby(static_cast<wxEvent*> (&$1));
            #endif
            __CODE
        end

        # For wxControl::Command

        map 'wxCommandEvent &' => 'Wx::CommandEvent' do
          map_directorin code: <<~__CODE
            #ifdef __WXRB_TRACE__
            $input = wxRuby_WrapWxEventInRuby(this, static_cast<wxEvent*> (&$1));
            #else
            $input = wxRuby_WrapWxEventInRuby(static_cast<wxEvent*> (&$1));
            #endif
            __CODE
        end

        # typemap to provide backward compatibility for BitmapBundle
        map 'const wxBitmapBundle&' do
          add_header_code <<~__CODE
            inline bool wx_IsClass(VALUE obj, const char* class_name)
            {
              VALUE klass = rb_const_get(wxRuby_Core(), rb_intern(class_name));
              return rb_obj_is_kind_of(obj, klass);
            }
            __CODE
          map_in from: 'Wx::BitmapBundle,Wx::Bitmap,Wx::Icon,Wx::Image',
                 temp: 'wxBitmapBundle tmpBundle', code: <<~__CODE
            $1 = &tmpBundle;
            if (!NIL_P($input))
            {
              bool ok = false;
              if (TYPE($input) == T_DATA) 
              {
                void *ptr;
                Data_Get_Struct($input, void, ptr);
                if (ptr)
                {
                  ok = true;
                  if (wx_IsClass($input, "BitmapBundle"))
                    tmpBundle = *static_cast<wxBitmapBundle*> (ptr);
                  else if (wx_IsClass($input, "Bitmap"))
                    tmpBundle = wxBitmapBundle(*static_cast<wxBitmap*> (ptr)); 
                  else if (wx_IsClass($input, "Icon"))
                    tmpBundle = wxBitmapBundle(*static_cast<wxIcon*> (ptr)); 
                  else if (wx_IsClass($input, "Image"))
                    tmpBundle = wxBitmapBundle(*static_cast<wxImage*> (ptr));
                  else
                    ok = false;
                }
                else
                {
                  rb_raise(rb_eArgError, "Object already deleted for $1_basetype parameter $argnum");
                }
              }
              // did we get a bitmap of some kind?
              if (!ok)
              {
                rb_raise(rb_eTypeError, "Wrong type for $1_basetype parameter $argnum");
              }
            }
            __CODE
          map_typecheck precedence: 2000, code: <<~__CODE
            $1 = (NIL_P($input) || 
                    (TYPE($input) == T_DATA && 
                     (wx_IsClass($input, "BitmapBundle") || 
                      wx_IsClass($input, "Bitmap") || 
                      wx_IsClass($input, "Icon") || 
                      wx_IsClass($input, "Image")))
                 );
            __CODE
        end

        # output typemaps for common reference counted objects like wxColour, wxFont,
        # making sure to ALWAYS create managed copies
        %w[wxColour wxFont wxPen wxBrush wxBitmap wxIcon wxCursor wxIconBundle wxPalette wxFontData wxFindReplaceData].each do |klass|
          map "const #{klass}&", "const #{klass}*" do
            map_out code: <<~__CODE
              $result = SWIG_NewPointerObj((new #{klass}(*static_cast< const #{klass}* >($1))), SWIGTYPE_p_#{klass}, SWIG_POINTER_OWN);
              __CODE
          end
        end
        # special case bc SWIG causes trouble in Window.cpp
        map 'const wxRegion&', 'const wxRegion*' do
          map_out code: '$result = wxRuby_WrapWxObjectInRuby(new wxRegion(*static_cast<const wxRegion*> ($1)));'
        end

        # add type mapping for wxVariant input args
        intypes = 'nil,String,Integer,Float,Time,Wx::Font,Wx::Colour,Wx::Variant,Array<WxVariant>,Array<String>,Object'
        if Config.instance.features_set?('wxUSE_PROPGRID')
          intypes << 'Wx::PG::ColourPropertyValue'
        end
        map 'const wxVariant&' => intypes do
          map_in temp: 'wxVariant tmp', code: 'tmp = wxRuby_ConvertRbValue2Variant($input); $1 = &tmp;'
        end
        map 'wxVariant' => intypes do
          map_in code: '$1 = wxRuby_ConvertRbValue2Variant($input);'
        end

      end # define

    end # Common

  end # Typemap

end # WXRuby3
