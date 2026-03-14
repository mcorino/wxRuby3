# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

require_relative './window'

module WXRuby3

  class Director

    class WebView < Window

      include Typemap::IOStreams
      include Typemap::DateTime

      def setup
        spec.items << 'wxWebViewHistoryItem'
        if Config.instance.wx_version_check('3.3.0') >= 0
          spec.items << 'wxWebViewConfiguration'
        end
        super
        if Config.instance.wx_version_check('3.3.0') >= 0
          spec.gc_as_object 'wxWebViewConfiguration'
          spec.no_proxy 'wxWebViewConfiguration'
          spec.extend_interface 'wxWebViewConfiguration', 'wxWebViewConfiguration()', visibility: 'protected'
          spec.make_abstract 'wxWebViewConfiguration'
        end
        spec.gc_as_untracked 'wxWebViewHistoryItem'
        spec.ignore 'wxWebViewHistoryItem::wxWebViewHistoryItem'
        spec.extend_interface 'wxWebViewHistoryItem', 'wxWebViewHistoryItem()', visibility: 'protected'
        spec.make_abstract 'wxWebViewHistoryItem'

        spec.no_proxy 'wxWebView'
        spec.ignore 'wxWebView::RegisterFactory'
        spec.ignore 'wxWebViewIE_EmulationLevel'

        spec.add_swig_code <<~__CODE
          %include <wx_shared_ptr.i>
          %wx_shared_ptr(wxWebViewHandler);
          %wx_shared_ptr(wxWebViewHistoryItem);
          __CODE

        spec.map 'wxVector< wxSharedPtr<wxWebViewHistoryItem> >' => 'Array<Wx::WEB::WebViewHistoryItem>' do
          map_out code: <<~__CODE
              $result = rb_ary_new();
              wxVector< wxSharedPtr<wxWebViewHistoryItem> > *history = (wxVector< wxSharedPtr<wxWebViewHistoryItem> > *)&$1;
              for (wxSharedPtr<wxWebViewHistoryItem>& hist_item : *history)
              {
                VALUE r_hist = SWIG_NewPointerObj(new wxSharedPtr<wxWebViewHistoryItem>(SWIG_STD_MOVE(hist_item)), SWIGTYPE_p_wxSharedPtrT_wxWebViewHistoryItem_t, SWIG_POINTER_OWN);
                rb_ary_push($result, r_hist);
              }
            __CODE
        end

        spec.map 'wxSharedPtr<wxWebViewHistoryItem>' => 'Wx::WEB::WebViewHistoryItem', swig: false do
          map_in code: ''
        end

        # fix event definitions
        if Config.instance.wx_version_check('3.3.0') >= 0
          # completely missing up and until 3.3.2 but should be there
          if Config.instance.wx_version_check('3.3.2') <= 0
            spec.add_swig_code %Q{%constant wxEventType wxEVT_WEBVIEW_BROWSING_DATA_CLEARED = wxEVT_WEBVIEW_BROWSING_DATA_CLEARED;}
          end
        end
      end

    end # class WebView

  end # class Director

end # module WXRuby3
