# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class HelpController < Director

      include Typemap::ConfigBase

      def setup
        super
        spec.items << 'wxHelpControllerBase' << 'helpfrm.h'
        spec.fold_bases(spec.module_name => 'wxHelpControllerBase')
        spec.rename_for_ruby('Init' => "#{spec.module_name}::Initialize")
        # ignore these (pure virtual) decls
        spec.ignore %w[
          wxHelpControllerBase::DisplayContents
          wxHelpControllerBase::DisplayBlock
          wxHelpControllerBase::DisplaySection
          wxHelpControllerBase::KeywordSearch
          wxHelpControllerBase::LoadFile
          wxHelpControllerBase::Quit
          ], ignore_doc: false
        # and add them as the implemented overrides they are
        spec.extend_interface spec.module_name,
                              'virtual bool DisplayContents()',
                              'virtual bool DisplayBlock(long blockNo)',
                              'virtual bool DisplaySection(int sectionNo)',
                              'virtual bool DisplaySection(const wxString &section)',
                              'virtual bool KeywordSearch(const wxString &keyWord, wxHelpSearchMode mode=wxHELP_SEARCH_ALL)',
                              'virtual bool LoadFile(const wxString &file=wxEmptyString)',
                              'virtual bool Quit()'
        # ignore this problematic method
        spec.ignore 'wxHelpControllerBase::GetFrameParameters'
        # and add a customized version
        spec.add_extend_code spec.module_name, <<~__HEREDOC
          VALUE GetFrameParameters()
          {
            wxFrame *result = 0;
            wxSize size;
		        wxPoint pos;
		        bool newFrameEachTime;
            result = $self->GetFrameParameters(&size, &pos, &newFrameEachTime);
            VALUE rc = Qnil;
            if (result)
            {
              rc = rb_ary_new();
              rb_ary_push(rc, wxRuby_WrapWxObjectInRuby(result));
              rb_ary_push(rc, SWIG_NewPointerObj(new wxSize(size), SWIGTYPE_p_wxSize, 1));
              rb_ary_push(rc, SWIG_NewPointerObj(new wxPoint(pos), SWIGTYPE_p_wxPoint, 1));
              rb_ary_push(rc, newFrameEachTime ? Qtrue : Qfalse);
            }
            return rc;
          }
          __HEREDOC
        spec.suppress_warning(473, "#{spec.module_name}::GetParentWindow")
        if spec.module_name == 'wxHtmlHelpController'
          # prevent having to expose HtmlHelpFrame & HtmlHelpDialog
          # I do not see real use in supporting custom HtmlHelpController derivatives
          spec.ignore 'wxHtmlHelpController::CreateHelpFrame',
                      'wxHtmlHelpController::CreateHelpDialog',
                      'wxHtmlHelpController::GetFrame',
                      'wxHtmlHelpController::GetDialog',
                      'wxHtmlHelpController::DisplayContents',
                      'wxHtmlHelpController::KeywordSearch'
          # add custom implementation of HtmlModalHelp as module function (not a class)
          spec.add_header_code <<~__CODE
            static VALUE wxruby_HtmlModalHelp(int argc, VALUE *argv, VALUE self)
            {
              if (argc < 2 || argc > 4)
              {
                rb_raise(rb_eArgError, "wrong # of arguments %d for 2 (max 4)", argc);
                return Qnil;
              }

              void *ptr = nullptr;
              wxWindow *parent = nullptr;
              wxString help_file;
              wxString topic = wxEmptyString;
              int style = wxHF_DEFAULT_STYLE;
              int res = 0;
            
              res = SWIG_ConvertPtr(argv[0], &ptr, SWIGTYPE_p_wxWindow, 0);
              if (!SWIG_IsOK(res)) 
              {
                VALUE msg = rb_inspect(argv[0]);
                rb_raise(rb_eTypeError, "expected wxWindow* for 1 but got %s", StringValuePtr(msg));
                return Qnil; 
              }
              parent = reinterpret_cast< wxWindow * >(ptr);
              if (TYPE(argv[1]) != T_STRING)  
              {
                VALUE msg = rb_inspect(argv[1]);
                rb_raise(rb_eTypeError, "expected String for 2 but got %s", StringValuePtr(msg));
                return Qnil;
              }
              help_file = RSTR_TO_WXSTR(argv[1]);
              if (argc > 2)
              {
                if (TYPE(argv[2]) != T_STRING)  
                {
                  VALUE msg = rb_inspect(argv[2]);
                  rb_raise(rb_eTypeError, "expected String for 3 but got %s", StringValuePtr(msg));
                  return Qnil;
                }
                topic = RSTR_TO_WXSTR(argv[2]);
              }
              if (argc > 3)
              {
                if (TYPE(argv[3]) != T_FIXNUM)  
                {
                  VALUE msg = rb_inspect(argv[3]);
                  rb_raise(rb_eTypeError, "expected Integer for 4 but got %s", StringValuePtr(msg));
                  return Qnil;
                }
                style = NUM2INT(argv[3]);
              } 
              wxHtmlModalHelp(parent, help_file, topic, style);
              return Qnil;
            } 
            __CODE
          spec.add_init_code <<~__CODE__
            rb_define_module_function(mWxHtmlHelpController, "HtmlModalHelp", VALUEFUNC(wxruby_HtmlModalHelp), -1);
            __CODE__
        elsif spec.module_name == 'wxExtHelpController'
          spec.ignore %w[
            wxExtHelpController::DisplayContents
            wxExtHelpController::DisplayBlock
            wxExtHelpController::DisplaySection
            wxExtHelpController::KeywordSearch
            wxExtHelpController::LoadFile
            wxExtHelpController::Quit
            wxExtHelpController::GetFrameParameters
          ]
          # already generated with HelpController
          spec.do_not_generate :variables, :enums, :defines, :functions
        end
      end
    end # class HelpController

  end # class Director

end # module WXRuby3
