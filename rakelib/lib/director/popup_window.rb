# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class PopupWindow < Window

      def setup
        spec.items << 'wxPopupTransientWindow'
        super
        spec.items.each do |itm|
          spec.no_proxy("#{itm}::ClearBackground",
                        "#{itm}::Enable",
                        "#{itm}::GetHelpTextAtPoint",
                        "#{itm}::GetMaxSize",
                        "#{itm}::GetMinSize",
                        "#{itm}::Refresh",
                        "#{itm}::Update")
        end
        # add these to the generated interface to be parsed by SWIG
        # the wxWidgets docs are flawed in this respect that several reimplemented
        # virtual methods are not documented at the reimplementing class as such
        # that would cause them missing from the interface which would cause a problem
        # for a SWIG director redirecting to the Ruby class as the SWIG wrappers
        # redirect explicitly to the implementation at the same class level as the wrapper
        # for upcalls
        spec.extend_interface('wxPopupWindow',
                              'virtual bool Show(bool show = true) override')
        spec.extend_interface('wxPopupTransientWindow',
                              'virtual bool Destroy() override')
        # OSX defines this override on the wxNonOwnedWindow class but since we declared that 'no_proxy'
        # we have to the override on it's descendants wxPopupWindow and wxTopLevelWindow (the last one
        # having the override itself also on all platforms)
        if Config.instance.features_set?('WXOSX')
          spec.extend_interface('wxNonOwnedWindow',
                                'virtual bool Destroy() override')
        end
        # For ProcessLeftDown
        spec.map 'wxMouseEvent &' => 'Wx::MouseEvent' do
          map_directorin code: <<~__CODE
            #ifdef __WXRB_DEBUG__
            $input = wxRuby_WrapWxEventInRuby(this, static_cast<wxEvent*> (&$1));
            #else
            $input = wxRuby_WrapWxEventInRuby(static_cast<wxEvent*> (&$1));
            #endif
            __CODE
        end
      end

    end # class PopupWindow

  end # class Director

end # module WXRuby3
