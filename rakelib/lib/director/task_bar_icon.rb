# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './event_handler'

module WXRuby3

  class Director

    class TaskBarIcon < EvtHandler

      def setup
        super
        spec.gc_never
        # need a custom implementation to handle event handler proc cleanup
        spec.add_header_code <<~__HEREDOC
          class WXRubyTaskBarIcon : public wxTaskBarIcon
          {
          public:
            WXRubyTaskBarIcon(wxTaskBarIconType iconType=wxTBI_DEFAULT_TYPE) : wxTaskBarIcon(iconType) {}
            virtual ~WXRubyTaskBarIcon() 
            {
              wxRuby_ReleaseEvtHandlerProcs(this);
            }               
          };
        __HEREDOC
        spec.use_class_implementation 'wxTaskBarIcon', 'WXRubyTaskBarIcon'
        # this one is protected so ignored by default but we want it here
        # (we do not want GetPopupMenu available for override in Ruby)
        spec.regard %w[wxTaskBarIcon::CreatePopupMenu]
        # This is used for CreatePopupMenu, a virtual method which is
        # overridden in user subclasses of TaskBarIcon to create the menu over
        # the icon.
        #
        # The Wx::Menu needs to be protected from GC so the typemap stores the
        # object returned by the ruby method in an instance variable so it's
        # marked. It also handles the special case where +nil+ is returned, to
        # signal to Wx that no menu is to be shown.
        spec.map 'wxMenu *' do
          map_directorout code: <<~__CODE
            rb_iv_set(swig_get_self(), "@__popmenu__", $1);
            if (NIL_P($1))
            {
              $result = NULL;
            }
            else
            {
              void * ptr;
              int swig_res = SWIG_ConvertPtr(result, &ptr, $1_descriptor, 0 | SWIG_POINTER_DISOWN);
              if (!SWIG_IsOK(swig_res))
              {
                Swig::DirectorTypeMismatchException::raise(swig_get_self(), "$symname", rb_eTypeError,
                         "create_popup_menu must return a Wx::Menu, or nil");
              }
              $result = reinterpret_cast < wxMenu * > (ptr);
            }
            __CODE
        end
        spec.add_extend_code 'wxTaskBarIcon', <<~__HEREDOC
          // Explicitly dispose of a TaskBarIcon; needed for clean exits on
          // Windows.
          VALUE destroy()
          {
            delete $self;
            return Qnil;
          }
          __HEREDOC
        # already generated with TaskBarIconEvent
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class TaskBarIcon

  end # class Director

end # module WXRuby3
