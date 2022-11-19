#--------------------------------------------------------------------
# @file    help_provider.rb
# @author  Martin Corino
#
# @brief   wxRuby3 wxWidgets interface director
#
# @copyright Copyright (c) M.J.N. Corino, The Netherlands
#--------------------------------------------------------------------

module WXRuby3

  class Director

    class HelpProvider < Director

      def setup
        super
        spec.gc_as_object 'wxHelpProvider'
        # We need to create a C++ subclass b/c the base class is pure
        # virtual. To be used, a class must be inherited in Ruby which
        # implements the relevant virtual methods eg AddHelp, ShowHelp,
        # GetHelp. wxWidgets provides some pre-made classes (eg
        # wxSimpleHelpProvider) but these are so trivial in implementation that
        # it's not worth porting them - easier to write as pure-ruby classes.
        spec.rename_for_ruby('wxHelpProvider' => 'wxRubyHelpProvider')
        spec.disown 'wxRubyHelpProvider *'
        spec.include 'wx/cshelp.h'
        spec.add_header_code <<~__HEREDOC
          class wxRubyHelpProvider : public wxHelpProvider
          {
          public:
            // This is pure virtual in base Wx class, so won't compile unless an
            // implementation is provided
            wxString GetHelp(const wxWindowBase* window)
            {
              VALUE rb_win = wxRuby_WrapWxObjectInRuby( (wxWindow*)window );
              VALUE self = SWIG_RubyInstanceFor(this);
              
              VALUE rb_help_str = rb_funcall(self, rb_intern("get_help"), 1, rb_win);
          
              wxString result;
              if ( TYPE(rb_help_str) == T_STRING )
                result = wxString( StringValuePtr(rb_help_str), wxConvUTF8);
              else
                rb_raise(rb_eTypeError, "HelpProvider#get_help must return a String");
              
              return result;
            }
          
            // RemoveHelp is called by Wx after the window deletion event has been
            // handled. A standard director here re-wraps the already destroyed
            // object, which will cause rapid segfaults when it is later marked.
            void RemoveHelp(wxWindowBase* window) 
            {
              VALUE rb_win = SWIG_RubyInstanceFor( (void *)window );
              if ( ! NIL_P(rb_win) )
                {
                  VALUE self   = SWIG_RubyInstanceFor(this);
                  rb_funcall(self, rb_intern("remove_help"), 1, rb_win);
                }
            }
          };
          __HEREDOC
        spec.add_swig_code <<~__HEREDOC
          typedef wxWindow wxWindowBase;

          %ignore wxHelpProvider::GetHelp; // Must be supplied in Ruby
          
          // Need to avoid standard director as it will call with destroyed
          // objects
          %feature("nodirector") wxHelpProvider::RemoveHelp;
          __HEREDOC
        # this is just the SWIG interface description so we do not need
        # to mention the inheritance relation here as it is not important
        # for the Ruby implementation
        spec.add_interface_code <<~__HEREDOC
          class wxRubyHelpProvider
          {
          public:
            virtual ~wxRubyHelpProvider();
            static wxRubyHelpProvider* Set(wxRubyHelpProvider* helpProvider);
            static wxRubyHelpProvider* Get();
            virtual void AddHelp(wxWindowBase* window, const wxString&  text);
            virtual void AddHelp(wxWindowID id, const wxString& text);
            virtual wxString GetHelp(const wxWindowBase* window);
            virtual void RemoveHelp(wxWindowBase* window);
            virtual bool ShowHelp(wxWindowBase* window);
            virtual bool ShowHelpAtPoint(wxWindowBase* window, const wxPoint point, 
                                         wxHelpEvent::Origin origin);
          };
          __HEREDOC
      end
    end # class HelpProvider

  end # class Director

end # module WXRuby3
