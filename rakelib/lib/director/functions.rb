# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class Functions < Director

      include Typemap::ArrayIntSelections

      def setup
        super
        spec.items.clear
        if Config.instance.wx_version_check('3.3.0') >= 0
          spec.add_header_code '#include <wx/busycursor.h>'
        end
        spec.add_header_code <<~__HEREDOC
          #include <wx/image.h>
          #include <wx/app.h>
          #include <wx/choicdlg.h>
          #include <wx/numdlg.h>
          #include <wx/xrc/xmlres.h>
          #include <wx/utils.h>
          #include <wx/stockitem.h>
          #include <wx/aboutdlg.h>
          
          // Logging functions - these don't directly wrap the corresponding wx
          // LogXXX functions because those expect a literal format string and a
          // list of arguments, rather than a dynamic string. Instead we do the
          // sprintf in ruby, then pass the composed message directly to the
          // log. This also avoids format string attacks.
          
          static WxRuby_ID __filename_id("filename");
          static WxRuby_ID __line_id("line");
          static WxRuby_ID __func_id("func");
          static WxRuby_ID __comp_id("component");

          static const char* __wxruby_component = "wxapp";

          // As the wxw logger will only make synchronous use of the filename, func and component pointers while
          // processing the log entry and never store them we simply gather pointers but no copies 
          static void do_log(wxLogLevel lvl, int argc, VALUE *argv)
          {
            const char* filename = nullptr;
            int line = 0;
            const char* func = nullptr;
            const char* component = __wxruby_component;

            if (argc>1 && TYPE(argv[argc-1]) == T_HASH)
            {
              VALUE rb_hash = argv[--argc];
              VALUE rb_fnm  = rb_hash_aref(rb_hash, ID2SYM(__filename_id.get_id()));
              if (!NIL_P(rb_fnm) && TYPE(rb_fnm) == T_STRING) filename = StringValuePtr(rb_fnm);
              VALUE rb_ln   = rb_hash_aref(rb_hash, ID2SYM(__line_id.get_id()));
              if (!NIL_P(rb_ln) && TYPE(rb_ln) == T_FIXNUM) line = NUM2INT(rb_ln);
              VALUE rb_func = rb_hash_aref(rb_hash, ID2SYM(__func_id.get_id()));
              if (!NIL_P(rb_func) && TYPE(rb_func) == T_STRING) func = StringValuePtr(rb_func);
              VALUE rb_comp = rb_hash_aref(rb_hash, ID2SYM(__comp_id.get_id()));
              if (!NIL_P(rb_comp) && TYPE(rb_comp) == T_STRING) component = StringValuePtr(rb_comp);
            }

            if ( lvl == wxLOG_FatalError ||
                    wxLog::IsLevelEnabled(lvl, wxASCII_STR(component)) )
            {
              VALUE log_msg = argc==1 ? argv[0] : rb_f_sprintf(argc, argv);
              wxLogRecordInfo info(filename, line, func, component);
              info.timestampMS = wxGetUTCTimeMillis().GetValue();
              wxLog::OnLog(lvl, RSTR_TO_WXSTR(log_msg), info);
            }
          }

          // Log a Wx message with the given level to the current Wx log output
          static VALUE log_generic(int argc, VALUE *argv, VALUE self)
          {
            wxLogLevel lvl = static_cast<wxLogLevel> (NUM2INT(argv[0]));
            do_log(lvl, argc-1, &argv[1]);
            return Qnil;
          }
          
          // Log a Wx low prio Message to the current Wx log output
          static VALUE log_info(int argc, VALUE *argv, VALUE self)
          {
            do_log(wxLOG_Info, argc, argv);
            return Qnil;
          }
          
          // Log a Wx verbose Message to the current Wx log output
          static VALUE log_verbose(int argc, VALUE *argv, VALUE self)
          {
            if (wxLog::GetVerbose ())
              do_log(wxLOG_Info, argc, argv);
            return Qnil;
          }
          
          // Log a Wx Message to the current Wx log output
          static VALUE log_message(int argc, VALUE *argv, VALUE self)
          {
            do_log(wxLOG_Message, argc, argv);
            return Qnil;
          }
          
          // Log a Wx Warning message to the current Wx log output
          static VALUE log_warning(int argc, VALUE *argv, VALUE self)
          {
            do_log(wxLOG_Warning, argc, argv);
            return Qnil;
          }
          
          // Log an error message to the current output
          static VALUE log_error(int argc, VALUE *argv, VALUE self)
          {
            do_log(wxLOG_Error, argc, argv);
            return Qnil;
          }

          // Log a debug message
          static VALUE log_debug(int argc, VALUE *argv, VALUE self)
          {
            do_log(wxLOG_Debug, argc, argv);
            return Qnil;
          }
          
          // Log a Wx Status message - this is directed to the status bar of the
          // specified window, or the application main window if not specified.
          // Based on wxWidgets code in src/generic/logg.cpp, WxLogGui::DoLog
          static VALUE log_status(int argc, VALUE *argv, VALUE self)
          {
            if ( ! wxLog::IsEnabled() )
              return Qnil;
          
            VALUE log_msg; // The message to be written
            wxFrame* log_frame {}; // The frame whose status bar should display the logmsg
          
            // To a specific window's status bar
            if( TYPE(argv[0]) == T_DATA ) {
              log_msg = rb_f_sprintf(argc-1, &argv[1]);
              Data_Get_Struct(argv[0], wxFrame, log_frame);
            }
            // To the application main window's status bar
            else {
              log_msg = rb_f_sprintf(argc, argv);
              wxWindow* win = wxTheApp->GetTopWindow();
              // Check the top window is actually a frame, not a dialog
              if ( win != NULL && win->IsKindOf( CLASSINFO(wxFrame)  ) )
                log_frame = (wxFrame*)win;
            }
          
            // Finally, display in the status bar if it has one
            if ( log_frame && log_frame->GetStatusBar() )
              log_frame->SetStatusText(wxString( StringValuePtr(log_msg), wxConvUTF8));
          
            return Qnil;
          }
          
          // Returns the global app object
          static VALUE get_app(VALUE self)
          {
            static WxRuby_ID THE_APP_id("THE_APP");

            return rb_const_get(wxRuby_Core(), THE_APP_id());
          }
          
          // Converts a string XRC id into a Wx id
          static VALUE
          xrcid(VALUE self,VALUE str_id)
          {
            wxString temp(StringValuePtr(str_id), wxConvUTF8);
            int ret = wxXmlResource::GetXRCID(temp);
            return INT2NUM(ret);
          }
          
          
          // Returns the pointer address of the underlying C++ object as a hex
          // string - useful for debugging
          static VALUE
          cpp_ptr_addr(VALUE self, VALUE obj)
          {
            static WxRuby_ID sprintf_id("sprintf");

            size_t ptr = (size_t)DATA_PTR(obj);
            return rb_funcall( rb_mKernel, sprintf_id(), 2,
                               rb_str_new2("0x%x"), OFFT2NUM(ptr) );
          }
          __HEREDOC

        # All the functions which take a parent argument in this file display
        # dialogs, so the parent argument can be nil (which is not permitted in
        # the normal typemap defined in common.rb). So override the standard
        # typemap and just check that the App has been started.
        spec.map 'wxWindow* parent' do
          map_check code: <<~__CODE
            if ( !wxRuby_IsAppRunning() )
            { 
                rb_raise(rb_eRuntimeError,
                       "Cannot display dialog before App.main_loop has been called");
            }
            __CODE
        end
        spec.map_apply 'int *OUTPUT' => ['int *indexDefaultExtension']
        # hardcoded interface declarations
        if Config.instance.wx_version_check('3.3.0') >= 0
          spec.add_interface_code 'void wxBeginBusyCursor(const wxCursorBundle& cursors);'
        end
        spec.add_interface_code <<~__HEREDOC
          void wxBeginBusyCursor(const wxCursor* cursor = wxHOURGLASS_CURSOR);
          void wxEndBusyCursor(); 	

          bool wxSafeYield(wxWindow* win = NULL, bool onlyIfNeeded = false);
          
          // Dialog shortcuts
          wxString wxFileSelector (const wxString &message,
                                   const wxString &default_path=wxEmptyString,
                                   const wxString &default_filename=wxEmptyString,
                                   const wxString &default_extension=wxEmptyString,
                                   const wxString &wildcard=wxFileSelectorDefaultWildcardStr,
                                   int flags=0, wxWindow *parent=NULL, int x=wxDefaultCoord, int y=wxDefaultCoord);
          
          wxString wxFileSelectorEx (const wxString &message=wxFileSelectorPromptStr,
                                     const wxString &default_path=wxEmptyString,
                                     const wxString &default_filename=wxEmptyString,
                                     int *indexDefaultExtension=NULL,
                                     const wxString &wildcard=wxFileSelectorDefaultWildcardStr,
                                     int flags=0, wxWindow *parent=NULL, int x=wxDefaultCoord, int y=wxDefaultCoord);
          
          wxString wxLoadFileSelector (const wxString &what,
                                       const wxString &extension,
                                       const wxString &default_name=wxEmptyString,
                                       wxWindow *parent=NULL);
          
          wxString wxSaveFileSelector (const wxString &what,
                                       const wxString &extension,
                                       const wxString &default_name=wxEmptyString,
                                       wxWindow *parent=NULL);
          
          // Managing stock ids
          enum  	wxStockLabelQueryFlag {
            wxSTOCK_NOFLAGS = 0 ,
            wxSTOCK_WITH_MNEMONIC = 1 ,
            wxSTOCK_WITH_ACCELERATOR = 2 ,
            wxSTOCK_WITHOUT_ELLIPSIS = 4 ,
            wxSTOCK_FOR_BUTTON = wxSTOCK_WITHOUT_ELLIPSIS | wxSTOCK_WITH_MNEMONIC
          };

          bool wxIsStockID(wxWindowID id);
          bool wxIsStockLabel(wxWindowID id, const wxString& label);
          wxString wxGetStockLabel(wxWindowID id,
                                   long flags = wxSTOCK_WITH_MNEMONIC);
          wxAcceleratorEntry wxGetStockAccelerator(wxWindowID id);

          enum wxStockHelpStringClient
          {
              wxSTOCK_MENU
          };

          wxString wxGetStockHelpString(wxWindowID id,
                                        wxStockHelpStringClient client = wxSTOCK_MENU);
          __HEREDOC
        spec.add_init_code <<~__HEREDOC
          rb_define_module_function(mWxFunctions, "log_generic", VALUEFUNC(log_generic), -1);
          rb_define_module_function(mWxFunctions, "log_info", VALUEFUNC(log_info), -1);
          rb_define_module_function(mWxFunctions, "log_verbose", VALUEFUNC(log_verbose), -1);
          rb_define_module_function(mWxFunctions, "log_message", VALUEFUNC(log_message), -1);
          rb_define_module_function(mWxFunctions, "log_warning", VALUEFUNC(log_warning), -1);
          rb_define_module_function(mWxFunctions, "log_status", VALUEFUNC(log_status), -1);
          rb_define_module_function(mWxFunctions, "log_error", VALUEFUNC(log_error), -1);
          rb_define_module_function(mWxFunctions, "log_debug", VALUEFUNC(log_debug), -1);
          rb_define_module_function(mWxFunctions, "get_app", VALUEFUNC(get_app), 0);
          rb_define_module_function(mWxFunctions, "xrcid", VALUEFUNC(xrcid), 1);
          rb_define_module_function(mWxFunctions, "ptr_addr", VALUEFUNC(cpp_ptr_addr), 1);
          __HEREDOC
      end
    end # class Functions

  end # class Director

end # module WXRuby3
