// Copyright 2004-2007, wxRuby development team
// released under the MIT-like wxRuby2 license

%module(directors="1") wxFunctions
%include "common.i"

// This file defines a set of top-level functions used across the
// wxLibrary:
// * shortcut methods for displaying simple dialogs
// * logging functions
// * the xrcid macro
// * display information methods
// * global mouse/keyboard information


%{
#include <wx/image.h>
#include <wx/app.h>
#include <wx/choicdlg.h>
#include <wx/numdlg.h>
#include <wx/xrc/xmlres.h>
#include <wx/utils.h>
#include <wx/stockitem.h>
#include <wx/aboutdlg.h>

extern VALUE mWxCore;
WXRUBY_EXPORT VALUE wxRuby_Core();

class wxRubyApp
{
public:

};

// Logging functions - these don't directly wrap the corresponding wx
// LogXXX functions because those expect a literal format string and a
// list of arguments, rather than a dynamic string. Instead we do the
// sprintf in ruby, then pass the composed message directly to the
// log. This also avoids format string attacks.

// Log a Wx message with the given level to the current Wx log output
static VALUE log_generic(int argc, VALUE *argv, VALUE self)
{
  if ( wxLog::IsEnabled() )
    {
      wxLogLevel lvl = static_cast<wxLogLevel> (NUM2INT(argv[0]));
      VALUE log_msg = rb_f_sprintf(argc-1, &argv[1]);
      wxLog::OnLog( lvl,
                    wxString(StringValuePtr(log_msg), wxConvUTF8),
                    time(NULL) );
    }
  return Qnil;
}

// Log a Wx low prio Message to the current Wx log output
static VALUE log_info(int argc, VALUE *argv, VALUE self)
{
  if ( wxLog::IsEnabled() )
    {
      VALUE log_msg = rb_f_sprintf(argc, argv);
      wxLog::OnLog( wxLOG_Info,
                    wxString(StringValuePtr(log_msg), wxConvUTF8),
                    time(NULL) );
    }
  return Qnil;
}

// Log a Wx verbose Message to the current Wx log output
static VALUE log_verbose(int argc, VALUE *argv, VALUE self)
{
  if ( wxLog::IsEnabled() && wxLog::GetVerbose () )
    {
      VALUE log_msg = rb_f_sprintf(argc, argv);
      wxLog::OnLog( wxLOG_Info,
                    wxString(StringValuePtr(log_msg), wxConvUTF8),
                    time(NULL) );
    }
  return Qnil;
}

// Log a Wx Message to the current Wx log output
static VALUE log_message(int argc, VALUE *argv, VALUE self)
{
  if ( wxLog::IsEnabled() )
    {
      VALUE log_msg = rb_f_sprintf(argc, argv);
      wxLog::OnLog( wxLOG_Message,
                    wxString(StringValuePtr(log_msg), wxConvUTF8),
                    time(NULL) );
    }
  return Qnil;
}

// Log a Wx Warning message to the current Wx log output
static VALUE log_warning(int argc, VALUE *argv, VALUE self)
{
  if ( wxLog::IsEnabled() )
    {
      VALUE log_msg = rb_f_sprintf(argc, argv);
      wxLog::OnLog( wxLOG_Warning,
                    wxString(StringValuePtr(log_msg), wxConvUTF8),
                    time(NULL) );
    }
  return Qnil;
}

// Log an error message to the current output
static VALUE log_error(int argc, VALUE *argv, VALUE self)
{
  if ( wxLog::IsEnabled() )
    {
      VALUE log_msg = rb_f_sprintf(argc, argv);
      wxLog::OnLog( wxLOG_Error,
                    wxString(StringValuePtr(log_msg), wxConvUTF8),
                    time(NULL) );
    }
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
  return rb_const_get(wxRuby_Core(), rb_intern("THE_APP"));
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
  size_t ptr = (size_t)DATA_PTR(obj);
  return rb_funcall( rb_mKernel, rb_intern("sprintf"), 2,
                     rb_str_new2("0x%x"), OFFT2NUM(ptr) );
}
%} // end of Header code


// All the functions which take a parent argument in this file display
// dialogs, so the parent argument can be nil (which is not permitted in
// the normal typemap defined in typemap.i). So override the standard
// typemap and just check that the App has been started.
%typemap(check) wxWindow* parent {
  if ( ! rb_const_defined(wxRuby_Core(), rb_intern("THE_APP") ) )
	{ rb_raise(rb_eRuntimeError,
			   "Cannot display dialog before App.main_loop has been called");}
}

