# Copyright (c) 2023 M.J.N. Corino, The Netherlands
#
# This software is released under the MIT license.

###
# wxRuby3 wxWidgets interface director
###

module WXRuby3

  class Director

    class DataViewColumn < Director

      def setup
        super
        spec.gc_as_object 'wxDataViewColumn'
        spec.override_inheritance_chain('wxDataViewColumn', [{ 'wxSettableHeaderColumn' => 'wxHeaderCtrl' }, { 'wxHeaderColumn' => 'wxHeaderCtrl' }])
        spec.add_header_code <<~__HEREDOC
            WXRUBY_TRACE_GUARD(WxRubyTraceMarkDVColumn, "GC_MARK_DVCOLUMN")
            static void GC_mark_wxDataViewColumn(void* ptr)
            {
              WXRUBY_TRACE_IF(WxRubyTraceMarkDVColumn, 2)
                WXRUBY_TRACE("> GC_mark_wxDataViewColumn : " << ptr)
              WXRUBY_TRACE_END
  
              // Mark attached renderer
              wxDataViewColumn* wx_dvcol = reinterpret_cast<wxDataViewColumn*> (ptr);
              rb_gc_mark(SWIG_RubyInstanceFor(wx_dvcol->GetRenderer()));               
            
              WXRUBY_TRACE_IF(WxRubyTraceMarkDVColumn, 2)
                WXRUBY_TRACE("< GC_mark_wxDataViewColumn : " << ptr)
              WXRUBY_TRACE_END
            }
            __HEREDOC
        spec.add_swig_code '%markfunc wxDataViewColumn "GC_mark_wxDataViewColumn";'
        spec.swig_import 'swig/classes/include/wxObject.h'
        spec.swig_import 'swig/classes/include/wxEvtHandler.h'
        spec.swig_import 'swig/classes/include/wxWindow.h'
        spec.swig_import 'swig/classes/include/wxControl.h'
        spec.disown 'wxDataViewRenderer *renderer'
        # add pure virtual base overrides missing from docs
        spec.extend_interface 'wxDataViewColumn',
                              'void	SetTitle(const wxString &title) override',
                              'void SetBitmap(const wxBitmapBundle &bitmap) override',
                              'void SetWidth(int width) override',
                              'void SetMinWidth(int minWidth) override',
                              'void SetAlignment(wxAlignment align) override',
                              'void SetFlags(int flags) override',
                              'void SetSortOrder(bool ascending) override'
        spec.do_not_generate :typedefs, :variables, :defines, :functions, :enums
      end

    end

  end

end
