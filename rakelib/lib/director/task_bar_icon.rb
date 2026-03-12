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
        spec.gc_as_object
        # need a custom implementation to handle event handler proc cleanup
        spec.add_header_code <<~__HEREDOC
          class WXRubyTaskBarIcon : public wxTaskBarIcon
          {
          public:
            WXRubyTaskBarIcon(wxTaskBarIconType iconType=wxTBI_DEFAULT_TYPE) : wxTaskBarIcon(iconType) {}
            virtual ~WXRubyTaskBarIcon() 
            {
              wxRuby_ReleaseEvtHandlerProcs(this);
              SWIG_RubyUnlinkObjects(this);
              SWIG_RubyRemoveTracking(this);
            }
          };
          __HEREDOC
        spec.use_class_implementation 'wxTaskBarIcon', 'WXRubyTaskBarIcon'
        # this one is protected so ignored by default but we want it here
        # (we do not want GetPopupMenu available for override in Ruby)
        spec.regard %w[wxTaskBarIcon::CreatePopupMenu]
        if Config.instance.wx_version_check('3.1.5') >= 0
          spec.regard %w[wxTaskBarIcon::GetPopupMenu]
        end
        # This is used for CreatePopupMenu and possibly GetPopupMenu, virtual methods which can be
        # overridden in user subclasses of TaskBarIcon to provide the menu over the icon.
        # In the case of GetPopupMenu the menu will be used but not deleted so it can be stored in
        # a member variable and reused.
        # In the case of CreatePopupMenu the menu is disowned and deleted after use. The Wx::Menu Ruby
        # instance than needs to be protected from GC so the typemap stores the object returned by the
        # ruby method in an instance variable so it's marked as long as the TaskBarIcon exists.
        # It also handles the special case where +nil+ is returned, to signal to Wx that no menu is to
        # be shown.
        spec.map 'wxMenu *' do
          map_directorout code: <<~__CODE
            static const std::string create_popup_menu("CreatePopupMenu");
            bool disown = (std::string("$symname") == create_popup_menu);
            if (disown) rb_iv_set(swig_get_self(), "@__popupmenu__", $1);
            if (NIL_P($1))
            {
              $result = nullptr;
            }
            else
            {
              void * ptr;
              int swig_res = SWIG_ConvertPtr(result, &ptr, $1_descriptor, disown ? SWIG_POINTER_DISOWN : 0);
              if (!SWIG_IsOK(swig_res))
              {
                Swig::DirectorTypeMismatchException::raise(swig_get_self(), "$symname", rb_eTypeError,
                         "create_popup_menu must return a Wx::Menu, or nil");
              }
              $result = static_cast <wxMenu *> (ptr);
            }
            __CODE
        end
        spec.do_not_generate :variables, :enums, :defines, :functions
      end
    end # class TaskBarIcon

  end # class Director

end # module WXRuby3
