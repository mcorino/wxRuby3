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

      def setup
        super

        spec.items << 'wxWebViewHistoryItem'
        spec.gc_as_window 'wxWebView'
        spec.make_abstract 'wxWebView'
        spec.no_proxy 'wxWebView'

        spec.ignore 'wxWebView::Create'
        spec.ignore 'wxWebView::RegisterFactory'
        spec.ignore 'wxWebView::NewConfiguration'
        spec.ignore 'wxWebView::New(const wxWebViewConfiguration&)'
        spec.ignore 'wxWebView::RegisterHandler'
        spec.ignore 'wxWebView::GetBackwardHistory'
        spec.ignore 'wxWebView::GetForwardHistory'
        spec.ignore 'wxWebView::LoadHistoryItem'
        spec.ignore 'wxWebView::GetNativeBackend'
        spec.ignore 'wxWebViewConfiguration'
        spec.ignore 'wxWebViewFactory'
        spec.ignore 'wxWebViewWindowFeatures'
        spec.ignore 'wxWebViewHandlerRequest'
        spec.ignore 'wxWebViewHandlerResponse'
        spec.ignore 'wxWebViewHandlerResponseData'
        spec.ignore 'wxWebViewHandler'
        spec.ignore 'wxWebView::SetPage(wxInputStream&, wxString)'
        spec.ignore 'wxWebView::RunScriptAsync'
        spec.ignore 'wxWebViewIE_EmulationLevel'

        spec.map 'wxString* output' => 'String' do
          map_in ignore: true, temp: 'wxString tmp', code: '$1 = &tmp;'
          map_argout code: '$result = SWIG_Ruby_AppendOutput($result, WXSTR_TO_RSTR(tmp$argnum));'
        end

        # Explicitly declare EVT constants as SWIG constants
        spec.add_swig_code '%constant int EVT_WEBVIEW_CREATED = wxEVT_WEBVIEW_CREATED;'
        spec.add_swig_code '%constant int EVT_WEBVIEW_NAVIGATING = wxEVT_WEBVIEW_NAVIGATING;'
        spec.add_swig_code '%constant int EVT_WEBVIEW_NAVIGATED = wxEVT_WEBVIEW_NAVIGATED;'
        spec.add_swig_code '%constant int EVT_WEBVIEW_LOADED = wxEVT_WEBVIEW_LOADED;'
        spec.add_swig_code '%constant int EVT_WEBVIEW_ERROR = wxEVT_WEBVIEW_ERROR;'
        spec.add_swig_code '%constant int EVT_WEBVIEW_NEWWINDOW = wxEVT_WEBVIEW_NEWWINDOW;'
        spec.add_swig_code '%constant int EVT_WEBVIEW_NEWWINDOW_FEATURES = wxEVT_WEBVIEW_NEWWINDOW_FEATURES;'
        spec.add_swig_code '%constant int EVT_WEBVIEW_WINDOW_CLOSE_REQUESTED = wxEVT_WEBVIEW_WINDOW_CLOSE_REQUESTED;'
        spec.add_swig_code '%constant int EVT_WEBVIEW_TITLE_CHANGED = wxEVT_WEBVIEW_TITLE_CHANGED;'
        spec.add_swig_code '%constant int EVT_WEBVIEW_FULLSCREEN_CHANGED = wxEVT_WEBVIEW_FULLSCREEN_CHANGED;'
        spec.add_swig_code '%constant int EVT_WEBVIEW_SCRIPT_MESSAGE_RECEIVED = wxEVT_WEBVIEW_SCRIPT_MESSAGE_RECEIVED;'
        spec.add_swig_code '%constant int EVT_WEBVIEW_SCRIPT_RESULT = wxEVT_WEBVIEW_SCRIPT_RESULT;'
        spec.add_swig_code '%constant int EVT_WEBVIEW_BROWSING_DATA_CLEARED = wxEVT_WEBVIEW_BROWSING_DATA_CLEARED;'

        spec.do_not_generate :variables, :functions
      end

    end # class WebView

  end # class Director

end # module WXRuby3