// App-wide user information methods
void wxBeginBusyCursor(wxCursor *cursor = wxHOURGLASS_CURSOR);
void wxEndBusyCursor();
void wxBell();
bool wxSafeYield(wxWindow* win = NULL, bool onlyIfNeeded = false);

// System information
wxString wxGetEmailAddress();
wxString wxGetHostName();
wxString wxGetFullHostName();
wxString wxGetUserId();
wxString wxGetUserName();
wxString wxGetHomeDir();

// Mouse / keyboard information
bool wxGetKeyState(wxKeyCode key);
wxWindow* wxFindWindowAtPoint(const wxPoint& pt);
wxWindow * wxGetActiveWindow();
wxPoint wxGetMousePosition();
wxMouseState wxGetMouseState();

// Dialog shortcuts
int wxMessageBox(const wxString& message,
				 const wxString& caption = wxT("Message"),
				 int style = wxOK,
				 wxWindow *parent = NULL,
				 int x = -1,
				 int y = -1);

// Fix selections to be the return value to ruby
%include "shared/arrayint_selections.i"
int wxGetSelectedChoices(wxArrayInt& selections,
              const wxString& message,
              const wxString& caption,
              int n, const wxString *choices,
              wxWindow *parent = NULL,
              int x = wxDefaultCoord,
              int y = wxDefaultCoord,
              bool centre = true,
              int width = wxCHOICE_WIDTH,
              int height = wxCHOICE_HEIGHT);
long wxGetNumberFromUser(const wxString& message,
						 const wxString& prompt,
						 const wxString& caption,
						 long value, long min = 0, long max = 100,
						 wxWindow *parent = NULL,
						 const wxPoint& pos = wxDefaultPosition);
wxString wxGetTextFromUser(const wxString& message,
						   const wxString& caption = wxT("Input text"),
						   const wxString& default_value = wxT(""),
						   wxWindow *parent = NULL);
wxString wxGetPasswordFromUser(const wxString& message,
							   const wxString& caption = wxT("Input text"),
							   const wxString& default_value = wxT(""),
							   wxWindow *parent = NULL);
// wxString wxFileSelector(const wxString& message,
// 						const wxString& default_path = wxT(""),
// 						const wxString& default_filename = wxT(""),
// 						const wxString& default_extension = wxT(""),
// 						const wxString& wildcard = wxT("*.*"),
// 						int flags = 0,
// 						wxWindow *parent = 0,
// 						int x = -1,
// 						int y = -1);

// void wxAboutBox(const wxAboutDialogInfo& info);

//// Display information methods
//int wxDisplayDepth();
//wxSize wxGetDisplaySize();
//wxSize wxGetDisplaySizeMM();
//bool wxColourDisplay();
//wxRect wxGetClientDisplayRect();

// Managing stock ids
bool wxIsStockID(wxWindowID id);
bool wxIsStockLabel(wxWindowID id, const wxString& label);
wxString wxGetStockLabel(wxWindowID id,
                         long flags = wxSTOCK_WITH_MNEMONIC);
wxAcceleratorEntry wxGetStockAccelerator(wxWindowID id);
wxString wxGetStockHelpString(wxWindowID id,
                              wxStockHelpStringClient client = wxSTOCK_MENU);


%init %{
    rb_define_module_function(mWxCore, "log_generic", VALUEFUNC(log_generic), -1);
    rb_define_module_function(mWxCore, "log_info", VALUEFUNC(log_info), -1);
    rb_define_module_function(mWxCore, "log_verbose", VALUEFUNC(log_verbose), -1);
    rb_define_module_function(mWxCore, "log_message", VALUEFUNC(log_message), -1);
    rb_define_module_function(mWxCore, "log_warning", VALUEFUNC(log_warning), -1);
    rb_define_module_function(mWxCore, "log_status", VALUEFUNC(log_status), -1);
    rb_define_module_function(mWxCore, "log_error", VALUEFUNC(log_error), -1);
    rb_define_module_function(mWxCore, "get_app", VALUEFUNC(get_app), 0);
    rb_define_module_function(mWxCore, "xrcid", VALUEFUNC(xrcid), 1);
    rb_define_module_function(mWxCore, "ptr_addr", VALUEFUNC(cpp_ptr_addr), 1);
%}
